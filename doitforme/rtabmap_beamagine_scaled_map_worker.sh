#!/bin/bash
kpfeat=gftt_brief
capture="3captures_30-08-2018" #DATASET CAPTURES
map_dir="/work/icaminal/reconstructions/beamagine"
path="/work/icaminal/datasets/Beamagine/${capture}/generated"
seq_a=("01" "02" "03" "04" "05" "06" "07" "08")

dot_a=("f2m")
#inlier_dist_a=("0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02" "0.02") #SCALED
inlier_dist_a=("2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2" "2")
source ~/workspace/install/modules_rtabmap.sh

#max_inlierdist=0.3 #SCALED
max_inlierdist=6
#depth_scale=27 #SCALED
depth_scale=1
gftt_dist=6
sensor=infrared
scaled="unscaled"
#scaled="scaled" #SCALED

for ((i=0;i<${#seq_a[@]};++i)); do
	cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build
	seq_dir=$path/${seq_a[i]}
	#out_dir=$path/${seq_a[i]}_rtab_${sensor}_scaled #SCALED
	out_dir=$path/${seq_a[i]}_rtab_${sensor}
	calib=$seq_dir/calib.txt
	rm -fr $out_dir
	mkdir -p $out_dir/worker/
	
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
			--imagename "infrared_mint_three"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--scale ${depth_scale} \
			--depthfactor 0.397187 \
			--times "none" \
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
			--Vis/FeatureType 6 \
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
				inlierdist=$(echo "$inlierdist 0.02" | awk '{printf "%2f", $1+$2}')
				#break #NO TUNE INLIER DIST#######------------#############
				continue
				rm -f $out_dir/$out_name
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]]
			then 
				rm -f $out_dir/$out_name
				break
			else
				continue 
			fi			
			
			maps=$map_dir/$capture/$sensor/rtab/${scaled}/${seq_a[i]}
			logs=$map_dir/$capture/$sensor/rtab/${scaled}/${seq_a[i]}/worker

			rm -fr $maps
			mkdir -p $logs

			cd /imatge/icaminal/workspace/export_rtab-map/build
			srun --mem=20GB ./export --output $maps --outname $out_name $out_dir/database.$out_name.db > $logs/out.cloud.$out_name.txt
			srun --mem=20GB ./export --mesh --output $maps --outname $out_name $out_dir/database.$out_name.db > $logs/out.mesh.$out_name.txt
			#srun --mem=20GB ./export --texture --output $maps --outname $out_name $out_dir/database.$out_name.db > $logs/out.texture.$out_name.txt
			break

		done
	done
done

echo "done until no od!"
exit

for ((i=0;i<${#seq_a[@]};++i)); do
	cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build
	seq_dir=$path/${seq_a[i]}
	#out_dir=$path/${seq_a[i]}_rtab_${sensor}_scaled #SCALED
	out_dir=$path/${seq_a[i]}_rtab_${sensor}
	calib=$seq_dir/calib.txt
	mkdir -p $out_dir/worker/
	
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
			--imagename "infrared_mint_three"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--scale ${depth_scale} \
			--depthfactor 0.397187 \
			--times "none" \
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
			--Vis/FeatureType 6 \
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
				inlierdist=$(echo "$inlierdist 0.02" | awk '{printf "%2f", $1+$2}')
				#break #NO TUNE INLIER DIST#######------------#############
				continue
				rm -f $out_dir/$out_name
			elif [[ $(echo "$inlierdist $max_inlierdist" | awk '{printf ($1>$2)}') -eq 1 ]]
			then 
				rm -f $out_dir/$out_name
				break
			else
				continue
			fi

			maps=$map_dir/$capture/$sensor/rtab/${scaled}/${seq_a[i]}
			logs=$map_dir/$capture/$sensor/rtab/${scaled}/${seq_a[i]}/worker

			rm -fr $maps/*.od.*
			mkdir -p $logs

			cd /imatge/icaminal/workspace/export_rtab-map/build
			srun --mem=20GB ./export --output $maps --outname $out_name $out_dir/database.$out_name.db > $logs/out.cloud.$out_name.txt
			srun --mem=20GB ./export --mesh --output $maps --outname $out_name $out_dir/database.$out_name.db > $logs/out.mesh.$out_name.txt
			#srun --mem=20GB ./export --texture --output $maps --outname $out_name $out_dir/database.$out_name.db > $logs/out.texture.$out_name.txt
			break

		done
	done
done

echo all done!
