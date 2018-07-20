#!/bin/bash

# Usage

# 1. Default Jupyter notebook (with your scratch to work in)
# $ bash start.sh singularity-jupyter

# 2. Default Jupyter notebook with custom working directory
# $ bash start.sh singularity-jupyter /scratch/users/<username>

# 3. Select your own jupyter container on Sherlock!
# $ bash start.sh singularity-jupyter /scratch/users/<username> /path/to/container

# 4. Or any singularity container...
# $ bash start.sh singularity /path/to/container <args>

PORT=$1
NOTEBOOK_DIR=${2:-${SCRATCH}}
CONTAINER=${3:-/scratch/users/vsochat/share/repo2docker.simg}

module load singularity
export SINGULARITY_CACHEDIR="${SCRATCH}/.singularity"
echo "Container is ${CONTAINER}"
echo "Notebook directory is ${NOTEBOOK_DIR}"
cd ${NOTEBOOK_DIR}
singularity exec ${CONTAINER} jupyter notebook --no-browser --port=$PORT --ip 0.0.0.0
