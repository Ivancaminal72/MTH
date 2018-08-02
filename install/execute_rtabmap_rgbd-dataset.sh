#!/bin/bash
downsampling=1
path="/imatge/icaminal/datasets/kitty/generated"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "22") 
test_a=("" "-r" "-fod" "-fod -r" "-ri" "-fod -ri")
dot_a=("i" "r" "if" "rf" "ri" "rif")

source ~/workspace/install/modules_rtabmap.sh
source ~/workspace/world3d-ros/devel/setup.bash
cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build

srun-fast --x11 --mem=8GB -c 4 ./rgbd_dataset \
--output /projects/world3d/2018-slam/kitty/generated/05_rtab \
--calib calib_1.000000.txt \
--times /imatge/icaminal/datasets/kitty/sequences/05 \
--Rtabmap/PublishRAMUsage true \
--Rtabmap/DetectionRate 2 \
--Rtabmap/CreateIntermediateNodes true \
--RGBD/LinearUpdate 0 \
--Reg/Strategy 0 \
--GFTT/QualityLevel 0.001 \
--GFTT/MinDistance 7 \
--Odom/Strategy 0 \
--OdomF2M/MaxSize 3000 \
--Kp/MaxFeatures 750 \
--Vis/MaxFeatures 1500 \
--Vis/EstimationType 0 \
--Vis/InlierDistance 0.5 \
/projects/world3d/2018-slam/kitty/generated/05

#--Mem/STMSize 30 \ #def. 10
#--RGBD/OptimizeMaxError 2.0 \
#--RGBD/NeighborLinkRefining true \


#for ((i=0;i<${#seq_a[@]};++i)); do
#	seq_dir=$path/${seq_a[i]}_${downsampling}
#	#seq_dir=$path/${seq_a[i]} #for downsampling2 us this (the script was thinked later...)
#	calib=$path/${seq_a[i]}/calib_${downsampling}.000000.txt.scaled
#	rm -fr $seq_dir/worker/
#	mkdir $seq_dir/worker/
#	rm -f $seq_dir/*poses*
#	rm -f $seq_dir/*ate*
#	rm -f $seq_dir/*plot*
#    echo -e "\n\n Running sequence: $seq_dir"

#	for ((j=0;j<${#test_a[@]};++j)); do
#		
#		printf "\n${dot_a[j]} "

#		#Without loop closure
#		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $seq_dir/${downsampling}.klg.10922 ${test_a[j]} -fl -c $calib -t 16 > $seq_dir/worker/out.${dot_a[j]}.txt 2> $seq_dir/worker/err.${dot_a[j]}.txt
#		mv $seq_dir/${downsampling}.klg.10922.poses $seq_dir/${downsampling}.klg.10922.poses.${dot_a[j]}

#		printf "\n${dot_a[j]}.od "

#		#With loop closure
#		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $seq_dir/${downsampling}.klg.10922 ${test_a[j]} -od -fl -c $calib -t 16 > $seq_dir/worker/out.${dot_a[j]}.od.txt 2> $seq_dir/worker/err.${dot_a[j]}.od.txt
#		mv $seq_dir/${downsampling}.klg.10922.poses $seq_dir/${downsampling}.klg.10922.poses.${dot_a[j]}.od

#	done
#done
