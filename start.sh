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

# The user could request either <resource>/<script>.sbatch or
#                               <name>.sbatch
SBATCH="$NAME.sbatch"

# Exponential backoff Configuration

TIMEOUT=${TIMEOUT-1}
ATTEMPT=0

# Will be changed to script name, if found

FOUND="no"
echo "== Finding Script =="

declare -a FORWARD_SCRIPTS=("sbatches/${RESOURCE}/$SBATCH" 
                            "sbatches/$SBATCH"
                            "${RESOURCE}/$SBATCH" 
                            "$SBATCH");

for FORWARD_SCRIPT in "${FORWARD_SCRIPTS[@]}"
do
    echo "Looking for ${FORWARD_SCRIPT}";
    if [ -f "${FORWARD_SCRIPT}" ]
        then
        FOUND="${FORWARD_SCRIPT}"
        echo "Script      ${FORWARD_SCRIPT}";
        break
    fi
done
echo

if [ "${FOUND}" == "no" ]
then    
    echo "sbatch script not found!!";
    echo "Make sure \$RESOURCE is defined" ;
    echo "and that your sbatch script exists in the sbatches folder.";
    exit
fi

# Since we just have one port, only allow the user one running at a time
# This command will return empty (not defined) if nothing running

echo "== Checking for previous notebook =="
PREVIOUS=`ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o "%R" -h`
if [ -z "$PREVIOUS" -a "${PREVIOUS+xxx}" = "xxx" ]; 
  then
      echo "No existing ${NAME} jobs found, continuing..."
  else
      echo "Found existing job for ${NAME}, ${PREVIOUS}."
      echo "Please end.sh before using start.sh, or use resume.sh to resume."
      exit 1
fi

echo
echo "== Getting destination directory =="
RESOURCE_HOME=`ssh ${RESOURCE} pwd`
ssh ${RESOURCE} mkdir -p $RESOURCE_HOME/forward-util

echo
echo "== Uploading sbatch script =="
scp $FOUND sherlock:$RESOURCE_HOME/forward-util/

# Give them one gpu :)
if [ "${PARTITION}" == "gpu" ];
  then
      echo "== Requesting GPU =="
      PARTITION="${PARTITION} --gres gpu:1"
  fi

echo
echo "== Submitting sbatch =="

command="${RESOURCE} sbatch
    --job-name=$NAME
    --partition=$PARTITION
    --output=$RESOURCE_HOME/forward-util/$NAME.out
    --error=$RESOURCE_HOME/forward-util/$NAME.err
    --mem=$MEM
    --time=$TIME
    $RESOURCE_HOME/forward-util/$SBATCH $PORT \"${@:2}\""

echo ${command}
ssh ${command}

# Tell the user how to debug before trying

echo
echo "== View logs in separate terminal =="
echo "ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${NAME}.out"
echo "ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${NAME}.err"

echo
echo "== Waiting for job to start, using exponential backoff =="
MACHINE=""

ALLOCATED="no"
while [[ $ALLOCATED == "no" ]]
  do
                                                                  # nodelist
    MACHINE=`ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o "%N" -h`
    
    if [[ "$MACHINE" != "" ]]
      then
        echo "Attempt ${ATTEMPT}: resources allocated to ${MACHINE}!.."  1>&2
        ALLOCATED="yes"
        break
    fi

    echo "Attempt ${ATTEMPT}: not ready yet... retrying in $TIMEOUT.."  1>&2
    sleep $TIMEOUT
    ATTEMPT=$(( ATTEMPT + 1 ))
    TIMEOUT=$(( TIMEOUT * 2 ))

  done

echo $MACHINE
MACHINE="`ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o "%R" -h`"
echo $MACHINE

# If we didn't get a node...
if [[ "$MACHINE" != "sh"* ]]
  then
    echo "Max attempts ${MAX_ATTEMPTS} reached!"  1>&2
    exit 1
fi

echo "notebook running on $MACHINE"

echo
echo "== Setting up port forwarding =="
sleep 5
echo "ssh -L $PORT:localhost:$PORT ${RESOURCE} ssh -L $PORT:localhost:$PORT -N $MACHINE &"
ssh -L $PORT:localhost:$PORT ${RESOURCE} ssh -L $PORT:localhost:$PORT -N "$MACHINE" &

sleep 5
echo
echo "== Connecting to notebook =="

# Print logs for the user, in case needed
ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${NAME}.out
ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${NAME}.err
echo "Open your browser to http://localhost:$PORT"
