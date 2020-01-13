#!/bin/bash
map_dir="/work/icaminal/reconstructions/kitti"
path="/imatge/icaminal/datasets/kitti/generated"
source ~/workspace/install/modules_rtabmap.sh

#seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10")
seq_a=("07")

#version=rtab_1_infrared #infrared
#version=rtab_1_infrared_scaled #infrared SCALED
version=rtab_1
#version=rtab_1_scaled #SCALED

scaled="unscaled"
#scaled="scaled" #SCALED

sensor=visible
#sensor=infrared #infrared

mode="fix"
#mode="adaptive"

cd /imatge/icaminal/workspace/export_rtab-map/build
for ((i=0;i<${#seq_a[@]};++i)); do
	gen_dir=$path/${seq_a[i]}_${version}
	calib=$path/calib${flip}.txt	

	maps=$map_dir/$sensor/rtab/${scaled}/${mode}/${seq_a[i]}
	logs=$map_dir/$sensor/rtab/${scaled}/${mode}/${seq_a[i]}/worker

	rm -fr $maps
	mkdir -p $logs
	
    echo -e "\n\n Processing sequence: $gen_dir"
	for filepath in $gen_dir/*; do
			name=$(basename -- "$filepath");
			extension=${filepath/*./}
			if [ "$extension" == "db" ]; then
				if [[ "$name" == *"od"* ]]; then
					#srun --mem=30GB ./export --output $maps --outname $name ${filepath} > $logs/out.$name.txt
					srun --mem=30GB ./export --mesh --output $maps --outname $name ${filepath} > $logs/out.$name.txt
					#srun --mem=30GB ./export --texture --output $maps --outname $name ${filepath} > $logs/out.$name.txt
				fi
			fi
	done
done

echo all done!
