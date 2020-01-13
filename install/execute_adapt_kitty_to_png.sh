#!/bin/bash
module purge
module load slurm/15.08.9-1

#modules
echo "loading modules"
module load eigen/3.3.4 \
			opencv/3.4.1 \
			boost/1.60 \

#execute
cd /imatge/icaminal/workspace/adapt/kitti/kitti_to_png/build
pwd
srun-fast --x11 --mem=8GB -c1 ./kitti_to_png \
-r 120 \
-d 1 \
-i /imatge/icaminal/projects/world3d/2018-slam/dataset/ \
-s 22 \
-o /imatge/icaminal/projects/world3d/2018-slam/dataset/generated/
