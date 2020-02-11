#!/bin/bash
##SBATCH -p gpu
##SBATCH --gpus 1
##SBATCH --cpus-per-gpu 8
##SBATCH -C GPU_MEM:16GB


PORT=$1
NOTEBOOK_DIR=$2
if [ -z "$NOTEBOOK_DIR" ]; then
    cd $SCRATCH
else
    cd $NOTEBOOK_DIR
fi

####module load py-jupyter/1.0.0_py27
module load gcc/7.3.0
module load gdb
module load cmake


module load cuda/10.1.168
module load cudnn/7.6.4
module load nccl

export CC=$(which gcc)
export CXX=$(which g++)
source activate base 
jupyter lab --no-browser --port=$PORT
