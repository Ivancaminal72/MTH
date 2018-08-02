#!/bin/bash
downsampling=1
path="/imatge/icaminal/datasets/kitty/generated"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10") 
test_a=("" "-r" "-fod" "-fod -r" "-ri" "-fod -ri")
dot_a=("orig")
max_inlierdist=10

source ~/workspace/install/modules_rtabmap.sh
cd /imatge/icaminal/workspace/rgbd-dataset_rtab-map/build

for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$path/${seq_a[i]}
	out_dir=${gen_dir}_rtab_${downsampling}
	#gen_dir=$path/${seq_a[i]} #for downsampling2 us this (the script was thought later...)
	calib=$path/${seq_a[i]}/calib_${downsampling}.000000.txt
	rm -fr $out_dir
	mkdir -p $out_dir/worker/
    echo -e "\n\n Running sequence: $gen_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		inlierdist=0.1
		while true
		do
			out_name=$downsampling.rtabmap.poses.$inlierdist.${dot_a[j]}
			printf "\n${dot_a[j]} "
			printf "\nTrying inlier distance --> $inlierdist\n"

			#Without loop closure
			srun-fast --mem=8GB -c 4 ./rgbd_dataset \
			--output $out_dir \
			--outname $out_name \
			--imagename "visible"\
			--depthname "depth"\
			--calibfile $calib \
			--poses ${dot_a[j]} \
			--times /imatge/icaminal/datasets/kitty/sequences/${seq_a[i]}/times.txt \
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
				inlierdist=$(echo "$inlierdist 0.1" | awk '{printf "%.1f", $1+$2}')
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