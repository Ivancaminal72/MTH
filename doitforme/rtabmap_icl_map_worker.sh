#!/bin/bash
kpfeat=gftt_brief_fix
map_dir="/work/icaminal/reconstructions/icl"
path="/imatge/icaminal/datasets/ICL-NUIM_synthetic/living-room"
source ~/workspace/install/modules_rtabmap.sh

dot_a=("f2m")
#version="orig_tum"
version="noise_tum"
flip="_flip" #FLIP
#flip=""

inlier_dist_a=("0.1" "0.1" "0.1" "0.1")

max_inlierdist=0.1
gftt_dist=5

for ((i=0;i<4;++i)); do
	cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build
	seq_dir=$path/$i/${version}${flip}
	out_dir=$path/generated/${version}${flip}/${i}_rtab
	calib=$path/calib${flip}.txt
	rm -fr $out_dir
	mkdir -p $out_dir/worker/
	mkdir -p $path/$i/$version/worker/
	
    echo -e "\n\n Processing sequence: $seq_dir"
	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do
			rm -f $out_dir/database.rtabmap.poses.*.db
			out_name=rtabmap.poses.$inlierdist.${dot_a[j]}.$kpfeat
			printf "\n${dot_a[j]} "
			printf "\nTrying inlier distance --> $inlierdist\n"

			#Without loop closure
			srun-fast --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "rgb"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--depthfactor 5.0 \
			--times "none" \
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
			--Kp/DetectorStrategy 0 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/FeatureType 8 \
			--Vis/InlierDistance $inlierdist \
			$seq_dir \
			> $out_dir/worker/out.${dot_a[j]}.txt \
			#2> $out_dir/worker/err.${dot_a[j]}.txt
			
			retVal=$?
			if [[ $retVal -eq 0 ]]
			then
				:
			elif [[ $retVal -eq 3 && $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1<=$2)}') -eq 1 ]]
			then
				inlierdist=$(echo "$inlierdist 0.005" | awk '{printf "%3f", $1+$2}')
				rm -f $out_dir/$out_name
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]]
			then 
				rm -f $out_dir/$out_name
				break
			else
				continue 
			fi
			
			rm -fr $map_dir/$i/$version/rtab_*
			mkdir -p $map_dir/$i/$version/rtab_cloud/
			mkdir -p $map_dir/$i/$version/rtab_mesh/
			mkdir -p $map_dir/$i/$version/rtab_texture/

			cd /imatge/icaminal/workspace/export_rtab-map/build
			srun --mem=40GB ./export --output $map_dir/$i/$version/rtab_cloud --outname $out_name $out_dir/database.$out_name.db
			srun --mem=40GB ./export --mesh --output $map_dir/$i/$version/rtab_mesh --outname $out_name $out_dir/database.$out_name.db
			srun --mem=40GB ./export --texture --output $map_dir/$i/$version/rtab_texture --outname $out_name $out_dir/database.$out_name.db
			break

		done
	done
done

for ((i=0;i<4;++i)); do
	cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build
	seq_dir=$path/$i/${version}${flip}
	out_dir=$path/generated/${version}${flip}/${i}_rtab
	calib=$path/calib${flip}.txt
	mkdir -p $out_dir/worker/
	mkdir -p $path/$i/$version/worker/
	mkdir -p $map_dir/$i/$version/rtab_cloud/
	mkdir -p $map_dir/$i/$version/rtab_mesh/
	mkdir -p $map_dir/$i/$version/rtab_texture/
	
    echo -e "\n\n Processing sequence: $seq_dir"
	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=${inlier_dist_a[i]}
		while true
		do
			out_name=rtabmap.poses.$inlierdist.${dot_a[j]}.$kpfeat.od
			rm -f $out_dir/database.rtabmap.poses.*.od.db
			printf "\n${dot_a[j]} "
			printf "\nTrying inlier distance --> $inlierdist\n"

			#With loop closure
			srun-fast --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "rgb"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--depthfactor 5.0 \
			--times "none" \
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
			--Kp/DetectorStrategy 0 \
			--Vis/CorType 0 \
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
			--Vis/FeatureType 8 \
			--Vis/InlierDistance $inlierdist \
			$seq_dir \
			> $out_dir/worker/out.${dot_a[j]}.od.txt \
			#2> $out_dir/worker/err.${dot_a[j]}.txt
			
			retVal=$?
			if [[ $retVal -eq 0 ]]
			then
				:
			elif [[ $retVal -eq 3 && $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1<=$2)}') -eq 1 ]]
			then
				inlierdist=$(echo "$inlierdist 0.005" | awk '{printf "%3f", $1+$2}')
				rm -f $out_dir/$out_name
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]]
			then 
				rm -f $out_dir/$out_name
				break
			else
				continue
			fi
			
			rm -fr $map_dir/$i/$version/rtab_cloud/*.od.*
			rm -fr $map_dir/$i/$version/rtab_mesh/*.od.*
			rm -fr $map_dir/$i/$version/rtab_texture/*.od.*

			cd /imatge/icaminal/workspace/export_rtab-map/build
			srun --mem=40GB ./export --output $map_dir/$i/$version/rtab_cloud --outname $out_name $out_dir/database.$out_name.db
			srun --mem=40GB ./export --mesh --output $map_dir/$i/$version/rtab_mesh --outname $out_name $out_dir/database.$out_name.db
			srun --mem=40GB ./export --texture --output $map_dir/$i/$version/rtab_texture --outname $out_name $out_dir/database.$out_name.db
			break

		done
	done
done

echo all done!
