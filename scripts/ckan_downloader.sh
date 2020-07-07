#!/bin/bash -l


#----------------------------------------
#        load ENV variables
#----------------------------------------
CFGFILE="flee.cfg"
source $CFGFILE

#----------------------------------------
#     check CNAK repo ENV variable
#----------------------------------------
if [ -z $CKANREPO ]
then
	echo "no CKANREPO specified !!!"
	exit 1
else
	echo USING $CKANREPO
fi

#----------------------------------------
#     create inputs folder
#----------------------------------------
if [ -d inputs ]; then
  rm -rf inputs
fi
mkdir -p inputs

#----------------------------------------
#     downloading input files from CKAN
#     based on INPUT_CONFIG_TAGS ENV variable
#----------------------------------------
DATASET=$(ckanapi action package_search fq=$INPUT_CONFIG_TAGS -r $CKANREPO | ./jq-linux64 -r .results[].name)
echo $DATASET

if [ -z "$DATASET" ]
then
    echo "There is no dataset with name input tag names : $INPUT_CONFIG_TAGS"
    exit 1
else
    echo "Found Datasets: $DATASET, Downloading resources"
fi

for i in $(ckanapi action package_show id=$DATASET -r $CKANREPO | ./jq-linux64 -r .resources[].url)
do
    echo $i
    wget $i -P inputs
done
echo "Downloading Input files from CKAN: DONE"


#----------------------------------------
#     check user input config and exact it
#----------------------------------------
INPUT_FILES=$(find inputs -name "$CONFIG_NAME*" -type f)

if [ -z "$INPUT_FILES" ]; then
    echo "there is not input config file name matching $CONFIG_NAME"
    exit 1
fi

for FILE in $INPUT_FILES;
do
    echo $FILE
    unzip -o $FILE
done

