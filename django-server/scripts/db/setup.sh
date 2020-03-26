#!/bin/bash
# Make sure to run     chmod a+x setup.sh     before running
# To execute  ./setup.sh

# PLEASE SET YOUR OWN PASSWORD

sudo apt update
sudo apt install postgresql postgresql-contrib

sudo /bin/bash reset.sh
sudo /bin/bash create_super.sh
