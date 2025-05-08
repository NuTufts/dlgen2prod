#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=lantern
#SBATCH --mem-per-cpu=6000
#SBATCH --time=8:00:00
#SBATCH --array=0
#SBATCH --cpus-per-task=2
##SBATCH --partition=batch
#SBATCH --partition=wongjiradlab
##SBATCH --exclude=i2cmp006,s1cmp001,s1cmp002,s1cmp003,p1cmp041,c1cmp003,c1cmp004
##SBATCH --gres=gpu:p100:3
#SBATCH --error=griderr_lantern_prodntuple.%j.%N.log
#SBATCH --output=stdout_lantern_prodntuple.%j.%N.log

container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/lantern_v2_me_06_03_prod/
BINDING=/cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab
SCRIPT_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/run_prod_ntuple/
WEIGHTDIR=/cluster/tufts/wongjiradlabnu/mrosen25/gen2ntuple/event_weighting/

# weight files in /cluster/tufts/wongjiradlabnu/mrosen25/gen2ntuple/event_weighting/
# weights_forCV_v48_Sep24_bnb_nu_run1.pkl
# weights_forCV_v48_Sep24_bnb_nu_run2.pkl
# weights_forCV_v48_Sep24_bnb_nu_run3.pkl
# weights_forCV_v48_Sep24_dirt_nu_run1.pkl
# weights_forCV_v48_Sep24_dirt_nu_run3.pkl
# weights_forCV_v48_Sep24_intrinsic_nue_run1.pkl
# weights_forCV_v48_Sep24_intrinsic_nue_run2.pkl
# weights_forCV_v48_Sep24_intrinsic_nue_run3.pkl

# ARGS
DLGEN2PROD_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/
SAMPLE_NAME=mcc9_v28_wctagger_bnboverlay
RECO_VER=v3dev_lm_showerkp_retraining
GOOD_RECO_LIST=${DLGEN2PROD_DIR}/larmatch_and_reco_scripts/goodoutput_lists/goodoutput_list_mcc9_v28_wctagger_bnboverlay_v3dev_lm_showerkp_retraining.txt
NFILES=10
WEIGHTFILE=${WEIGHTDIR}/weights_forCV_v48_Sep24_bnb_nu_run1.pkl
OUTDIR=${SCRIPT_DIR}/outdir_${SAMPLE_NAME}_${RECO_VER}/

module load singularity/3.5.3
singularity exec -B ${BINDING} ${container} bash -c "cd ${SCRIPT_DIR} && ./run_prodcontainer_gen2ntuple.sh ${DLGEN2PROD_DIR} ${SAMPLE_NAME} ${RECO_VER} ${GOOD_RECO_LIST} ${NFILES} ${WEIGHTFILE} ${OUTDIR}"

