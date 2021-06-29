#!/bin/bash

# The singularity-exec script will execute a command to a container.
# To run a container, use singularity-run

CONTAINER=${1}
shift

if [ "$#" -gr 0 ]; then
    NOTEBOOK_DIR=${1}
    shift 1
else
if [ -d "${SCRATCH}" ]
    then
        NOTEBOOK_DIR=${SCRATCH}
    else
        NOTEBOOK_DIR=$HOME
    fi
fi

cd $NOTEBOOK_DIR

# Script assumes Singularity is already available

singularity exec ${CONTAINER} "${@}"
