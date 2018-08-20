#!/bin/bash
module purge
module load slurm/15.08.9-1

#modules
echo "loading modules"
module load boost/1.60 \
			pcl/1.7.2 \
			opencv \

