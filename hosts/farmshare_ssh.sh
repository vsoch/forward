#!/bin/bash
#
# Farmshare cluster at Stanford
# Prints an ssh configuration for the user, selecting a login node at random
# Sample usage: bash farmshare_ssh.sh
echo
read -p "Farmshare username > "  USERNAME

# Get a login node to use.
# The current FarmShare generation uses "rice.stanford.edu", which is DNS
# load-balanced.  "rice.stanford.edu" is currently an alias to
# "rice.best.stanford.edu", and returns a CNAME to the best login node to use.
# WARNING: If the load-balancing method, or the name, ever changes; this will
# need to be updated.
FARMSHARE_HOST=$(dig +short +recurse rice.best.stanford.edu cname)

echo "Host farmshare
    User ${USERNAME}
    Hostname ${FARMSHARE_HOST}
    GSSAPIDelegateCredentials yes
    GSSAPIAuthentication yes
    ControlMaster auto
    ControlPersist yes
    ControlPath ~/.ssh/%l%r@%h:%p"
