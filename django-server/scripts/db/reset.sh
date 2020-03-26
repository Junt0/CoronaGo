#!/bin/bash
# Make sure to run     chmod a+x reset.sh     before running
# To execute  ./reset.sh

sudo -u postgres psql << EOF
  DROP DATABASE IF EXISTS coronagodb;
  create database coronagodb;
