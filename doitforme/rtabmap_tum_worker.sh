#!/bin/bash
downsampling=1
path="/imatge/icaminal/datasets/tumrgbd"

seq_a=("rgbd_dataset_freiburg1_desk" 
	 "rgbd_dataset_freiburg1_room" 
	 "rgbd_dataset_freiburg2_desk"
     "rgbd_dataset_freiburg2_large_no_loop"
	 "rgbd_dataset_freiburg2_pioneer_slam2"
     "rgbd_dataset_freiburg3_long_office_household")
inlier_dist_a=("0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1") #FIX
#inlier_dist_a=("0.015" "0.020" "0.005" "0.03" "0.48" "0.005")
cal_a=("1" "1" "2" "2" "2" "3")

dot_a=("f2m")

max_inlierdist=1
gftt_dist=5 #downsampling2 GFTT.MinDistance/dw^2

source ~/workspace/install/modules_rtabmap.sh
cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build

for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$path/${seq_a[i]}
	out_dir=${gen_dir}_rtab_${downsampling}
	#gen_dir=$path/${seq_a[i]} #for downsampling2 us this (the script was thougth later...)
	calib=$path/calib_freiburg${cal_a[i]}.txt
	rm -f $out_dir/*rtabmap*
	mkdir -p $out_dir/worker/
    echo -e "\n\n Running sequence: $gen_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do			
			rm -f $out_dir/database.rtabmap.poses.*.db
			out_name=rtabmap.poses.$inlierdist.${dot_a[j]}
			printf "\n${dot_a[j]} "
			printf "\nTrying inlier distance --> $inlierdist\n"
			
			#Without loop closure
			srun --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "rgb_sync"\
			--depthname "depth_sync"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--depthfactor 5.0 \
			--Rtabmap/PublishRAMUsage true \
			--Rtabmap/DetectionRate 2 \
			--Rtabmap/CreateIntermediateNodes true \
			--RGBD/LinearUpdate 0 \
			--Reg/Strategy 0 \
			--GFTT/QualityLevel 0.005\
			--GFTT/MinDistance $gftt_dist \
			--Odom/Strategy 0 \
			--OdomF2M/MaxSize 3000 \
			--Kp/MaxFeatures -1 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/FeatureType 6 \
			--Vis/InlierDistance $inlierdist \
			$gen_dir \
			> $out_dir/worker/out.${dot_a[j]}.txt \
			
			retVal=$?
			if [[ $retVal -eq 0 ]]
			then
				break
			elif [[ $retVal -eq 3 && $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1<=$2)}') -eq 1 ]]
			then
				inlierdist=$(echo "$inlierdist 0.005" | awk '{printf "%.3f", $1+$2}')
				break #NO TUNE INLIER DIST#######------------#############
				rm -f $out_dir/$out_name
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]]
			then 
				rm -f $out_dir/$out_name
				break
			else
				continue 
				#exit
			fi
		done
	done
done

for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$path/${seq_a[i]}
	out_dir=${gen_dir}_rtab_${downsampling}
	#gen_dir=$path/${seq_a[i]} #for downsampling2 us this (the script was thinked later...)
	calib=$path/calib_freiburg${cal_a[i]}.txt
    echo -e "\n\n Running sequence: $gen_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do
			out_name=rtabmap.poses.$inlierdist.${dot_a[j]}.od
			rm -f $out_dir/database.rtabmap.poses.*.od.db
			printf "\n${dot_a[j]} "
			printf "\nTrying inlier distance --> $inlierdist\n"

			#With loop closure
			srun --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "rgb_sync"\
			--depthname "depth_sync"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--depthfactor 5.0 \
			--Rtabmap/PublishRAMUsage true \
			--Rtabmap/DetectionRate 2 \
			--Rtabmap/CreateIntermediateNodes true \
			--RGBD/LinearUpdate 0 \
			--Reg/Strategy 0 \
			--GFTT/QualityLevel 0.005\
			--GFTT/MinDistance $gftt_dist \
			--Odom/Strategy 0 \
			--OdomF2M/MaxSize 3000 \
			--Kp/MaxFeatures 750 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/FeatureType 6 \
			--Vis/InlierDistance $inlierdist \
			$gen_dir \
			> $out_dir/worker/out.${dot_a[j]}.od.txt \
			#2> $out_dir/worker/err.${dot_a[j]}.txt

			#--Mem/STMSize 30 \ #def. 10
			#--RGBD/OptimizeMaxError 2.0 \
			#--RGBD/NeighborLinkRefining true \
			
			retVal=$?
			if [[ $retVal -eq 0 ]]
			then
				break
			elif [[ $retVal -eq 3 && $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1<=$2)}') -eq 1 ]]
			then
				inlierdist=$(echo "$inlierdist 0.005" | awk '{printf "%.3f", $1+$2}')
				break #NO TUNE INLIER DIST#######------------#############
				rm -f $out_dir/$out_name
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]]
			then 
				rm -f $out_dir/$out_name
				break
			else
				continue
				#exit
			fi	
		done
	done
done
