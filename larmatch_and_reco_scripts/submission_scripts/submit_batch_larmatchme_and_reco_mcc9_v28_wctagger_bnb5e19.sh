#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=bnb5e19_lantern
#SBATCH --output=stdout_mcc9_v28_wctagger_bnb5e19_sub02.txt
##SBATCH --mem-per-cpu=8000
#SBATCH --mem-per-cpu=4000
#SBATCH --time=2-00:00:00
#SBATCH --array=0-173
#SBATCH --cpus-per-task=4
#SBATCH --partition=batch
##SBATCH --partition=wongjiradlab
##SBATCH --partition=preempt
##SBATCH --exclude=i2cmp006,s1cmp001,s1cmp002,s1cmp003,p1cmp041,c1cmp003,c1cmp004
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:a100:1
##SBATCH --nodelist=ccgpu01
#SBATCH --error=griderr_mcc9_v28_wctagger_bnb5e19.%j.%N.test.err

container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/singularity_minkowski_u20.04.cu111.torch1.9.0_jupyter_xgboost.sif
RUN_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/
OFFSET=0
STRIDE=10

# total files: 11688
SAMPLE_NAME=mcc9_v28_wctagger_bnb5e19
INPUTSTEM=merged_dlreco
#FILEIDLIST=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/larmatch_runlist_mcc9_v28_wctagger_bnb5e19_v3dev_lm_showerkp_retrain.txt
FILEIDLIST=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/runid_list_mcc9_v28_wctagger_bnb5e19.txt

module load singularity/3.5.3
# GPU MODE
#singularity exec --nv ${container} bash -c "cd ${RUN_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"
# CPU MODE
cd /cluster/tufts/wongjiradlab/
cd /cluster/tufts/wongjiradlabnu/
singularity exec --bind /cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab ${container} bash -c "cd ${RUN_DIR} && source run_batch_larmatchme_and_reco_data.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTSTEM} ${FILEIDLIST}"

