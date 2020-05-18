#!/bin/bash
#
# Starts a remote sbatch jobs without port forwarding.
# Sample usage: bash start-node.sh singularity docker://ubuntu

if [ ! -f params.sh ]
then
    echo "Need to configure params before first run, run setup.sh!"
    exit
fi
. params.sh

if [ ! -f helpers.sh ]
then
    echo "Cannot find helpers.sh script!"
    exit
fi
. helpers.sh

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

# set FORWARD_SCRIPT and FOUND
set_forward_script
check_previous_submit

echo
echo "== Getting destination directory =="
RESOURCE_HOME=`ssh ${RESOURCE} pwd`
ssh ${RESOURCE} mkdir -p $RESOURCE_HOME/forward-util

echo
echo "== Uploading sbatch script =="
scp "${FORWARD_SCRIPT}" "${RESOURCE}:$RESOURCE_HOME/forward-util/"

# adjust PARTITION if necessary
set_partition
echo

echo "== Submitting sbatch =="

SBATCH_NAME=$(basename $SBATCH)
command="sbatch
    --job-name=$NAME
    --partition=$PARTITION
    --output=$RESOURCE_HOME/forward-util/$NAME.out
    --error=$RESOURCE_HOME/forward-util/$NAME.err
    --mem=$MEM
    --time=$TIME
    $RESOURCE_HOME/forward-util/$SBATCH_NAME $PORT \"${@:2}\""

echo ${command}
ssh ${RESOURCE} ${command}

# Tell the user how to view error/output logs
instruction_get_logs

# Wait for the node allocation, get identifier
get_machine

echo "job is running on $MACHINE"

sleep 5
echo
echo "== Connecting to resource =="

# Print logs for the user, in case needed
print_logs

echo "Connect to machine:"
echo "ssh -t ${RESOURCE} ssh ${FORWARD_USERNAME}@${MACHINE}"
