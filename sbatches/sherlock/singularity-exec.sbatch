#!/bin/bash

# The singularity-run script will run a container, and it would use the
# container's runscript as entrypoint. To execute a command, 
# use singularity-exec

CONTAINER=${1}
shift

if [ "$#" -gr 0 ]; then
    NOTEBOOK_DIR=${1}
    shift 1
else
    NOTEBOOK_DIR=${SCRATCH}
fi

cd $NOTEBOOK_DIR

module use system
module load singularity
export SINGULARITY_CACHEDIR=$SCRATCH/.singularity
singularity exec ${CONTAINER} "${@}"
