#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=lantern
##SBATCH --mem-per-cpu=8000
#SBATCH --mem-per-cpu=6000
#SBATCH --time=3-0:00:00
#SBATCH --array=0,106
#SBATCH --cpus-per-task=4
##SBATCH --partition=batch
#SBATCH --partition=wongjiradlab
##SBATCH --partition=preempt
##SBATCH --exclude=i2cmp006,s1cmp001,s1cmp002,s1cmp003,p1cmp041,c1cmp003,c1cmp004
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:a100:1
##SBATCH --nodelist=ccgpu01
#SBATCH --output=stdout_mcc9_v29e_dl_run1_C1_extbnb_resub00.%j.%N.log
#SBATCH --error=griderr_mcc9_v29e_dl_run1_C1_extbnb_resub00.%j.%N.err

container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/singularity_minkowski_u20.04.cu111.torch1.9.0_jupyter_xgboost.sif
#container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/lantern_v2_me_06_03_prod/
BINDING=/cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab
RUN_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/
OFFSET=0
STRIDE=10

SAMPLE_NAME=mcc9_v29e_dl_run1_C1_extbnb
INPUTSTEM=merged_dlreco
FILEIDLIST=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/runid_list_mcc9_v29e_dl_run1_C1_extbnb_v3dev_lm_showerkp_retraining.txt
# num files in inputlist: 27602
# with 10 files per job, thats 2761 jobs to complete!

module load singularity/3.5.3
# GPU MODE
#singularity exec --nv ${container} bash -c "cd ${RUN_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"
# CPU MODE
singularity exec --bind ${BINDING} ${container} bash -c "cd ${RUN_DIR} && source run_batch_larmatchme_and_reco_data.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTSTEM} ${FILEIDLIST}"

