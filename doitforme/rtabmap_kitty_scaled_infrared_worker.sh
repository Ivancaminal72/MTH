#!/bin/bash
downsampling=1
path="/imatge/icaminal/datasets/kitty/generated"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10")
#inlier_dist_a=("0.005" "0.005" "0.005" "0.005" "0.005" "0.005" "0.005" "0.005" "0.005" "0.005" "0.005") #SCALED gftt/brief
inlier_dist_a=("0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1") #FIX

#inlier_dist_a=0.5
#seq_a="07"
dot_a=("f2m")

max_inlierdist=0.3
depth_scale=20 #SCALED
gftt_dist=6
#gftt_dist=2 #downsampling2 GFTT.MinDistance/dw^2

source ~/workspace/install/modules_rtabmap.sh
cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build

for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$path/${seq_a[i]}
	out_dir=${gen_dir}_rtab_${downsampling}_infrared_scaled #infrared SCALED
	calib=$path/${seq_a[i]}/calib_${downsampling}.000000.txt.scaled #SCALED
	rm -f $out_dir/*rtabmap*
	mkdir -p $out_dir/worker/
    echo -e "\n\n Running sequence: $gen_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do
			out_name=$downsampling.rtabmap.poses.$inlierdist.${dot_a[j]}.scaled #SCALED
			printf "\nTrying inlier distance --> $inlierdist\n"

			#Without loop closure
			printf "\n${dot_a[j]} "

			srun --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "infrared_mint_three"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--scale ${depth_scale} \
			--times /imatge/icaminal/datasets/kitty/sequences/${seq_a[i]}/times.txt \
			--Rtabmap/PublishRAMUsage true \
			--Rtabmap/DetectionRate 2 \
			--Rtabmap/CreateIntermediateNodes true \
			--RGBD/LinearUpdate 0 \
			--Reg/Strategy 0 \
			--GFTT/QualityLevel 0.0005\
			--GFTT/MinDistance $gftt_dist \
			--Odom/Strategy 0 \
			--OdomF2M/MaxSize 3000 \
			--Kp/MaxFeatures -1 \
			--Kp/DetectorStrategy 6 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/FeatureType 6\
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
			fi

		done
	done
done

for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$path/${seq_a[i]}
	out_dir=${gen_dir}_rtab_${downsampling}_infrared_scaled #infrared SCALED
	calib=$path/${seq_a[i]}/calib_${downsampling}.000000.txt.scaled #SCALED
	mkdir -p $out_dir/worker/
    echo -e "\n\n Running sequence: $gen_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do
			out_name=$downsampling.rtabmap.poses.$inlierdist.${dot_a[j]}.scaled #SCALED
			rm -f $out_dir/database.$downsampling.rtabmap.poses.*.od.db
			printf "\nTrying inlier distance --> $inlierdist\n"

			#With loop closure
			printf "\n${dot_a[j]}.od "
			out_name=$out_name.od
			
			srun --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "infrared_mint_three"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--times /imatge/icaminal/datasets/kitty/sequences/${seq_a[i]}/times.txt \
			--scale ${depth_scale} \
			--Rtabmap/PublishRAMUsage true \
			--Rtabmap/DetectionRate 2 \
			--Rtabmap/CreateIntermediateNodes true \
			--RGBD/LinearUpdate 0 \
			--Reg/Strategy 0 \
			--GFTT/QualityLevel 0.0005\
			--GFTT/MinDistance $gftt_dist \
			--Odom/Strategy 0 \
			--OdomF2M/MaxSize 3000 \
			--Kp/MaxFeatures 750 \
			--Kp/DetectorStrategy 6 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/FeatureType 6\
			--Vis/InlierDistance $inlierdist \
			$gen_dir \
			> $out_dir/worker/out.${dot_a[j]}.od.txt \

			#--Mem/STMSize 30 \ #def. 10
			#--RGBD/OptimizeMaxError 2.0 \
			#--RGBD/NeighborLinkRefining true \

#			--Grid/FromDepth true\
#			--Grid/DepthDecimation 1\
#			--Grid/RangeMax 20\
#			--Grid/3D true\	
			
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
			fi
		done
	done
done
