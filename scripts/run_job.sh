#!/bin/bash -l

#----------------------------------------
#        load ENV variables
#----------------------------------------
CFGFILE="flee.cfg"
source $CFGFILE

#----------------------------------------
#     Cloning FLEE application
#----------------------------------------
git clone -b $REPO_BRANCH $FLEE_GITHUB_REPO




#----------------------------------------
#     install required packages
#----------------------------------------
bash scripts/install_packages.sh


#----------------------------------------
#     Download config files from CKAN
#----------------------------------------
bash scripts/ckan_downloader.sh



#----------------------------------------
#     Add FLEE to PYTHONPATH
#----------------------------------------
cat << EOF_CFGFILE >> $CFGFILE
export PYTHONPATH=$PWD/flee:\$PYTHONPATH
EOF_CFGFILE

source $CFGFILE


#----------------------------------------------
#     Install python required packages by FLEE
#----------------------------------------------
pip3 install --user -r $PWD/flee/requirements.txt


#----------------------------------------
#     RUN job
#----------------------------------------
LOG_RUN_JOB='run_job.log'
echo "PYTHONPATH = " $PYTHONPATH > $LOG_RUN_JOB

cd $CONFIG_NAME

# covert to lowercase
MSCALE=$(echo "$MSCALE" | tr "[:upper:]" "[:lower:]")
PARALLEL_MODE=$(echo "$PARALLEL_MODE" | tr "[:upper:]" "[:lower:]")
MSCALE_COUPLING_TYPE=$(echo "$MSCALE_COUPLING_TYPE" | tr "[:upper:]" "[:lower:]")




if [ "$MSCALE" == "false" ]
then

    if [ "$PARALLEL_MODE" == "true" ]
    then
        echo "PARALLEL_MODE is enabled . . ." | tee -a "$LOG_RUN_JOB"
        mpirun -n $NUMBER_OF_CORES_PER_NODE python3 run_par.py input_csv source_data $SIMULATION_PERIOD simsetting.csv > out.csv
    else
        echo "PARALLEL_MODE is disabled . . ." | tee -a "$LOG_RUN_JOB"
        python3 run.py input_csv source_data $SIMULATION_PERIOD simsetting.csv > out.csv
    fi

else
    pip3 install --user -U muscle3
    if [ "$MSCALE_COUPLING_TYPE" == "file" ]
    then
        echo "Run file-mode multi-scale simulation . . ." | tee -a "$LOG_RUN_JOB"
        bash run_file_coupling.sh --NUM_INSTANCES $MSCALE_NUM_INSTANCES --cores $MSCALE_CORES_PER_INSTANCE --INPUT_DATA_DIR $MSCALE_INPUT_DATA_DIR --LOG_EXCHANGE_DATA $MSCALE_LOG_EXCHANGE_DATA --WEATHER_COUPLING $MSCALE_WEATHER_COUPLING
    fi

fi

cd ..


#----------------------------------------
#     Zip output results 
#----------------------------------------

result_file_name=$CONFIG_NAME'-results-'$ID'-'$(whoami)

cat << EOF_CFGFILE >> $CFGFILE
RESULT_FILE_NAME=$result_file_name
EOF_CFGFILE

source flee.cfg

env > env.log
/usr/bin/env > env2.log

zip -r $result_file_name *.err *.out *.script *.yaml $CONFIG_NAME



#----------------------------------------
#      Upload results to CKAN
#----------------------------------------
bash scripts/ckan_uploader.sh