# change to your workspace folder
cd ~/methods

# load modules
module load openni2/master \
            opencv/2.4.9 \
            boost/1.60 \
            dlib/1.0 \
            dbow2/1.0 \
            dloopdetector/1.0 \
            isam/1.7 \
            pcl/1.7.2 \
            eigen/3.2.8

# download Kintinuous  (will create a "Kintinuous" folder)
git clone --recursive https://github.com/mp3guy/Kintinuous.git

# download dependencies
cd Kintinuous
mkdir deps && cd deps/
git clone https://github.com/stevenlovegrove/Pangolin.git

# build dependencies
cd Pangolin
mkdir build && cd build
cmake ..
srun --mem 20G -c12 make -j12

# build Kintinuous
cd ~/methods/Kintinuous/src/
mkdir build && cd build
cmake ../ -DCMAKE_CXX_FLAGS="-D HAVE_EIGEN"
srun --mem 20G -c12 make -j12
