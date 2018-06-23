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
srun --mem=8GB -c4 ./kitty_to_png \
-r 120 \
-d 4 \
-i /imatge/icaminal/projects/world3d/2018-slam/dataset/ \
-s 22 \
-o /imatge/icaminal/projects/world3d/2018-slam/dataset/generated/
