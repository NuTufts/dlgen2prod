#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=lantern
#SBATCH --mem-per-cpu=6000
#SBATCH --time=2-0:00:00
#SBATCH --array=1-310
#SBATCH --cpus-per-task=2
#SBATCH --partition=batch
##SBATCH --partition=wongjiradlab
##SBATCH --partition=preempt
##SBATCH --exclude=i2cmp006,s1cmp001,s1cmp002,s1cmp003,p1cmp041,c1cmp003,c1cmp004
##SBATCH --gres=gpu:p100:3
#SBATCH --error=griderr_lantern_mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge_v3dev_reco_retune_sub00.%j.%N.err
#SBATCH --output=stdout_lantern_mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge_v3dev_reco_retune_sub00.%j.%N.log

container=/cluster/tufts/wongjiradlabnu/twongj01/gen2/photon_analysis/u20.04_cu111_torch1.9.0_minkowski.sif
BINDING=/cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab
RUN_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/
OFFSET=0
STRIDE=50

SAMPLE_NAME=mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge
INPUTSTEM=merged_dlreco
FILEIDLIST=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/runid_list_mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge_v3dev_reco_retune.txt
# total number of files: 15519
# with stride 50, 311 jobs


module load singularity/3.5.3
# GPU MODE
#singularity exec --nv ${container} bash -c "cd ${RUN_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"
# CPU MODE
cd /cluster/tufts/wongjiradlab/
cd /cluster/tufts/wongjiradlabnu/
singularity exec --bind ${BINDING} ${container} bash -c "cd ${RUN_DIR} && source run_batch_larmatchme_and_reco_mc.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTSTEM} ${FILEIDLIST}"

