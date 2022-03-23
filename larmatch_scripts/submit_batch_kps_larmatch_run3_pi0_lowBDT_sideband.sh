#!/bin/bash

# slurm submission script for making larmatch training data

#SBATCH --job-name=larmatch
#SBATCH --output=larmatch_run3_pi0.log
#SBATCH --mem-per-cpu=2000
#SBATCH --time=1-00:00:00
#SBATCH --array=0-110
#SBATCH --cpus-per-task=4
##SBATCH --partition=batch
#SBATCH --partition=preempt
##SBATCH --partition=wongjiradlab
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:a100:1
##SBATCH --nodelist=ccgpu01

container=/cluster/tufts/wongjiradlab/larbys/larbys-containers/ubdl_depsonly_py3.6.11_u16.04_cu11_pytorch1.7.1.simg
RUN_DLANA_DIR=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/larmatch_scripts/
OFFSET=0
STRIDE=10

SAMPLE_NAME=mcc9_v29e_dl_run3_pi0_lowBDT_sideband
INPUTFILE=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/run3inputlists/mcc9_v29e_dl_run3_pi0_lowBDT_sideband.list
INPUTSTEM=dlfilter_allsamples1
FILEIDLIST=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/larmatch_scripts/larmatch_runlist_mcc9_v29e_dl_run3_pi0_lowBDT_sideband.txt

module load singularity
# GPU MODE
#srun singularity exec --nv ${container} bash -c "cd ${RUN_DLANA_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM}"
# CPU MODE
srun singularity exec ${container} bash -c "cd ${RUN_DLANA_DIR} && source run_batch_kps_larmatch_cpu.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"

