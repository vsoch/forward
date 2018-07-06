#!/bin/bash

PORT=$1
NOTEBOOK_DIR=$2
cd $NOTEBOOK_DIR
jupyter notebook --no-browser --port=$PORT
