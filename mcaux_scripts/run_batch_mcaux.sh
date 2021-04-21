#!/bin/bash

OFFSET=$1
STRIDE=$2
SAMPLE_NAME=$3
MCWEIGHT_FILE=$4
INPUTLIST=$5
OUTPUT_DATADIR=$6
INPUTSTEM=larflowreco

# we assume we are already in the container
WORKDIR=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/mcaux_scripts/
UBDL_DIR=/cluster/tufts/wongjiradlab/twongj01/ubdl_py3/
OUTPUT_DIR=${OUTPUT_DATADIR}/v0/${SAMPLE_NAME}/mcaux/
OUTPUT_LOGDIR=${WORKDIR}/logdir/${SAMPLE_NAME}/

mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_LOGDIR

# WE WANT TO RUN MULTIPLE FILES PER JOB IN ORDER TO BE GRID EFFICIENT
start_jobid=$(( ${OFFSET} + ${SLURM_ARRAY_TASK_ID}*${STRIDE}  ))

cudadev="cpu"
echo "JOB ARRAYID: ${SLURM_ARRAY_TASK_ID} : DEVICE = ${cudadev}"

# LOCAL JOBDIR
local_jobdir=`printf /tmp/mcaux_jobid%d_%04d_${SAMPLE_NAME} ${SLURM_JOB_ID} ${SLURM_ARRAY_TASK_ID}`
#echo "local jobdir: $local_jobdir"
rm -rf $local_jobdir
mkdir -p $local_jobdir

# local log file
local_logfile=`printf mcaux_${SAMPLE_NAME}_jobid%d_%04d.log ${SLURM_JOB_ID} ${SLURM_ARRAY_TASK_ID}`
#echo "output logfile: "$local_logfile

#echo "SETUP CONTAINER/ENVIRONMENT"
cd ${UBDL_DIR}
alias python=python3
source /usr/local/root/root-6.22.06/bin/thisroot.sh
source setenv_py3.sh > /dev/null
source configure.sh > /dev/null
export PYTHONPATH=${LARMATCH_DIR}:${PYTHONPATH}
export PATH=${WORKDIR}:${PATH}

cd $local_jobdir

echo "STARTING TASK ARRAY ${SLURM_ARRAY_TASK_ID} for ${SAMPLE_NAME}" > ${local_logfile}

# run loop. 

for ((i=0;i<${STRIDE};i++)); do

    # CALC JOB ID
    jobid=$(( ${start_jobid} + ${i} ))
    echo "JOBID ${jobid}" >> ${local_logfile}

    # GET FILE PATH
    let lineno=${jobid}+1    
    inputfile=`sed -n ${lineno}p ${INPUTLIST} | awk '{ print $2 }'`
    let fileid=`sed -n ${lineno}p ${INPUTLIST} | awk '{ print $1 }'`


    if [ -n "$inputfile" ]; then    
	echo "inputfile path: $inputfile" >> ${local_logfile}

	baseinput=$(basename $inputfile )	
	echo "baseinput: $baseinput" >> ${local_logfile}

	mcauxname=`echo $baseinput | sed 's|larflowreco|mcaux|g' | sed 's|\_kpsrecomanagerana.root|.root|g'`
	echo "mcaux output name: $mcauxname"
	cp $inputfile  $baseinput
	python $WORKDIR/make_mc_cv_weight_tree.py $baseinput $MCWEIGHT_FILE $mcauxname
	let subdirid=${fileid}/100
	outdir=`printf $OUTPUT_DIR/%03d/ $subdirid`
	mkdir -p $outdir
	echo "copy mcaux file to $outdir"
	cp $mcauxname $outdir
    else
	echo "fileid empty"
    fi
done

cp $local_logfile ${OUTPUT_LOGDIR}/

# clean-up
cd /tmp
rm -r $local_jobdir
