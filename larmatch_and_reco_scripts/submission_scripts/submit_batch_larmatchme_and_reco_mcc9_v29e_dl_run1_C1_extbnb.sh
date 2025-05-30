#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=lantern
#SBATCH --mem-per-cpu=8000
#SBATCH --time=3-0:00:00
#SBATCH --array=0-193
#SBATCH --cpus-per-task=2
#SBATCH --partition=batch
##SBATCH --partition=wongjiradlab
##SBATCH --partition=preempt
##SBATCH --exclude=i2cmp006,s1cmp001,s1cmp002,s1cmp003,p1cmp041,c1cmp003,c1cmp004
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:a100:1
##SBATCH --nodelist=ccgpu01
#SBATCH --output=stdout_mcc9_v29e_dl_run1_C1_extbnb_v3dev_reco_retune_resub02.%j.%N.log
#SBATCH --error=griderr_mcc9_v29e_dl_run1_C1_extbnb_v3dev_reco_retune_resub02.%j.%N.log

#container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/lantern_v2_me_06_03_prod/
container=/cluster/tufts/wongjiradlabnu/twongj01/gen2/photon_analysis/u20.04_cu111_torch1.9.0_minkowski.sif
BINDING=/cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab,/cluster/home/twongj01:/cluster/home/twongj01
RUN_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/
OFFSET=0
STRIDE=100

INPUTSTEM=merged_dlreco
FILEIDLIST=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/runid_list_mcc9_v29e_dl_run1_C1_extbnb_v3dev_reco_retune_mod20250524_164618.txt
# num files in inputlist: 27602
# with 10 files per job, thats 2761 jobs to complete!

SAMPLE_NAME=mcc9_v29e_dl_run1_C1_extbnb
RECOVER=v3dev_reco_retune

module load singularity/3.5.3
# GPU MODE
#singularity exec --nv ${container} bash -c "cd ${RUN_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"
# CPU MODE
singularity exec --bind ${BINDING} ${container} bash -c "cd ${RUN_DIR} && source run_batch_larmatchme_and_reco_data.sh $OFFSET $STRIDE ${SAMPLE_NAME} ${INPUTSTEM} ${FILEIDLIST}"

