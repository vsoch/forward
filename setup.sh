#!/bin/bash
#
# Sets up parameters for use with other scripts.  Should be run once.
# Sample usage: bash setup.sh
echo
read -p "Sherlock username > "  USERNAME

echo
echo "Next, pick a port to use.  If someone else is port forwarding using that
port already, this script will not work.  If you pick a random number in the
range 49152-65335, you should be good."
echo
read -p "Port to use > "  PORT

echo
echo "Next, pick the sherlock partition on which you will be running your
notebooks.  If your PI has purchased dedicated hardware on sherlock, you can use
that partition.  Otherwise, leave blank to use the default partition (normal)."
echo
read -p "Sherlock partition (default: normal) > "  PARTITION
PARTITION=${PARTITION:-normal}

echo
echo "Next, pick the path to the browser you wish to use.  Will default to Safari."
echo
read -p "Browser to use (default: /Applications/Safari.app/) > "  BROWSER
BROWSER=${BROWSER:-"/Applications/Safari.app/"}

MEM=20G

TIME=8:00:00

for var in USERNAME PORT PARTITION BROWSER MEM TIME
do
    echo "$var="'"'"$(eval echo '$'"$var")"'"'
done >> params.sh
