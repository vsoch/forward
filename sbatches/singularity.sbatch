#!/bin/bash

CONTAINER=${1}
NOTEBOOK_DIR=${2}
shift shift
cd $NOTEBOOK_DIR

module load singularity
export SINGULARITY_CACHEDIR=$SCRATCH/.singularity
singularity exec ${CONTAINER} "${@}"
