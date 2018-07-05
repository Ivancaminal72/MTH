#!/bin/bash
module purge
module load slurm/15.08.9-1

#modules
module load ros/kinetic \
            rtabmap/0.17.1 \
            octomap/1.7.1
