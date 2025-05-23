#!/bin/bash

JOBSTARTDATE=$(date)

OFFSET=$1
STRIDE=$2
SAMPLE_NAME=$3
INPUTSTEM=$4
FILEIDLIST=$5 # make this using check_files.py

# we assume we are already in the container
export OMP_NUM_THREADS=16
WORKDIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/

# Parameters for production version reco
#RECOVER=v2_me_06_03_prodtest
#UBDL_DIR=/cluster/home/ubdl/
#LARMATCH_DIR=${UBDL_DIR}/larflow/larmatchnet/larmatch/
#WEIGHTS_DIR=${LARMATCH_DIR}
#WEIGHT_FILE=larmatch_ckpt78k.pt
#CONFIG_FILE=/cluster/home/lantern_scripts/config_larmatchme_deploycpu.yaml
#LARMATCHME_SCRIPT=${LARMATCH_DIR}/deploy_larmatchme.py

# Parameters for shower-keypoint update version
#RECOVER=v3dev_lm_showerkp_retraining
#UBDL_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/photon_analysis/ubdl/
#LARMATCH_DIR=${UBDL_DIR}/larflow/larmatchnet/larmatch/
#WEIGHTS_DIR=${LARMATCH_DIR}/checkpoints/sparkling-sunset-78/
#WEIGHT_FILE=checkpoint.44000th.tar
#CONFIG_FILE=${WORKDIR}/config_larmatchme_deploycpu.yaml
#LARMATCHME_SCRIPT=${LARMATCH_DIR}/deploy_larmatchme_v2.py

# Parameters for shower-keypoint retraining and reco-retuning
RECOVER=v3dev_reco_retune
UBDL_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/photon_analysis/ubdl/
LARMATCH_DIR=${UBDL_DIR}/larflow/larmatchnet/larmatch/
WEIGHTS_DIR=${LARMATCH_DIR}/checkpoints/easy-wave-79/
WEIGHT_FILE=checkpoint.93000th.tar
CONFIG_FILE=${WORKDIR}/config_larmatchme_deploycpu.yaml
LARMATCHME_SCRIPT=${LARMATCH_DIR}/deploy_larmatchme_v2.py

# More common parameters dependent on version-specific variables
RECO_TEST_DIR=${UBDL_DIR}/larflow/larflow/Reco/test/
OUTPUT_DIR=/cluster/tufts/wongjiradlabnu/nutufts/data/${RECOVER}/${SAMPLE_NAME}/larflowreco/ana/
OUTPUT_LOGDIR=${WORKDIR}/logdir/${RECOVER}/${SAMPLE_NAME}

mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_LOGDIR

# WE WANT TO RUN MULTIPLE FILES PER JOB IN ORDER TO BE GRID EFFICIENT
start_jobid=$(( ${OFFSET} + ${SLURM_ARRAY_TASK_ID}*${STRIDE}  ))

#echo "JOB ARRAYID: ${SLURM_ARRAY_TASK_ID} -- CUDA DEVICES: ${CUDA_VISIBLE_DEVICES}"
#let ndevices=$(echo $CUDA_VISIBLE_DEVICES | sed 's|,| |g' | wc -w )
#let devnum=$(expr $SLURM_ARRAY_TASK_ID % $ndevices + 1)
#cudaid=$(echo $CUDA_VISIBLE_DEVICES | sed 's|,| |g' | awk '{print '"\$${devnum}"'}')
#cudadev=$(echo "cuda:${cudaid}")
cudadev="cpu"
echo "JOB ARRAYID: ${SLURM_ARRAY_TASK_ID} : CUDA DEVICE = ${cudadev} : NODE = ${SLURMD_NODENAME}"

# LOCAL JOBDIR
local_jobdir=`printf /tmp/larmatchme_larflowreco_jobid%04d_${SAMPLE_NAME}_${SLURM_JOB_ID} ${SLURM_ARRAY_TASK_ID}`
#echo "local jobdir: $local_jobdir"
rm -rf $local_jobdir
mkdir -p $local_jobdir

# local log file
local_logfile=`printf larmatchme_larflowreco_${SAMPLE_NAME}_jobid%04d_${SLURM_JOB_ID}.log ${SLURM_ARRAY_TASK_ID}`
#echo "output logfile: "$local_logfile

#echo "SETUP CONTAINER/ENVIRONMENT"
cd ${UBDL_DIR}
alias python=python3
cd $UBDL_DIR
source setenv_py3_container.sh
source configure_container.sh
cd ${UBDL_DIR}/larflow/larmatchnet
source set_pythonpath.sh
export PYTHONPATH=${LARMATCH_DIR}:${PYTHONPATH}

