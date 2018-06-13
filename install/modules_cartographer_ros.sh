#!/bin/bash
module purge
module load slurm/15.08.9-1

#modules
module load ros \
            ros-externals \
            boost \
            gtest \
            opencv \
            vtk \
            openni/1.5.4.0 \
            openni2 \
            tesseract \
            leptonica \
            cuda \
            eigen/3.2.8 \
            ogre \
            pcl \
            ceres/1.13 \
