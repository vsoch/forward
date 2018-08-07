#!/bin/bash
PORT=$1
TENSORBOARD_DIR=$2

module load py-tensorflow/1.8.0_py27
python -m tensorboard.main --logdir $TENSORBOARD_DIR --debug --port=$PORT
