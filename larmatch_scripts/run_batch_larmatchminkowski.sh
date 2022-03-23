#!/bin/bash

OFFSET=$1
STRIDE=$2
SAMPLE_NAME=$3
INPUTLIST=$4
INPUTSTEM=$5
FILEIDLIST=$6 # make this using gen_runlist.py

# we assume we are already in the container
export OMP_NUM_THREADS=4
WORKDIR=/cluster/tufts/wongjiradlabnu/nutufts/dlgen2prod/larmatch_scripts/larmatch_me/${SAMPLE_NAME}/
UBDL_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/ubdl/
LARMATCH_DIR=${UBDL_DIR}/larflow/larmatchnet/larmatch/
WEIGHTS_DIR=${LARMATCH_DIR}
WEIGHT_FILE=checkpoint.cc1gpu.78000th.tar
OUTPUT_DIR=/cluster/tufts/wongjiradlabnu/nutufts/data/larmatch/larmatch_me_v2/${SAMPLE_NAME}/
OUTPUT_LOGDIR=${WORKDIR}/logdir/${SAMPLE_NAME}
CONFIG_FILE=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/larmatch_scripts/config_larmatchme_deploycpu.yaml

mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_LOGDIR

# WE WANT TO RUN MULTIPLE FILES PER JOB IN ORDER TO BE GRID EFFICIENT
start_jobid=$(( ${OFFSET} + ${SLURM_ARRAY_TASK_ID}*${STRIDE}  ))

echo "JOB ARRAYID: ${SLURM_ARRAY_TASK_ID} -- CUDA DEVICES: ${CUDA_VISIBLE_DEVICES}"
#let ndevices=$(echo $CUDA_VISIBLE_DEVICES | sed 's|,| |g' | wc -w )
#let devnum=$(expr $SLURM_ARRAY_TASK_ID % $ndevices + 1)
#cudaid=$(echo $CUDA_VISIBLE_DEVICES | sed 's|,| |g' | awk '{print '"\$${devnum}"'}')
#cudadev=$(echo "cuda:${cudaid}")
echo "JOB ARRAYID: ${SLURM_ARRAY_TASK_ID} : CUDA DEVICE = ${cudadev}"

# LOCAL JOBDIR
local_jobdir=`printf /tmp/larmatch_me_jobid%04d_${SAMPLE_NAME}_${SLURM_JOB_ID} ${SLURM_ARRAY_TASK_ID}`
#echo "local jobdir: $local_jobdir"
rm -rf $local_jobdir
mkdir -p $local_jobdir

# local log file
local_logfile=`printf larmatch_me_${SAMPLE_NAME}_jobid%04d_${SLURM_JOB_ID}.log ${SLURM_ARRAY_TASK_ID}`
#echo "output logfile: "$local_logfile

#echo "SETUP CONTAINER/ENVIRONMENT"
cd ${UBDL_DIR}
alias python=python3
cd $UBDL_DIR
source setenv_py3.sh
source configure.sh
cd ${UBDL_DIR}/larflow/larmatchnet
source set_pythonpath.sh
export PYTHONPATH=${LARMATCH_DIR}:${PYTHONPATH}

cd $local_jobdir

echo "STARTING TASK ARRAY ${SLURM_ARRAY_TASK_ID} for ${SAMPLE_NAME}" > ${local_logfile}


# run a loop
for ((i=0;i<${STRIDE};i++)); do

    jobid=$(( ${start_jobid} + ${i} ))
    echo "JOBID ${jobid}" >> ${local_logfile}
  
    # GET INPUT FILENAME
    let lineno=${jobid}+1
    let fileid=`sed -n ${lineno}p ${FILEIDLIST} | awk '{print $1}'`
    let fileidno=${fileid}+1
    inputfile=`sed -n ${lineno}p ${FILEIDLIST} | awk '{print $2}'`
    baseinput=$(basename $inputfile )
    echo "inputfile path: $inputfile" >> ${local_logfile}
    echo "baseinput: $baseinput" >> ${local_logfile}

    # local outfile
    jobname=`printf jobid%04d ${jobid}`
    fileidstr=`printf fileid%04d ${fileid}`
    local_outfile=$(echo $baseinput  | sed 's|'"${INPUTSTEM}"'|larmatchme_'"${fileidstr}"'|g')
    local_basename=$(echo $baseinput | sed 's|'"${INPUTSTEM}"'|larmatchme_'"${fileidstr}"'|g' | sed 's|.root||g')
    echo "outfile : "$local_outfile >> ${local_logfile}
    scp $inputfile $baseinput
    
    CMD="python3 $LARMATCH_DIR/deploy_larmatchme.py --config-file ${CONFIG_FILE} --supera $baseinput --weights ${WEIGHTS_DIR}/${WEIGHT_FILE} --output $local_outfile --min-score 0.5 --adc-name wire --chstatus-name wire --device-name cpu -tb"
    echo $CMD >> ${local_logfile}
    $CMD >> ${local_logfile} 2>&1

    # subfolder dir
    let nsubdir=${fileid}/100
    subdir=`printf %03d ${nsubdir}`

    # copy to subdir in order to keep number of files per folder less than 100. better for file system.
    echo "COPY output to "${OUTPUT_DIR}/${subdir}/ >> ${local_logfile}
    mkdir -p $OUTPUT_DIR/${subdir}/
    cp ${local_basename}*larlite.root $OUTPUT_DIR/${subdir}/
    rm ${PWD}/${local_basename}*
    rm ${PWD}/${baseinput}
done

# copy log to logdir
cp $local_logfile $OUTPUT_LOGDIR/

# clean-up
cd /tmp
rm -r $local_jobdir
