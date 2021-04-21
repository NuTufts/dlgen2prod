#!/bin/bash

# slurm submission script for making larmatch training data

#SBATCH --job-name=getweights
#SBATCH --output=log_mcaux_intrinsics_sub0.txt
#SBATCH --mem-per-cpu=2000
#SBATCH --time=1:00:00
#SBATCH --array=0-99
#SBATCH --cpus-per-task=1
##SBATCH --partition=batch
##SBATCH --partition=preempt
#SBATCH --partition=wongjiradlab
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:t4:1
##SBATCH --nodelist=ccgpu01

container=/cluster/tufts/wongjiradlab/larbys/larbys-containers/ubdl_depsonly_py3.6.11_u16.04_cu11_pytorch1.7.1.simg
RUN_DLANA_DIR=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/mcaux_scripts
OFFSET=0
STRIDE=22

SAMPLE_NAME=mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge
MCWEIGHT_DIR=/cluster/tufts/wongjiradlab/nutufts/data/weights/forCV_v48_Sep24/
MCWEIGHT_FILE=weights_forCV_v48_Sep24_intrinsic_nue_run3.root
MCWEIGHT_PATH=$MCWEIGHT_DIR/$MCWEIGHT_FILE
INPUTFILE=${RUN_DLANA_DIR}/runlist_dlgen2filter_mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge.txt
OUTDIR=/cluster/tufts/wongjiradlab/nutufts/data/

module load singularity

# CPU MODE
srun singularity exec ${container} bash -c "cd ${RUN_DLANA_DIR} && source run_batch_mcaux.sh $OFFSET $STRIDE $SAMPLE_NAME $MCWEIGHT_PATH $INPUTFILE $OUTDIR"

