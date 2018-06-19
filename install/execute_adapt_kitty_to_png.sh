#!/bin/bash
module purge
module load slurm/15.08.9-1

#modules
echo "loading modules"
module load eigen/3.2.8 \
			opencv/2.4.9 \
			boost/1.60 \

#execute
cd /imatge/icaminal/workspace/adapt/KITTY/kitty_to_png/build
pwd
srun --mem=4GB -c4 ./kitty_to_png \
-r 120 \
-d 4 \
-l /imatge/icaminal/projects/world3d/2018-slam/dataset/lidar_sequences/00/velodyne \
-s /imatge/icaminal/projects/world3d/2018-slam/dataset/generated/00/ \
-i /imatge/icaminal/projects/world3d/2018-slam/dataset/color_sequences/00/image_2
