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

# --- Containershare: You can select
# If you need a set of notebooks to use, or bootstrap, check out the 
# containershare provided by @vsoch: https://vsoch.github.io/containershare 
# These are all Docker containers that are used by this tool by pulling
# them onto the cluster as Singularity containers with have jupyter notebooks 
# (e.g., julia, jupyter, or similar)

# Please Open an issue there to request a custom container! :)

# Ensure we have at least port and container
if (( $# < 2 )); then
    echo "Please provide minimally PORT and CONTAINER"
    echo "singularity-notebook.sbatch <port> <container>"
    exit 1
fi

PORT=$1
CONTAINER="${2}"
NOTEBOOK_DIR="${3:-${SCRATCH}}"
CONTAINERSHARE=${4:-/scratch/users/vsochat/share}

module use system
module load singularity
export SINGULARITY_CACHEDIR="${SCRATCH}/.singularity"
echo "Container is ${CONTAINER}"
echo "Notebook directory is ${NOTEBOOK_DIR}"
cd ${NOTEBOOK_DIR}

# If it's not a file, try pulling it
if [ ! -f "${CONTAINER}" ]
    then

    # The container name is the hash of the string
    CONTAINER_NAME=$(echo -n "${CONTAINER}" | md5sum | awk '{ print $1 }').simg

    # Attempt 1: look in the containershare
    echo "Attempt 1: Looking for ${CONTAINERSHARE}/${CONTAINER_NAME}"
    if [ -f "${CONTAINERSHARE}/${CONTAINER_NAME}" ]
        then
        echo "Container ${CONTAINER} found in containershare!"
        CONTAINER="${CONTAINERSHARE}/${CONTAINER_NAME}"
    else

        # Attempt 2: Look in the user's cache
        if [ ! -f "${SINGULARITY_CACHEDIR}/${CONTAINER_NAME}" ]
            then
            echo "Attempt 2: Container ${CONTAINER} not found on filesystem, attempting pull..."
            echo "singularity pull --name ${CONTAINER_NAME} ${CONTAINER}"
            singularity pull --name "${CONTAINER_NAME}" "${CONTAINER}"
        fi

        # Pull the container, if it doesn't exist.
        CONTAINER="${SINGULARITY_CACHEDIR}/${CONTAINER_NAME}"

    fi
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
