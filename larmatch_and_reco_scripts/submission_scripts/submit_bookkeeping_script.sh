#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=bookkeep
#SBATCH --mem-per-cpu=4000
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=2
#SBATCH --partition=wongjiradlab
##SBATCH --gres=gpu:p100:3
#SBATCH --output=logs/stdout_bookkeep_mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge.txt
#SBATCH --error=logs/griderr_bookkeep_mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge.txt

container=/cluster/tufts/wongjiradlabnu/twongj01/gen2/photon_analysis/u20.04_cu111_torch1.9.0_minkowski.sif
RUN_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/
BINDING=/cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab
UBDL=/cluster/tufts/wongjiradlabnu/twongj01/gen2/photon_analysis/ubdl/
#SAMPLENAME=mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge
SAMPLENAME=mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge

module load singularity/3.5.3
cd /cluster/tufts/wongjiradlab/
cd /cluster/tufts/wongjiradlabnu/
cd ${RUN_DIR}
singularity exec --bind ${BINDING} ${container} bash -c "cd ${UBDL} && source setenv_py3_container.sh && source configure_container.sh && cd ${RUN_DIR} && python3 make_booking_file.py ${SAMPLENAME}"

