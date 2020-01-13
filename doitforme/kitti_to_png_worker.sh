#!/bin/bash
source ~/workspace/install/modules_adapt_kitti_to_png.sh
ID=0
downsampling=1
while [ "$ID" -lt 10 ]
do
    echo $ID
	srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/kitti/kitti_to_png/build/kitti_to_png -r 120 -d $downsampling -i /imatge/icaminal/projects/world3d/2018-slam/kitti/ -o /imatge/icaminal/projects/world3d/2018-slam/kitti/generated/ -s 0$ID
    (( ID++ ))
done
ID=10
echo $ID
srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/kitti/kitti_to_png/build/kitti_to_png -r 120 -d $downsampling -i /imatge/icaminal/projects/world3d/2018-slam/kitti/ -o /imatge/icaminal/projects/world3d/2018-slam/kitti/generated/ -s $ID
ID=22
echo $ID
srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/kitti/kitti_to_png/build/kitti_to_png -r 120 -d $downsampling -i /imatge/icaminal/projects/world3d/2018-slam/kitti/ -o /imatge/icaminal/projects/world3d/2018-slam/kitti/generated/ -s $ID

echo all done!
