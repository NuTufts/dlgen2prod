#!/bin/bash

OFFSET=$1
STRIDE=$2
SAMPLE_NAME=$3
INPUTLIST=$4
INPUTSTEM=$5
FILEIDLIST=$6

# we assume we are already in the container

WORKDIR=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/larmatch_scripts/
UBDL_DIR=/cluster/tufts/wongjiradlab/twongj01/ubdl_py3
LARMATCH_DIR=${UBDL_DIR}/larflow/larmatchnet/
WEIGHTS_DIR=/cluster/tufts/wongjiradlab/twongj01/ubdl/larflow/larmatchnet/grid_deploy_scripts/larmatch_kps_weights/
WEIGHT_FILE=checkpoint.1974000th.tar
OUTPUT_DIR=/cluster/tufts/wongjiradlab/nutufts/data/v0/${SAMPLE_NAME}/larmatch/
OUTPUT_LOGDIR=${WORKDIR}/logdir/${SAMPLE_NAME}

mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_LOGDIR

# WE WANT TO RUN MULTIPLE FILES PER JOB IN ORDER TO BE GRID EFFICIENT
start_jobid=$(( ${OFFSET} + ${SLURM_ARRAY_TASK_ID}*${STRIDE}  ))

cudadev="cpu"
echo "JOB ARRAYID: ${SLURM_ARRAY_TASK_ID} : DEVICE = ${cudadev}"

# LOCAL JOBDIR
local_jobdir=`printf /tmp/larmatch_kps_jobid%d_%04d_${SAMPLE_NAME} ${SLURM_JOB_ID} ${SLURM_ARRAY_TASK_ID}`
#echo "local jobdir: $local_jobdir"
rm -rf $local_jobdir
mkdir -p $local_jobdir

# local log file
local_logfile=`printf larmatch_kps_${SAMPLE_NAME}_jobid%d_%04d.log ${SLURM_JOB_ID} ${SLURM_ARRAY_TASK_ID}`
#echo "output logfile: "$local_logfile

#echo "SETUP CONTAINER/ENVIRONMENT"
cd ${UBDL_DIR}
alias python=python3
source /usr/local/root/root-6.22.06/bin/thisroot.sh
source setenv_py3.sh > /dev/null
source configure.sh > /dev/null
export PYTHONPATH=${LARMATCH_DIR}:${PYTHONPATH}
export OMP_NUM_THREADS=4

cd $local_jobdir

echo "STARTING TASK ARRAY ${SLURM_ARRAY_TASK_ID} for ${SAMPLE_NAME}" > ${local_logfile}


# run a loop
for ((i=0;i<${STRIDE};i++)); do

    # CALC JOB ID
    jobid=$(( ${start_jobid} + ${i} ))
    echo "JOBID ${jobid}" >> ${local_logfile}

    # GET FILE ID
    let lineno=${jobid}+1    
    let fileid=`sed -n ${lineno}p ${FILEIDLIST}`
  
    # GET INPUT FILENAME
    let filelineno=${fileid}+1
    inputfile=`sed -n ${filelineno}p ${INPUTLIST}`
    baseinput=$(basename $inputfile )
    echo "inputfile path: $inputfile" >> ${local_logfile}
    echo "baseinput: $baseinput" >> ${local_logfile}

    echo "JOBID ${jobid} running FILEID ${fileid} with file: ${baseinput}"

    # local outfile
    jobname=`printf jobid%04d ${jobid}`
    fileidname=`printf fileid%04d ${fileid}`
    local_outfile=$(echo $baseinput  | sed 's|'"${INPUTSTEM}"'|larmatch_kps_'"${fileidname}"'|g')
    local_basename=$(echo $baseinput | sed 's|'"${INPUTSTEM}"'|larmatch_kps_'"${fileidname}"'|g' | sed 's|.root||g')
    echo "outfile : "$local_outfile >> ${local_logfile}
    scp $inputfile $baseinput
    
    CMD="python $LARMATCH_DIR/deploy_kps_larmatch.py --supera $baseinput --weights ${WEIGHTS_DIR}/${WEIGHT_FILE} --output $local_outfile --min-score 0.5 --adc-name wire --chstatus-name wire --device-name $cudadev --use-unet --use-skip-limit 1000000 -tb"
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
