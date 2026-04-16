#!/bin/bash

LOG_FILE="../output/workflow.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

run_step() {
	COMMAND="$1"
	log "START: $COMMAND"
	eval $COMMAND
	STATUS=$?

	if [ $STATUS -eq 0 ]; then
        	log "SUCCESS: $COMMAND"
    	else
        	log "ERROR ($STATUS): $COMMAND"
    	fi
}
log "----------start workflow----------"
run_step "python3 process_data.py"
echo "********************************************************************************************************"
echo "Python script executed"
echo "logged execution status to /output/workflow.log"
log "----------end workflow----------"
