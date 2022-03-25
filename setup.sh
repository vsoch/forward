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
   MACHINEPREFIX=${MACHINEPREFIX:-sh}
   USE_LSOF=${USE_LSOF:-/usr/sbin/lsof}
   DOMAINNAME=${DOMAINNAME:-login.sherlock.stanford.edu}
   ISOLATEDCOMPUTENODE=${ISOLATEDCOMPUTENODE:-true}
  
elif [[ "${RESOURCE}" == "farmshare" ]]
then
   MACHINEPREFIX=${MACHINEPREFIX:-wheat}
   USE_LSOF=${USE_LSOF:-lsof}
   DOMAINNAME=${DOMAINNAME:-rice.stanford.edu}
   ISOLATEDCOMPUTENODE=${ISOLATEDCOMPUTENODE:-false}

else
   echo "Since, you are not using farmshare or sherlock, please supply the domain name of your resource"
   echo
   read -p "Domain Name for Resource > " DOMAINNAME
   echo 
   echo "Next, please supply the prefix of the compute nodes that are used in your cluster resource. We will use this to check for assignment of
   compute node when we submit the sbatch script. If you are using sherlock or farmshare (without gpu capability), then prefixes are set for you."
   echo
   read -p "Compute Node Prefix identifier > "  MACHINEPREFIX
   echo
   echo "Are the compute nodes in your HPC cluster isolated from the outside internet?"
   echo
   read -p "Isolation Status (type true or false) >" ISOLATEDCOMPUTENODE
   echo 
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
For farmshare, leave blank to use default singularity maintained by Soham Sinha, which you will need to pull into your home directory. Check README located in sbatches/farmshare/README.md"
echo
read -p "container shared folder (default for Stanford: ${SHARE}) > " CONTAINERSHARE
echo
if [[ "${RESOURCE}" == "sherlock" ]]
then 
   CONTAINERSHARE=${CONTAINERSHARE:-${SHARE}}
elif [[ "${RESOURCE}" == "farmshare" ]]
then 
   CONTAINERSHARE=${CONTAINERSHARE:-library://sohams/default/farmsharejupyter:latest}
fi

echo
echo "Finally, how many seconds would you like to wait for a connection?"
echo
read -p "Seconds to wait (default, 10) > "  CONNECTION_WAIT_SECONDS
CONNECTION_WAIT_SECONDS=${CONNECTION_WAIT_SECONDS:-10}




MEM=20G

TIME=8:00:00


for var in FORWARD_USERNAME PORT PARTITION RESOURCE MEM TIME CONTAINERSHARE MACHINEPREFIX DOMAINNAME USE_LSOF ISOLATEDCOMPUTENODE CONNECTION_WAIT_SECONDS
do
    echo "$var="'"'"$(eval echo '$'"$var")"'"'
done >> params.sh
