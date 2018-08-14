#!/bin/bash
downsampling=1
path="/imatge/icaminal/datasets/TUM_rgbd"

seq_a=("rgbd_dataset_freiburg1_desk" 
	 "rgbd_dataset_freiburg1_room" 
	 "rgbd_dataset_freiburg2_desk")
cal_a=("1" "1" "2")
inlier_dist_a=("0.1" "0.1" "0.1") 

test_a=("" "-r" "-fod" "-fod -r" "-ri" "-fod -ri")
dot_a=("f2m")

max_inlierdist=9

source ~/workspace/install/modules_rtabmap.sh
cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build

for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$path/${seq_a[i]}
	out_dir=${gen_dir}_rtab_${downsampling}
	#gen_dir=$path/${seq_a[i]} #for downsampling2 us this (the script was thinked later...)
	calib=$path/calib_freiburg${cal_a[i]}.txt
	rm -fr $out_dir
	mkdir -p $out_dir/worker/
    echo -e "\n\n Running sequence: $gen_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do
			out_name=rtabmap.poses.$inlierdist.${dot_a[j]}.od
			printf "\n${dot_a[j]} "
			printf "\nTrying inlier distance --> $inlierdist\n"

			#With loop closure
			srun-fast --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "rgb_sync"\
			--depthname "depth_sync"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
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
			--Kp/DetectorStrategy 0 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/InlierDistance $inlierdist \
			$gen_dir \
			> $out_dir/worker/out.${dot_a[j]}.txt \
			#2> $out_dir/worker/err.${dot_a[j]}.txt

			#--Mem/STMSize 30 \ #def. 10
			#--RGBD/OptimizeMaxError 2.0 \
			#--RGBD/NeighborLinkRefining true \

			#printf "\n${dot_a[j]}.od "
			#With loop closure
			
			retVal=$?
			if [[ $retVal -eq 0 ]]
			then
				break
			elif [[ $retVal -eq 3 && $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1<=$2)}') -eq 1 ]]
			then
				inlierdist=$(echo "$inlierdist 0.02" | awk '{printf "%f", $1+$2}')
				rm -f $out_dir/$out_name
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]]
			then 
				rm -f $out_dir/$out_name
				break
			else
				exit
			fi

		done
	done
done
