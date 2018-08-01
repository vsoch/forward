#!/bin/bash

CONTAINER=${1}
NOTEBOOK_DIR=${2}
shift shift
cd $NOTEBOOK_DIR

# Script assumes Singularity is already available

# If the user has a scratch, define cache here
if [ -d "${SCRATCH}" ]
    then
    export SINGULARITY_CACHEDIR=$SCRATCH/.singularity
fi
singularity exec ${CONTAINER} "${@}"
