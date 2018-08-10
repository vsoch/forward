#!/bin/bash
#
# Sets up parameters for use with other scripts.  Should be run once.
# Sample usage: bash setup.sh

echo "First, choose the resource identifier that specifies your cluster resoure. We
will set up this name in your ssh configuration, and use it to reference the resource (sherlock)."
echo
read -p "Resource identifier (default: sherlock) > "  RESOURCE
RESOURCE=${RESOURCE:-sherlock}

echo
read -p "${RESOURCE} username > "  USERNAME

echo
echo "Next, pick a port to use.  If someone else is port forwarding using that
port already, this script will not work.  If you pick a random number in the
range 49152-65335, you should be good."
echo
read -p "Port to use > "  PORT

echo
echo "Next, pick the ${RESOURCE} partition on which you will be running your
notebooks.  If your PI has purchased dedicated hardware on ${RESOURCE}, you can use
that partition.  Otherwise, leave blank to use the default partition (normal)."
echo
read -p "${RESOURCE} partition (default: normal) > "  PARTITION
PARTITION=${PARTITION:-normal}

echo
SHARE="/scratch/users/vsochat/share"
echo "A containershare (https://vsoch.github.io/containershare is a library of
containers that are prebuilt for you, and provided on your cluster resource. if you
are at Stanford, leave this to be the default. If not, ask your HPC administrator
about setting one up, and direct them to https://www.github.com/vsoch/containershare."
echo
read -p "container shared folder (default for Stanford: ${SHARE}) > " CONTAINERSHARE
CONTAINERSHARE=${CONTAINERSHARE:-${SHARE}}

echo

MEM=20G

TIME=8:00:00

for var in USERNAME PORT PARTITION RESOURCE MEM TIME CONTAINERSHARE
do
    echo "$var="'"'"$(eval echo '$'"$var")"'"'
done >> params.sh
