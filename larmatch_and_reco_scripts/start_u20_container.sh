#!/bin/bash

CONTAINER_DIR=/cluster/tufts/wongjiradlabnu/twongj01/gen2/photon_analysis/
CONTAINER=u20.04_cu111_torch1.9.0_minkowski.sif
#BINDING="-B /cluster/:/cluster/"

#CONTAINER_DIR=/cluster/tufts/wongjiradlabnu/larbys/larbys-container/
#CONTAINER=lantern_v2_me_06_03_prod

BINDING="-B /cluster/tufts:/cluster/tufts "
BINDING+="-B /cluster/tufts/wongjiradlab:/cluster/tufts/wongjiradlab "
BINDING+="-B /cluster/tufts/wongjiradlabnu:/cluster/tufts/wongjiradlabnu "
BINDING+="-B $HOME:$HOME "
#BINDING+="-B /cluster/home/gen2ntuple:/cluster/home/gen2ntuple "
#BINDING+="-B /cluster/home/lantern_scripts:/cluster/home/lantern_scripts "
#BINDING+="-B /cluster/home/prongCNN:/cluster/home/prongCNN "
#BINDING+="-B /cluster/home/ubdl:/cluster/home/ubdl "
#BINDING+="-B /cluster/home/uresnet_pytorch:/cluster/home/uresnet_pytorch "

echo "BINDING: ${BINDING}"

module load singularity/3.5.3
singularity shell --nv ${BINDING} ${CONTAINER_DIR}/${CONTAINER}
