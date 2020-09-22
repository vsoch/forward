#!/bin/bash
#
# Nero at Stanford
# Prints an ssh configuration for the user, selecting a login node at random
# Sample usage: bash nero_ssh.sh
echo
read -p "Nero username > "  FORWARD_USERNAME

# Randomly select login node from 1..4
LOGIN_NODE=$((1 + RANDOM % 8))

echo "Host nero
    User ${FORWARD_USERNAME}
    Hostname nero.compute.stanford.edu
    GSSAPIDelegateCredentials yes
    GSSAPIAuthentication yes
    ControlMaster auto
    ControlPersist yes
    ControlPath ~/.ssh/%C"
