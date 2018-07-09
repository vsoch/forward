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

MACHINE=`ssh sherlock squeue --name=$NAME --user=$USERNAME -o "%N" -h`
ssh -L $PORT:localhost:$PORT sherlock ssh -L $PORT:localhost:$PORT -N $MACHINE &
