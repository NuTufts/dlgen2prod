#!/bin/bash

# slurm submission script for making larmatch training data

#SBATCH --job-name=larmatch
#SBATCH --output=kps_batch_bnbnu.log
#SBATCH --mem-per-cpu=4000
#SBATCH --time=2-00:00:00
#SBATCH --array=0
##SBATCH --partition=wongjiradlab
##SBATCH --nodelist=p1cmp075
#SBATCH --partition ccgpu
#SBATCH --gres=gpu:a100:1

container=/cluster/tufts/wongjiradlab/larbys/larbys-containers/ubdl_depsonly_py3.6.11_u16.04_cu11_pytorch1.7.1.simg
RUN_DLANA_DIR=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/larmatch_scripts/
OFFSET=0
STRIDE=3

#SAMPLE_NAME=mcc9_v29e_dl_run3b_bnb_intrinsic_nue_LowE # 580 files
#SAMPLE_NAME=mcc9_v28_wctagger_extbnb # 19864 files
#SAMPLE_NAME=mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge # 15519
#SAMPLE_NAME=mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge_goodlist  # 2232
#SAMPLE_NAME=mcc9_v29e_dl_run3b_bnb_dlfilter_pi0 #849
SAMPLE_NAME=mcc9jan_run1_bnb5e19
INPUTFILE=/cluster/tufts/wongjiradlab/nutufts/dlgen2prod/run1inputlists/mcc9jan_run1_bnb5e19.list

#DLMERGED_STEM=dlfilter
DLMERGED_STEM=merged_dlreco

module load singularity
srun singularity exec --nv ${container} bash -c "cd ${RUN_DLANA_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE}"

