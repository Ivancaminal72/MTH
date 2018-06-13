#!/bin/bash
module purge
module load slurm/15.08.9-1

#kintinuous modules
module load openni2/master \
            opencv/2.4.9 \
            boost/1.60 \
            dlib/1.0 \
            dbow2/1.0 \
            dloopdetector/1.0 \
            isam/1.7 \
            pcl/1.7.2 \
            eigen/3.2.8
