#!/bin/bash

# slurm submission script for making larmatch training data

#SBATCH --job-name=lfreco
#SBATCH --output=larflow_reco_intrinsics_sub0.log
#SBATCH --mem-per-cpu=4000
#SBATCH --time=4:00:00
#SBATCH --array=0-99
#SBATCH --cpus-per-task=1
##SBATCH --partition=batch
#SBATCH --partition=preempt
##SBATCH --partition=wongjiradlab
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:t4:1
##SBATCH --nodelist=ccgpu01
#SBATCH --error=gridlog/griderr_larmatcheme_deploy_mcc9_run3_intrinsics_nue_sub0.%j.%N.err

container=/cluster/tufts/wongjiradlabnu/larbys/larbys-container/singularity_minkowskiengine_u20.04.cu111.torch1.9.0_comput8.sif
RUN_DLANA_DIR=/cluster/tufts/wongjiradlabnu/nutufts/dlgen2prod/reco_scripts/
OFFSET=1
STRIDE=10

SAMPLE_NAME=mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge
INPUTFILE=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/maskrcnn_input_filelists/mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge_MRCNN_INPUTS_LIST.txt
INPUTSTEM=merged_dlreco
FILEIDLIST=${RUN_DLANA_DIR}/runlist_reco_mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge.txt

module load singularity/3.5.3

# CPU MODE
singularity exec --bind /cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab ${container} bash -c "cd ${RUN_DLANA_DIR} && source run_batch_larflowreco_mc_cpu.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"

