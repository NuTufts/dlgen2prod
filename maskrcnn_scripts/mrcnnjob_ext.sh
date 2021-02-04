#!/bin/bash

# This runs inside the container and builds the container
# We assume you did the first-time setup already
# source mrcnnjob.sh /cluster/tufts/wongjiradlab/jmills09/ubdl_gen2/ /cluster/tufts/wongjiradlab/jmills09/maskrcnn_gen2/ 0
# python tools/save_output_objects.py --dataset particle --cfg configs/tuftscluster_config_0.yaml --load_ckpt weights/u_plane.pth --input_file /cluster/tufts/wongjiradlab/larbys/data/mcc9/mcc9_v29e_dl_run3_G1_extbnb_dlana/data/mcc9_v29e_dl_run3_G1_extbnb_dlana/merged_dlana_d9679e9b-3be3-4411-bc25-6e2cea860827.root --output_dir output2_delete/ --num_images 999
UBDL_DIR=$1
MRCNN_DIR=$2
SLURM_ARRAY_TASK_ID=$3

echo "Here"
echo $UBDL_DIR
echo $MRCNN_DIR
echo $SLURM_ARRAY_TASK_ID

cd $UBDL_DIR
source setenv.sh
source configure.sh
cd $MRCNN_DIR
SAMPLE=mcc9_v29e_dl_run3_G1_extbnb_dlana
# FILELIST=/cluster/tufts/wongjiradlab/larbys/data/mcc9/${SAMPLE}/goodlist.txt
# FILELIST=/cluster/tufts/wongjiradlab/jmills09/mrcnn_processed_outs/mcc9_v29e_dl_run3_G1_extbnb_dlana/second_failed_files_2.txt
FILELIST=/cluster/tufts/wongjiradlab/jmills09/mrcnn_processed_outs/mcc9_v29e_dl_run3_G1_extbnb_dlana/fifth_failed_files_2.txt
SUBMITNUM=5
# SAMPLE=mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge
# FILELIST=/cluster/tufts/wongjiradlab/jmills09/mrcnn_processed_outs/failed_files_2.txt
# FILELIST=/cluster/tufts/wongjiradlab/larbys/data/mcc9/mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge/goodlist.txt
ARRAYID=$SLURM_ARRAY_TASK_ID

# 34254 entries 0 to 17 (18 total at 1950 jobs)
# 16557 entries in 2nd pass, go from 0 to 8 (9 total at 1950 jobs )
# for VARIABLE in {0..17} #need ext to go from 0 to 17
for VARIABLE in {0..0}

do
  # echo $VARIABLE
  let line=(1 * $ARRAYID + 1 + $VARIABLE)

  # if [ $line -lt 34300 ]
  if [ $line -lt 159 ]
  then
  INFULLPATHFILE=`sed -n ${line}p ${FILELIST}`
  INDIR=`dirname "${INFULLPATHFILE}"`
  INDIR=${INDIR}/
  INFILE=`basename "$INFULLPATHFILE"`
  PADVAR=$VARIABLE
  while [ ${#PADVAR} -ne 2 ];
  do
    PADVAR="0"$PADVAR
  done
  PADARRAY=$ARRAYID
  while [ ${#PADARRAY} -ne 4 ];
  do
    PADARRAY="0"$PADARRAY
  done
  OUTDIR0=/cluster/tufts/wongjiradlab/jmills09/mrcnn_processed_outs/${SAMPLE}/${SUBMITNUM}/${PADARRAY}/${PADVAR}/0/
  OUTDIR1=/cluster/tufts/wongjiradlab/jmills09/mrcnn_processed_outs/${SAMPLE}/${SUBMITNUM}/${PADARRAY}/${PADVAR}/1/
  OUTDIR2=/cluster/tufts/wongjiradlab/jmills09/mrcnn_processed_outs/${SAMPLE}/${SUBMITNUM}/${PADARRAY}/${PADVAR}/2/

  mkdir -p $OUTDIR0
  mkdir -p $OUTDIR1
  mkdir -p $OUTDIR2

  NENTRIES=$(python check_file_entry_count.py --input_file ${INFULLPATHFILE})

  for ENTRYVAR in $(seq 0 $NENTRIES)
  do

    python tools/save_output_objects.py \
          --dataset particle \
          --cfg configs/tuftscluster_config_0.yaml  \
          --load_ckpt weights/u_plane.pth  \
          --input_file ${INFULLPATHFILE} \
          --output_dir ${OUTDIR0} \
          --one_entry ${ENTRYVAR}

    python tools/save_output_objects.py \
          --dataset particle \
          --cfg configs/tuftscluster_config_1.yaml  \
          --load_ckpt weights/v_plane.pth  \
          --input_file ${INFULLPATHFILE} \
          --output_dir ${OUTDIR1} \
          --one_entry ${ENTRYVAR}

    python tools/save_output_objects.py \
          --dataset particle \
          --cfg configs/tuftscluster_config_2.yaml  \
          --load_ckpt weights/y_plane.pth  \
          --input_file ${INFULLPATHFILE} \
          --output_dir ${OUTDIR2} \
          --one_entry ${ENTRYVAR}
  done

  cd ${OUTDIR0}
  hadd -f hadd_mrcnnproposals_${INFILE} mrcnn*root
  cd ${OUTDIR1}
  hadd -f hadd_mrcnnproposals_${INFILE} mrcnn*root
  cd ${OUTDIR2}
  hadd -f hadd_mrcnnproposals_${INFILE} mrcnn*root
  fi
  cd $MRCNN_DIR

done





cd /cluster/tufts/wongjiradlab/jmills09/
