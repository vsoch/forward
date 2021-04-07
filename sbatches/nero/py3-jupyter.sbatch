#!/bin/bash

PORT=$1
NOTEBOOK_DIR=${2:-${HOME}}
cd $NOTEBOOK_DIR

export PATH=/share/sw/open/anaconda/3/bin:$PATH

pip3 install nbserverproxy --user
cat /etc/hosts
jupyter lab --ip=0.0.0.0 --port=${PORT}
