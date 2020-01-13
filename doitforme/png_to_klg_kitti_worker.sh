#!/bin/bash
source ~/workspace/install/modules_tool_png_to_klg.sh
path="/imatge/icaminal/datasets/kitti/generated"
downsampling=2
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "22") 
cd /imatge/icaminal/workspace/adapt/png_to_klg/build
for ((i=0;i<${#seq_a[@]};++i)); do

	seq_dir=$path/${seq_a[i]}
	klg_dir=${seq_dir}_${downsampling}

	#rm -rf $klg_dir
	#mkdir $klg_dir

    echo -e "\n\n Processing sequence: $seq_dir"
	srun -c1 --mem=8G ./pngtoklg -w $seq_dir -c $seq_dir/calib_$downsampling.000000.txt -o $klg_dir/$downsampling.klg -s 10922.66666
    (( ID++ ))
done

echo all done!
