#!/bin/bash
PORT=$1
NOTEBOOK_DIR=$2
cd $NOTEBOOK_DIR

module load protobuf/3.4.0
module load py-jupyter/1.0.0_py27
module load py-tensorflow/1.8.0_py27

jupyter notebook --no-browser --port=$PORT
