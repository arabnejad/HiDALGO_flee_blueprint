#!/bin/bash -l

CFGFILE="flee.cfg"
source $CFGFILE

#----------------------------------------
#        install required packages
#----------------------------------------
echo "Install ckanapi python package"
pip3 install --user ckanapi
echo "DONE..."


#----------------------------------------
#     Add ckanapi to PATH
#----------------------------------------
cat << EOF_CFGFILE >> $CFGFILE
export PATH=/home/users/\$(whoami)/.local/bin:\$PATH
EOF_CFGFILE

wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64

wget --no-check-certificate https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x jq-linux64

