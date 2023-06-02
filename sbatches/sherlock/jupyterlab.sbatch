#!/bin/bash

PORT=$1
NOTEBOOK_DIR=$2
cd $NOTEBOOK_DIR

module load python/3.6.1
module load nodejs/9.5.0
jupyter lab --no-browser --port=$PORT
