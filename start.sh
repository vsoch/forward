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

NAME=$1
SBATCH=$NAME.sbatch

if [ ! -f "sbatches/$SBATCH" ]
then
    echo "$SBATCH does not exist!"
    exit
fi

echo "== Getting destination directory =="
SHERLOCK_HOME=`ssh sherlock pwd`

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

echo "== Waiting for job to start =="
MACHINE=""
until [[ "$MACHINE" == "sh"* ]]
do
    echo "not ready yet..."
    sleep 1
    MACHINE=`ssh sherlock squeue --name=$NAME --user=$USERNAME -o "%R" -h`
done

echo "notebook running on $MACHINE"
echo "== Setting up port forwarding =="
ssh -L $PORT:localhost:$PORT sherlock ssh -L $PORT:localhost:$PORT -N $MACHINE &

sleep 5
echo "== Connecting to notebook =="
open -a "$BROWSER" http://localhost:$PORT
