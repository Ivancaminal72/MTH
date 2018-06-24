#!/bin/bash
module purge
module load slurm/15.08.9-1

#modules
echo "loading modules"
module load eigen/3.3.4 \
			opencv/3.4.1 \
			boost/1.60 \

