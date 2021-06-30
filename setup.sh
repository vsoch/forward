#!/bin/bash
#
# Sets up parameters for use with other scripts.  Removes an instance of param.sh if it exists. 
# Sample usage: bash setup.sh
# Can be run for any number of times
rm -r params.sh
echo "First, choose the resource identifier that specifies your cluster resoure. We
will set up this name in your ssh configuration, and use it to reference the resource (sherlock)."
echo
read -p "Resource identifier (default: sherlock) > "  RESOURCE
RESOURCE=${RESOURCE:-sherlock}
if [[ "${RESOURCE}" == "sherlock" ]]
then
   SHERLOCK=true
   MACHINEPREFIX=${MACHINEPREFIX:-sh}
else 
   SHERLOCK=false
   MACHINEPREFIX=${MACHINEPREFIX:-wheat}
fi



echo
read -p "${RESOURCE} username > "  FORWARD_USERNAME

echo
echo "Next, pick a port to use.  If someone else is port forwarding using that
port already, this script will not work.  If you pick a random number in the
range 49152-65335, you should be good. For farmshare, please use a port number higher than
32768."
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
about setting one up, and direct them to https://www.github.com/vsoch/containershare.
For farmshare, leave blank to use default singularity maintained by Paul Nuyujukian (/farmshare/home/classes/bioe/301p/ce/ces)"
echo
read -p "container shared folder (default for Stanford: ${SHARE}) > " CONTAINERSHARE
if $SHERLOCK
then
   CONTAINERSHARE=${CONTAINERSHARE:-${SHARE}}
else
   CONTAINERSHARE=${CONTAINERSHARE:-/farmshare/home/classes/bioe/301p/ce/ces}
fi
echo

MEM=20G

TIME=8:00:00

for var in FORWARD_USERNAME PORT PARTITION RESOURCE MEM TIME CONTAINERSHARE SHERLOCK MACHINEPREFIX
do
    echo "$var="'"'"$(eval echo '$'"$var")"'"'
done >> params.sh
