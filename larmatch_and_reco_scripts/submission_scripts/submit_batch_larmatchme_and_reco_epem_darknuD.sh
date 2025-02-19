#!/bin/bash

# slurm submission script for running merged dlreco through larmatch and larflowreco
#SBATCH --job-name=epem-dnD-fullReco
#SBATCH --output=larmatchme_larflowreco_epem_darknuD_sub00.log
#SBATCH --mem-per-cpu=4000
##SBATCH --time=30:00:00
#SBATCH --time=3-00:00:00
##SBATCH --array=1-44
#SBATCH --array=0-44
#SBATCH --cpus-per-task=4
#SBATCH --partition=batch,wongjiradlab
##SBATCH --partition=wongjiradlab
##SBATCH --partition=preempt
##SBATCH --exclude=i2cmp006,s1cmp001,s1cmp002,s1cmp003,p1cmp041,c1cmp003,c1cmp004
##SBATCH --gres=gpu:p100:3
##SBATCH --partition ccgpu
##SBATCH --gres=gpu:a100:1
##SBATCH --nodelist=ccgpu01
#SBATCH --error=griderr_larmatcheme_larflowreco_epem_darknuD_sub00.%j.%N.err

container=/cluster/tufts/wongjiradlabnu//larbys/larbys-container/singularity_minkowski_u20.04.cu111.torch1.9.0_jupyter_xgboost.sif
RUN_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/dlgen2prod/larmatch_and_reco_scripts/
OFFSET=0
STRIDE=5

SAMPLE_NAME="epem_DarkNu_BenchmarkD"
INPUTSTEM=merged_dlreco
FILEIDLIST=/cluster/tufts/wongjiradlabnu/nutufts/dlgen2prod/larmatch_and_reco_scripts/larmatch_runlist_epem_DarkNu_BenchmarkD.txt
# num files in inputlist: 400

module load singularity/3.5.3
# GPU MODE
#singularity exec --nv ${container} bash -c "cd ${RUN_DIR} && source run_batch_kps_larmatch.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTFILE} ${INPUTSTEM} ${FILEIDLIST}"
# CPU MODE
singularity exec --bind /cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu,/cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab ${container} bash -c "cd ${RUN_DIR} && source run_batch_larmatchme_and_reco_darkNu_mc.sh $OFFSET $STRIDE $SAMPLE_NAME ${INPUTSTEM} ${FILEIDLIST}"

