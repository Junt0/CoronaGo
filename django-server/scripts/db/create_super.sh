#!/bin/bash
# Make sure to run     chmod a+x create_super.sh     before running
# To execute  ./create_super.sh

echo 'Enter a username:'
read USERNAME
echo 'Enter a password:'
read PASSWORD

sudo -u postgres psql << EOF
    create user $USERNAME with encrypted password '$PASSWORD';
    grant all privileges on database coronagodb to $USERNAME;
    ALTER USER $USERNAME CREATEDB;