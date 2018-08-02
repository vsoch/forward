#!/bin/bash
#
# Farmshare cluster at Stanford
# Prints an ssh configuration for the user, selecting a login node at random
# Sample usage: bash farmshare_ssh.sh
echo
read -p "Farmshare username > "  USERNAME

# The FarmShare login node is (as of 2018) rice.stanford.edu.  That is a
# load-balanced DNS.  The use of ControlMaster will ensure that multiple
# connections to rice.stanford.edu all go to the same host.

echo "Host farmshare
    User ${USERNAME}
    Hostname rice.stanford.edu
    GSSAPIDelegateCredentials yes
    GSSAPIAuthentication yes
    ControlMaster auto
    ControlPersist yes
    ControlPath ~/.ssh/%l%r@%h:%p"
