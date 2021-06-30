#!/bin/bash
#
# Starts a remote sbatch jobs and sets up correct port forwarding.
# Sample usage: bash end.sh jupyter
#               bash end.sh tensorboard

if [ ! -f params.sh ]
then
    echo "Need to configure params before first run, run setup.sh!"
    exit
fi
source params.sh

if [ "$#" -eq 0 ]
then
    echo "Need to give name of sbatch job to kill!"
    exit
fi

NAME=$1

echo "Killing $NAME slurm job on ${RESOURCE}"
ssh ${RESOURCE} "squeue --name=$NAME --user=$FORWARD_USERNAME -o '%A' -h | xargs --no-run-if-empty /usr/bin/scancel"

echo "Killing listeners on ${RESOURCE}"
ssh ${RESOURCE} "${USE_LSOF} -i :$PORT -t | xargs --no-run-if-empty kill"
