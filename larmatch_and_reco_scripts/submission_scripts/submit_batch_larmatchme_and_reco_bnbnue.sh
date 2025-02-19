#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=bnbnue-fullReco
#SBATCH --output=larmatchme_larflowreco_mcc9_run3_bnbnue_sub2.log
#SBATCH --mem-per-cpu=10000
##SBATCH --mem-per-cpu=6000
#SBATCH --time=48:00:00
#SBATCH --array=0-1
#SBATCH --cpus-per-task=4
##SBATCH --partition=batch
#SBATCH --partition=wongjiradlab
##SBATCH --partition=preempt
#SBATCH --exclude=i2cmp006,s1cmp001,s1cmp002,s1cmp003,p1cmp041,c1cmp003,c1cmp004
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:a100:1
##SBATCH --nodelist=ccgpu01
#SBATCH --error=griderr_larmatcheme_larflowreco_mcc9_run3_bnbnue_sub2.%j.%N.err

container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/singularity_minkowskiengine_u20.04.cu111.torch1.9.0_comput8.sif
RUN_DIR=/cluster/tufts/wongjiradlabnu/nutufts/dlgen2prod/larmatch_and_reco_scripts/
OFFSET=0
STRIDE=5

SAMPLE_NAME=mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge
INPUTSTEM=merged_dlreco
FILEIDLIST=/cluster/tufts/wongjiradlabnu/nutufts/dlgen2prod/larmatch_and_reco_scripts/larmatch_runlist_mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge.txt
# num files in inputlist: 2232

module load singularity/3.5.3
# GPU MODE
#singularity exec --nv ${container} bash -c "cd ${RUN_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"
# CPU MODE
cd /cluster/tufts/wongjiradlab/
cd /cluster/tufts/wongjiradlabnu/
singularity exec --bind /cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab ${container} bash -c "cd ${RUN_DIR} && source run_batch_larmatchme_and_reco_mc.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTSTEM} ${FILEIDLIST}"

