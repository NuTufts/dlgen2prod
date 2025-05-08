#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=r1bnbnue_lantern
#SBATCH --output=stdout_mcc9_v40a_dl_run1_bnb_intrinsic_nue_overlay_CV_sub00.log
##SBATCH --mem-per-cpu=8000
#SBATCH --mem-per-cpu=6000
#SBATCH --time=3-0:00:00
#SBATCH --array=0
#SBATCH --cpus-per-task=4
##SBATCH --partition=batch
#SBATCH --partition=wongjiradlab
##SBATCH --partition=preempt
##SBATCH --exclude=i2cmp006,s1cmp001,s1cmp002,s1cmp003,p1cmp041,c1cmp003,c1cmp004
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:a100:1
##SBATCH --nodelist=ccgpu01
#SBATCH --error=griderr_lantern_mcc9_v40a_dl_run1_bnb_intrinsic_nue_overlay_CV_sub00.%j.%N.err

#container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/singularity_minkowski_u20.04.cu111.torch1.9.0_jupyter_xgboost.sif
container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/lantern_v2_me_06_03_prod/
RUN_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/
OFFSET=0
STRIDE=10

SAMPLE_NAME=mcc9_v40a_dl_run1_bnb_intrinsic_nue_overlay_CV
INPUTSTEM=merged_dlreco
FILEIDLIST=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/runid_list_mcc9_v40a_dl_run1_bnb_intrinsic_nue_overlay_CV_v2_me_06_03_prodtest.txt
# num files in inputlist: 10007
# with 10 files per job, thats 1001 jobs to complete

module load singularity/3.5.3
# GPU MODE
#singularity exec --nv ${container} bash -c "cd ${RUN_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"
# CPU MODE
cd /cluster/tufts/wongjiradlab/
cd /cluster/tufts/wongjiradlabnu/
singularity exec --bind /cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab ${container} bash -c "cd ${RUN_DIR} && source run_batch_larmatchme_and_reco_mc.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTSTEM} ${FILEIDLIST}"

