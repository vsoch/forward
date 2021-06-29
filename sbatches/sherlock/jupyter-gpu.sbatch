#!/bin/bash

PORT=$1
NOTEBOOK_DIR=$2
if [ -z "$NOTEBOOK_DIR" ]; then
    cd $SCRATCH
else
    cd $NOTEBOOK_DIR
fi

## to compile libtorch C++ code, load these modules
# module load gcc/7.3.0
# module load gdb
# module load cmake
# export CC=$(which gcc)
# export CXX=$(which g++)

# please select correct cuda version match to the pytorch/tensorflow
module load cuda/10.1.168
module load cudnn/7.6.4
module load nccl

source activate base 
jupyter lab --no-browser --port=$PORT
