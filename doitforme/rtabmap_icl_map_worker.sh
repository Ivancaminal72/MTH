#!/bin/bash
map_dir="/work/icaminal/reconstructions/icl"
path="/imatge/icaminal/datasets/ICL-NUIM_synthetic/living-room"
inlier_dist_a=("0.005" "0.005" "0.005" "0.005")
source ~/workspace/install/modules_rtabmap.sh
cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build

max_inlierdist=0.3
dot_a=("f2m")
for ((i=0;i<4;++i)); do

	seq_dir=$path/$i/"orig_tum"
	#seq_dir=$path/$i/"noise_tum"
	out_dir=$path/generated/${i}_rtab
	calib=$path/calib.txt
	rm -fr $out_dir
	mkdir -p $out_dir/worker/
	
    echo -e "\n\n Processing sequence: $seq_dir"
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
			--GFTT/QualityLevel 0.0005 \
			--GFTT/MinDistance 3 \
			--Odom/Strategy 0 \
			--OdomF2M/MaxSize 3000 \
			--Kp/MaxFeatures 750 \
			--Vis/CorType 0 \
			--Vis/FeatureType 6\
			--Vis/MaxFeatures 1500 \
			--Vis/EstimationType 0 \
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
				exit
			fi
			
			rm -fr $map_dir/$i
			mkdir -p $map_dir/$i

			cd /imatge/icaminal/workspace/export_rtab-map/build
			srun-fast --mem=GB ./export --output $map_dir/$i --outname $out_name $out_dir/database.$out_name.db
			srun-fast --mem=GB ./export --mesh --output $map_dir/$i --outname $out_name $out_dir/database.$out_name.db
			srun-fast --mem=GB ./export --texture --output $map_dir/$i --outname $out_name $out_dir/database.$out_name.db

		done
	done
done

echo all done!
