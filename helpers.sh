#!/bin/bash
#
# Helper Functions shared between forward tool scripts

#
# Configuration
#

function set_forward_script() {

    FOUND="no"
    echo "== Finding Script =="

    declare -a FORWARD_SCRIPTS=("sbatches/${RESOURCE}/$SBATCH" 
                                "sbatches/$SBATCH"
                                "${RESOURCE}/$SBATCH" 
                                "$SBATCH");

    for FORWARD_SCRIPT in "${FORWARD_SCRIPTS[@]}"
    do
        echo "Looking for ${FORWARD_SCRIPT}";
        if [ -f "${FORWARD_SCRIPT}" ]
            then
            FOUND="${FORWARD_SCRIPT}"
            echo "Script      ${FORWARD_SCRIPT}";
            break
        fi
    done
    echo

    if [ "${FOUND}" == "no" ]
    then
        echo "sbatch script not found!!";
        echo "Make sure \$RESOURCE is defined" ;
        echo "and that your sbatch script exists in the sbatches folder.";
        exit
    fi

}

#
# Job Manager
#

function check_previous_submit() {

    echo "== Checking for previous notebook =="
    PREVIOUS=`ssh ${RESOURCE} squeue --name=$NAME --user=$FORWARD_USERNAME -o "%R" -h`
    if [ -z "$PREVIOUS" -a "${PREVIOUS+xxx}" = "xxx" ]; 
        then
            echo "No existing ${NAME} jobs found, continuing..."
        else
        echo "Found existing job for ${NAME}, ${PREVIOUS}."
        echo "Please end.sh before using start.sh, or use resume.sh to resume."
        exit 1
    fi
}


function set_partition() {

    if [ "${PARTITION}" == "gpu" ];
    then
        echo "== Requesting GPU =="
        PARTITION="${PARTITION} --gres gpu:1"
    fi
}

function get_machine() {

    TIMEOUT=${TIMEOUT-1}
    ATTEMPT=0

    echo
    echo "== Waiting for job to start, using exponential backoff =="
    MACHINE=""

    ALLOCATED="no"
    while [[ $ALLOCATED == "no" ]]
      do
                                                                  # nodelist
          MACHINE=`ssh ${RESOURCE} squeue --name=$NAME --user=$FORWARD_USERNAME -o "%N" -h`
    
          if [[ "$MACHINE" != "" ]]
          then
              echo "Attempt ${ATTEMPT}: resources allocated to ${MACHINE}!.."  1>&2
              ALLOCATED="yes"
              break
          fi

        echo "Attempt ${ATTEMPT}: not ready yet... retrying in $TIMEOUT.."  1>&2
        sleep $TIMEOUT

        ATTEMPT=$(( ATTEMPT + 1 ))
        TIMEOUT=$(( TIMEOUT * 2 ))

    done

    echo $MACHINE
    MACHINE="`ssh ${RESOURCE} squeue --name=$NAME --user=$FORWARD_USERNAME -o "%R" -h`"
    echo $MACHINE

    # If we didn't get a node...
    if [[ "$MACHINE" != "$MACHINEPREFIX"* ]]
    then	
        echo "Tried ${ATTEMPTS} attempts!"  1>&2
        exit 1
    fi
}


#
# Instructions
#


function instruction_get_logs() {
    echo
    echo "== View logs in separate terminal =="
    echo "ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${SBATCH_NAME}.out"
    echo "ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${SBATCH_NAME}.err"
}

function print_logs() {

    ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${SBATCH_NAME}.out
    ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${SBATCH_NAME}.err

}

#
# Port Forwarding
#

function setup_port_forwarding() {

    echo
    echo "== Setting up port forwarding =="
    sleep 5
    if $ISOLATEDCOMPUTENODE
    then 
       echo "ssh -L $PORT:localhost:$PORT ${RESOURCE} ssh -L $PORT:localhost:$PORT -N $MACHINE &"
       ssh -L $PORT:localhost:$PORT ${RESOURCE} ssh -L $PORT:localhost:$PORT -N "$MACHINE" &
    else
       echo "ssh $DOMAINNAME -l $FORWARD_USERNAME -K -L  $PORT:$MACHINE:$PORT -N  &"
       ssh "$DOMAINNAME" -l $FORWARD_USERNAME -K -L  $PORT:$MACHINE:$PORT -N  &
    fi
}
