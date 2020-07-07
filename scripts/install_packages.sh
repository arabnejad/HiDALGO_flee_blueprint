#!/bin/bash -l

#----------------------------------------
#        install required packages
#----------------------------------------
pip install --user ckanapi

PATH=/home/users/$(whoami)/.local/bin:$PATH

wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64

wget --no-check-certificate https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x jq-linux64

