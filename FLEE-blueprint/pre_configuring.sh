#!/bin/bash -l

LOGFILE="pre_configuring_log.txt"


cat << EOF_LOGFILE > $LOGFILE
log pre_configuring.sh ...

flee_github_repo = $1
branch =  $2
config_name = $3
simulation_period = $4
parallel_mode = $5
jobmanager_type = $6
nnodes = $7
ncorespernode = $8
ckanrepo = $9
ckanapikey = ${10}
inputconfigtags = ${11}
mscale = ${12}
mscale_num_workers = ${13}
mscale_cores_per_worker = ${14}
mscale_input_data_dir = ${15}
mscale_log_exchange_data = ${16}
mscale_coupling_type = ${17}
mscale_weather_coupling = ${18}
EOF_LOGFILE


CFGFILE="flee.cfg"
id=`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1`
cat << EOF_CFGFILE > $CFGFILE
FLEE_GITHUB_REPO=$1
REPO_BRANCH=$2
CONFIG_NAME=$3
SIMULATION_PERIOD=$4
PARALLEL_MODE=$5
JOBMANAGER=$6
NUMBER_OF_NODES=$7
NUMBER_OF_CORES_PER_NODE=$8
CKANREPO=$9
CKANAPIKEY=${10}
INPUT_CONFIG_TAGS=${11}
MSCALE=${11}
MSCALE_NUM_WORKERS=${13}
MSCALE_CORES_PER_WORKER=${14}
MSCALE_INPUT_DATA_DIR=${15}
MSCALE_LOG_EXCHANGE_DATA=${16}
MSCALE_COUPLING_TYPE=${17}
MSCALE_WEATHER_COUPLING=${18}
ID=$id
CURDIR=$PWD
EOF_CFGFILE

source $CFGFILE

#----------------------------------------
#    Cloning HiDALGO flee blueprint repo
#----------------------------------------
git clone https://github.com/arabnejad/HiDALGO_flee_blueprint.git

mv HiDALGO_flee_blueprint/scripts .
rm -rf HiDALGO_flee_blueprint