cd $local_jobdir

echo "STARTING TASK ARRAY ${SLURM_ARRAY_TASK_ID} for ${SAMPLE_NAME}" > ${local_logfile}
echo "running on node $SLURMD_NODENAME" >> ${local_logfile}

ls /cluster/tufts/wongjiradlab/
ls /cluster/tufts/wongjiradlabnu/

# run a loop
for ((i=0;i<${STRIDE};i++)); do

    jobid=$(( ${start_jobid} + ${i} ))
    echo "JOBID ${jobid}" >> ${local_logfile}
  
    # GET INPUT FILENAME
    let lineno=${jobid}+1
    let fileid=`sed -n ${lineno}p ${FILEIDLIST} | awk '{print $1}'`
    inputfile=`sed -n ${lineno}p ${FILEIDLIST} | awk '{print $2}'`
    baseinput=$(basename $inputfile )
    echo "inputfile path: $inputfile" >> ${local_logfile}
    echo "baseinput: $baseinput" >> ${local_logfile}

    echo "JOBID ${jobid} running FILEID ${fileid} with file: ${baseinput}"

    # local outfile
    jobname=`printf jobid%04d ${jobid}`
    fileidstr=`printf fileid%04d ${fileid}`
    lm_outfile=$(echo $baseinput  | sed 's|'"${INPUTSTEM}"'|larmatchme_'"${fileidstr}"'|g')
    lm_basename=$(echo $baseinput | sed 's|'"${INPUTSTEM}"'|larmatchme_'"${fileidstr}"'|g' | sed 's|.root||g')
    baselm=$(echo $baseinput | sed 's|'"${INPUTSTEM}"'|larmatchme_'"${fileidstr}"'|g' | sed 's|.root|_larlite.root|g')
    reco_outfile=$(echo $baseinput  | sed 's|'"${INPUTSTEM}"'|larflowreco_'"${fileidstr}"'|g')
    reco_basename=$(echo $baseinput | sed 's|'"${INPUTSTEM}"'|larflowreco_'"${fileidstr}"'|g' | sed 's|.root||g')
    echo "larmatch outfile : "$lm_outfile >> ${local_logfile}
    echo "reco outfile : "$reco_outfile >> ${local_logfile}
    scp $inputfile $baseinput

    # larmatch v1
    #CMD="python3 $LARMATCH_DIR/deploy_larmatchme.py --config-file ${CONFIG_FILE} --supera $baseinput --weights ${WEIGHTS_DIR}/${WEIGHT_FILE} --output $lm_outfile --min-score 0.3 --adc-name wire --chstatus-name wire --device-name cpu -tb"
    CMD="python3 $LARMATCH_DIR/deploy_larmatchme_v2.py --config-file ${CONFIG_FILE} --input-larcv $baseinput --input-larlite ${baseinput} --weights ${WEIGHTS_DIR}/${WEIGHT_FILE} --output ${baselm} --min-score 0.3 --adc-name wire --device-name cpu --use-skip-limit"
    echo $CMD >> ${local_logfile}
    $CMD >> ${local_logfile} 2>&1

    CMD="python $RECO_TEST_DIR/run_kpsrecoman.py --input-dlmerged ${baseinput} --input-larflow ${baselm} --output ${reco_outfile} -tb --products min --save-all-keypoints --loglevel 3"
    echo $CMD >> ${local_logfile}
    $CMD >> ${local_logfile}

    # subfolder dir
    let nsubdir=${fileid}/100
    subdir=`printf %03d ${nsubdir}`

    # copy to subdir in order to keep number of files per folder less than 100. better for file system.
    echo "COPY output to "${OUTPUT_DIR}/${subdir}/ >> ${local_logfile}
    mkdir -p $OUTPUT_DIR/${subdir}/
    #cp ${lm_basename}*larlite.root $OUTPUT_DIR/${subdir}/
    cp ${reco_basename}*ana.root $OUTPUT_DIR/${subdir}/
    rm ${PWD}/${lm_basename}*
    rm ${PWD}/${reco_basename}*
    rm ${PWD}/${baseinput}
done

JOBENDDATE=$(date)

echo "Job began at $JOBSTARTDATE" >> $local_logfile
echo "Job ended at $JOBENDDATE" >> $local_logfile

# copy log to logdir
cp $local_logfile $OUTPUT_LOGDIR/

# clean-up
cd /tmp
rm -r $local_jobdir

