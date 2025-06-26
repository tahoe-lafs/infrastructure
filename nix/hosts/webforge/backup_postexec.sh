#!/usr/bin/env bash

# Configure bash behavior
set -o xtrace   # print every call to help debugging
set -o errexit  # exit on failed command
set -o nounset  # exit on undeclared variables
set -o pipefail # exit on any failed command in pipes

# Start services after backup
systemctl start \
	  postfix.service \
	  forgejo.service \
	  borgbackup-job-rsnapshot.service
