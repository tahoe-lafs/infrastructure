#!/usr/bin/env bash

# Configure bash behavior
set -o xtrace   # print every call to help debugging
set -o errexit  # exit on failed command
set -o nounset  # exit on undeclared variables
set -o pipefail # exit on any failed command in pipes

# Create file with read/write permissions for root only
umask 0077

# Dump the database using the postgres user privileges
sudo -u postgres pg_dumpall | tee > pg_dumpall.sql
