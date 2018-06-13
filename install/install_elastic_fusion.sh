# INSTALL --> bash install_elastic_fusion.sh 2> log_elastic_fusion_build.txt
# change to your workspace folder
cd ~/methods

# load modules
module load openni2/master \
            eigen/3.3.4 \
	    cuda/8.0

# download ElasticFusion
git clone --recursive https://github.com/Ivancaminal72/ElasticFusion.git
mv ElasticFusion elastic_fusion

# download dependencies
cd elastic_fusion
mkdir deps && cd deps/
git clone https://github.com/stevenlovegrove/Pangolin.git

# build dependencies
cd Pangolin
#git checkout v0.5
mkdir build && cd build
cmake .. -DEIGEN3_INCLUDE_DIR=/usr/local/opt/eigen-3.3.4/include/
srun --mem 20G -c12 make -j12

#patch to avoid the arch 61 of CUDA
cd ../../../Core/src
#sed -i -e 's/30 35 50 52 61/30 35 50 52/g' CMakeLists.txt

#build ElasticFusion
cd ..
mkdir build && cd build
cmake ../src -DCMAKE_CXX_FLAGS="-D HAVE_EIGEN"
srun --mem 20G -c12 make -j12
cd ../../GPUTest
mkdir build && cd build
cmake ../src -DCMAKE_CXX_FLAGS="-D HAVE_EIGEN"
srun --mem 20G -c12 make -j12
cd ../../GUI
mkdir build && cd build
cmake ../src -DCMAKE_CXX_FLAGS="-D HAVE_EIGEN"
srun --mem 20G -c12 make -j12
