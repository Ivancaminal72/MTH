#!bin/bash
cd ~/workspace/ElasticFusion/Core/
rm -rf build/
mkdir build && cd build
cmake ../src -DCMAKE_CXX_FLAGS="-D HAVE_EIGEN"
srun --mem 20G -c12 make -j12
