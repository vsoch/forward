#!/bin/bash
#
# Resumes an already running remote sbatch job.
# Sample usage: bash resume.sh

if [ ! -f params.sh ]
then
    echo "Need to configure params before first run, run setup.sh!"
    exit
fi
source params.sh

# The user is required to specify port

MACHINE=`ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o "%N" -h`
ssh -L $PORT:localhost:$PORT ${RESOURCE} ssh -L $PORT:localhost:$PORT -N $MACHINE &
