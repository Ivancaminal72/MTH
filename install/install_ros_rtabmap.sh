#!/bin/bash
cd ~/workspace
source ~/workspace/install/modules_rtabmap.sh
mkdir -p rtabmap-world3d-ros/src && cd rtabmap-world3d-ros/
catkin_make
source devel/setup.bash
rosinstall_generator rtabmap_ros --rosdistro kinetic \
    --deps --wet-only --exclude RPP libg2o octomap \
    rtabmap qt_gui_cpp | wstool merge -t src -
