#!/bin/bash
#
# Sherlock cluster at Stanford
# Prints an ssh configuration for the user, selecting a login node at random
# Sample usage: bash sherlock_ssh.sh
echo
read -p "Farmshare username > "  USERNAME

# Randomly select login node from 1..4
LOGIN_NODE=$((1 + RANDOM % 9))

echo "Host farmshare
    User ${USERNAME}
    Hostname rice0${LOGIN_NODE}.stanford.edu
    GSSAPIDelegateCredentials yes
    GSSAPIAuthentication yes
    ControlMaster auto
    ControlPersist yes
    ControlPath ~/.ssh/%l%r@%h:%p"
