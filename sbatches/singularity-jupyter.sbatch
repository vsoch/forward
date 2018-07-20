#!/bin/bash

PORT=$1
NOTEBOOK_DIR=$2
CONTAINER=${3:-/scratch/users/vsochat/share/repo2docker.simg}
cd $NOTEBOOK_DIR

module load singularity
export SINGULARITY_CACHEDIR=$SCRATCH/.singularity
echo "Container is ${CONTAINER}"
singularity exec ${CONTAINER} jupyter notebook --no-browser --port=$PORT --ip 0.0.0.0
