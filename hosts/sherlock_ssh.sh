#!/bin/bash
#
# Sherlock cluster at Stanford
# Prints an ssh configuration for the user, selecting a login node at random
# Sample usage: bash sherlock_ssh.sh
echo
read -p "Sherlock username > "  USERNAME

# Randomly select login node from 1..4
LOGIN_NODE=$((1 + RANDOM % 8))

echo "Host sherlock
    User ${USERNAME}
    Hostname sh-ln0${LOGIN_NODE}.stanford.edu
    GSSAPIDelegateCredentials yes
    GSSAPIAuthentication yes
    ControlMaster auto
    ControlPersist yes
    ControlPath ~/.ssh/%l%r@%h:%p"
