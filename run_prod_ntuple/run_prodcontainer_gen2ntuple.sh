#!/bin/bash

DLGEN2PROD_DIR=$1
SAMPLE_NAME=$2
RECO_VER=$3
GOOD_RECO_LIST=$4
NFILES=$5
WEIGHTFILE=$6
OUTDIR=$7

GEN2NTUPLE_DIR="/cluster/home/gen2ntuple"
SCRIPT=${DLGEN2PROD_DIR}/run_prod_ntuple/get_dlmerged.py
LARPID_DIR=/cluster/home/prongCNN/models/checkpoints/
LARPID_MODEL="${LARPID_DIR}/LArPID_default_network_weights.pt"

alias python=python3
source /cluster/home/lantern_scripts/setup_lantern_container.sh

maxFileCount=`wc -l < $GOOD_RECO_LIST`
let firstfile="${SLURM_ARRAY_TASK_ID}*${NFILES}"
let lastfile="$firstfile+${NFILES}-1"
echo "firstfile=${firstfile}"
echo "lastfile=${lastfile}"

local_jobdir=`printf /tmp/lantern_prodgen2ntuple_jobid%05d_${SAMPLE_NAME}_${SLURM_JOB_ID} ${SLURM_ARRAY_TASK_ID}`
mkdir -p $local_jobdir
cd $local_jobdir

mkdir -p $OUTDIR

for n in $(seq $firstfile $lastfile); do
  if (($n > $maxFileCount)); then
    break
  fi
  let lineno="${n}+1"
  fileid=`sed -n ${lineno}p ${GOOD_RECO_LIST} | awk '{ print $1 }'`
  recofile=`sed -n ${lineno}p ${GOOD_RECO_LIST} | awk '{ print $2 }'`
  dlmergedfile=`python3 ${SCRIPT} ${fileid} ${SAMPLE_NAME} ${RECO_VER} ${DLGEN2PROD_DIR} | awk '{ print $2 }'`
  ntuple_filename=`printf lantern_v2_me_06_03_prodntuple_${SAMPLE_NAME}_${RECO_VER}_fileid%05d.root ${fileid}`

  recobase=$(basename ${recofile})
  dlmergedbase=$(basename ${dlmergedfile})
  
  echo "fileid: ${fileid}"
  echo "recofile: ${recofile}"
  echo "dlmergedfile: ${dlmergedfile}"
  echo "ntuple_filename: ${ntuple_filename}"

  if [ -n "$dlmergedfile" ]; then
      cp $recofile .
      cp $dlmergedfile .        
      cmd="python3 ${GEN2NTUPLE_DIR}/make_dlgen2_flat_ntuples.py -f ${recobase} -t ${dlmergedbase} -o ${ntuple_filename} -m $LARPID_MODEL -mc -tb -w ${WEIGHTFILE}"
      echo $cmd
      $cmd
  fi
done
haddfile=`printf lantern_v2_me_06_03_prodntuple_${SAMPLE_NAME}_${RECO_VER}_jobid%04d.root ${SLURM_ARRAY_TASK_ID}`
haddcmd="hadd -f $haddfile lantern_v2_me_06_03_prodntuple_${SAMPLE_NAME}_${RECO_VER}_fileid*.root"
echo $haddcmd
$haddcmd

cpcmd="cp ${haddfile} ${OUTDIR}/"
echo $cpcmd
$cpcmd

echo "DONE"



