#!/bin/bash

PORT=$1
NOTEBOOK_DIR=$2
cd $NOTEBOOK_DIR

module load py-jupyter/1.0.0_py36
module load R/3.4.0

# You will need to set up a jupyter notebook password first, see the mini
# tutorial at https://vsoch.github.io/lessons/sherlock-juputer-r/
# Note to user: it's helpful to install these before running the script, and then
# have the script just load (and not need to compile and install!)

# Install devtools and IRkernel
Rscript -e "install.packages('devtools', repos='http://cran.us.r-project.org');"
Rscript -e "library('devtools'); devtools::install_github('IRkernel/IRkernel')"

# register the kernel in the current R installation
Rscript -e "IRkernel::installspec(name = 'ir34', displayname = 'R 3.4')"

jupyter notebook --no-browser --port=$PORT
