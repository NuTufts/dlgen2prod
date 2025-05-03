#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=bookkeep
#SBATCH --output=stdout_bookkeep_mcc9_v29e_dl_run1_C1_extbnb
#SBATCH --mem-per-cpu=4000
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=2
#SBATCH --partition=wongjiradlab
##SBATCH --gres=gpu:p100:3
#SBATCH --error=griderr_bookkeep_mcc9_v29e_dl_run1_C1_extbnb

container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/singularity_minkowski_u20.04.cu111.torch1.9.0_jupyter_xgboost.sif
RUN_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/
BINDING=/cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab
UBDL=/cluster/tufts/wongjiradlabnu/twongj01/gen2/photon_analysis/ubdl/

module load singularity/3.5.3
# GPU MODE
#singularity exec --nv ${container} bash -c "cd ${RUN_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"
# CPU MODE
cd /cluster/tufts/wongjiradlab/
cd /cluster/tufts/wongjiradlabnu/
cd ${RUN_DIR}
singularity exec --bind ${BINDING} ${container} bash -c "cd ${UBDL} && source setenv_py3.sh && source configure.sh && cd ${RUN_DIR} && python3 check_files.py"

