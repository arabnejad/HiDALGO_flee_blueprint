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


#----------------------------------------
#     RUN job
#----------------------------------------
LOG_RUN_JOB='run_job.log'
echo "PYTHONPATH = " $PYTHONPATH > $LOG_RUN_JOB

cd $CONFIG_NAME

if [[ "${PARALLEL_MODE^^}" == "TRUE" ]]; then
    echo "PARALLEL_MODE is enabled . . ." | tee -a "$LOG_RUN_JOB"    
    mpirun -n 28 python3 run_par.py input_csv source_data $SIMULATION_PERIOD simsetting.csv > out.csv
else
    echo "PARALLEL_MODE is disabled . . ." | tee -a "$LOG_RUN_JOB"
    python3 run.py input_csv source_data $SIMULATION_PERIOD simsetting.csv > out.csv
fi

cd ..


#----------------------------------------
#     Zip output results 
#----------------------------------------

result_file_name=$CONFIG_NAME'-results['$ID'][by '$(whoami)']'

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