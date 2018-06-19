#!/bin/bash
module purge
module load slurm/15.08.9-1

#modules
echo "loading modules"
module load eigen/3.2.8 \
			opencv/2.4.9 \
			boost/1.60 \

