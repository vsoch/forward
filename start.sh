#!/bin/bash
#
# Starts a remote sbatch jobs and sets up correct port forwarding.
# Sample usage: bash start.sh jupyter
#               bash start.sh jupyter /home/users/raphtown
#               bash start.sh tensorboard /home/users/raphtown
if [ ! -f params.sh ]
then
    echo "Need to configure params before first run, run setup.sh!"
    exit
fi
source params.sh

if [ "$#" -eq 0 ]
then
    echo "Need to give name of sbatch job to run!"
    exit
fi

NAME="${1:-}"
SBATCH="$NAME.sbatch"

# Exponential backoff Configuration

TIMEOUT=${TIMEOUT-1}
ATTEMPT=0

if [ ! -f "sbatches/$SBATCH" ]
then
    echo "$SBATCH does not exist!"
    exit
fi

# Since we just have one port, only allow the user one running at a time

echo "== Checking for previous notebook =="
PREVIOUS=`ssh sherlock squeue --name=$NAME --user=$USERNAME -o "%R" -h`
if [ -z "$PREVIOUS" -a "${PREVIOUS+xxx}" = "xxx" ]; 
  then
      echo "No existing ${NAME} jobs found, continuing..."
  else
      echo "Found existing job for ${NAME}, ${PREVIOUS}."
      echo "Please end.sh before using start.sh, or use resume.sh to resume."
      exit 1
fi

echo "== Getting destination directory =="
SHERLOCK_HOME=`ssh sherlock pwd`
ssh sherlock mkdir -p $SHERLOCK_HOME/forward-util

echo "== Uploading sbatch script =="
scp sbatches/$SBATCH sherlock:$SHERLOCK_HOME/forward-util/

echo "== Submitting sbatch =="
ssh sherlock sbatch \
    --job-name=$NAME \
    --partition=$PARTITION \
    --output=$SHERLOCK_HOME/forward-util/$NAME.out \
    --error=$SHERLOCK_HOME/forward-util/$NAME.err \
    --mem=$MEM \
    --time=$TIME \
    $SHERLOCK_HOME/forward-util/$SBATCH $PORT "${@:2}"

echo "== Waiting for job to start, using exponential backoff =="
MACHINE=""

ALLOCATED="no"
while [[ $ALLOCATED == "no" ]]
  do

    MACHINE="`ssh sherlock squeue --name=$NAME --user=$USERNAME -o "%R" -h`"
    echo ${MACHINE}

    if [[ "$MACHINE" == "sh"* ]]
      then
        echo "Attempt ${ATTEMPT}: resources allocated to ${MACHINE}!.."  1>&2
        ALLOCATED="yes"
        break
    fi

    echo "Attempt ${ATTEMPT}: not ready yet... retrying in $TIMEOUT.."  1>&2
    sleep $TIMEOUT
    ATTEMPT=$(( ATTEMPT + 1 ))
    TIMEOUT=$(( TIMEOUT * 2 ))
    echo $ATTEMPT
    echo $TIMEOUT
    echo $MAX_ATTEMPTS

  done

echo $MACHINE

# If we didn't get a node...
if [[ "$MACHINE" != "sh"* ]]
  then
    echo "Max attempts ${MAX_ATTEMPTS} reached!"  1>&2
    exit 1
fi

echo "notebook running on $MACHINE"
echo "== Setting up port forwarding =="
echo "ssh -L $PORT:localhost:$PORT sherlock ssh -L $PORT:localhost:$PORT -N $MACHINE &"
ssh -L $PORT:localhost:$PORT sherlock ssh -L $PORT:localhost:$PORT -N "$MACHINE" &

sleep 5
echo "== Connecting to notebook =="
"Open your browser to http://localhost:$PORT"
