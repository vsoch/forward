#!/bin/bash

# Run a Singularity container notebook, meaning content is in /home/joyvan and
# your $HOME/.local is mounted to the container's $HOME/.local to make
# extra modules available.

# --- Usage
# bash start.sh sherlock/singularity-notebook <container>

# --- <container>
# This batch script is intended to run a singularity notebook container,
# and this can mean:

# A Singularity container image FILE on your scratch
# $ bash start.sh sherlock/singularity-notebook /scratch/users/vsochat/julia.simg

# A Docker unique resource identifier
# $ bash start.sh sherlock/singularity-notebook docker://<username>/<repository>:<tag>

# A Singularity Hub unique resource identifier
# $ bash start.sh sherlock/singularity-notebook shub://<username>/<repository>:<tag>

# --- Container Expectations
# In all cases, it's expected that the notebook is in /home/joyvan (jupyter
# standard). Your local installation directory (at $HOME/.local) will be 
# mapped to the container so that modules you have installed locally will 
# be usable in the notebook.

# Ensure we have at least port and container
if (( $# < 2 )); then
    echo "Please provide minimally PORT and CONTAINER"
    echo "singularity-notebook.sbatch <port> <container>"
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

    # Attempt 1: look in the containershare
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
