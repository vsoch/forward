#!/bin/bash

# This batch script is intended to run a containershare container, typically
# deploying a Docker container as Singularity from the containershare
# registry at https://vsoch.github.io/containershare. You can select
# containers that have jupyter notebooks (e.g., julia, jupyter, or similar)
# Open an issue there to request a custom container.

# Usage

# 1. Containershare Julia (with your scratch to work in)
# $ bash start.sh containershare-notebook docker://vanessa/repo2docker-julia

# Ensure we have at least port and container
if (( $# < 2 )); then
    echo "Please provide minimally PORT and CONTAINER"
    echo "containershare.sbatch <port> <container>"
    exit 1
fi

PORT=$1
CONTAINER="${2}"
NOTEBOOK_DIR="${3:-${SCRATCH}}"

module use system
module load singularity
export SINGULARITY_CACHEDIR="${SCRATCH}/.singularity"
echo "Container is ${CONTAINER}"
echo "Notebook directory is ${NOTEBOOK_DIR}"
cd ${NOTEBOOK_DIR}

# If it's not a file, try pulling it
if [ ! -f "${CONTAINER}" ]
    then
    echo "Container ${CONTAINER} not found on filesystem, attempting pull..."
    CONTAINER_NAME=$(echo -n "${CONTAINER}" | md5sum | awk '{ print $1 }').simg

    # Pull the container, if it doesn't exist.
    if [ ! -f "${SINGULARITY_CACHEDIR}/${CONTAINER_NAME}" ]
        then
        singularity pull --name "${CONTAINER_NAME}" "${CONTAINER}"
    fi
    CONTAINER="${SINGULARITY_CACHEDIR}/${CONTAINER_NAME}"
fi

# If still doesn't exist, exit
if [ ! -f "${CONTAINER}" ]
    then
    echo "Issue obtaining ${CONTAINER}."
    exit 1
fi

# Create .local folder for default modules, if doesn't exist
if [ ! -d "${HOME}/.local" ];
    then
        echo "Creating local python modules folder to map at ${HOME}/.local";
        mkdir -p "${HOME}/.local";
fi

singularity exec --home "${HOME}" --bind ${HOME}/.local:/home/joyvan/.local "${CONTAINER}" jupyter notebook --no-browser --port=$PORT --ip 0.0.0.0
