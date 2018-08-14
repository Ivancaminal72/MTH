#!/bin/bash
path="/imatge/icaminal/datasets/TUM_rgbd"
out_dir="/imatge/icaminal/results/rtabmap"
out_file="$out_dir/ate_tum.csv"

seq_a=( "rgbd_dataset_freiburg1_desk" 
	    "rgbd_dataset_freiburg1_room" 
	    "rgbd_dataset_freiburg2_desk" )
inlier_dist_a=("0.1" "0.1" "0.1") 
dot_a=("f2m")

rm -f $out_file
mkdir -p $out_dir

for ((i=0;i<${#seq_a[@]};++i)); do
	seq_dir=$path/${seq_a[i]}_rtab_1
	orig_seq_dir=$path/${seq_a[i]}
	cd $seq_dir

    echo -e "\n\n Evaluating ate sequence: $seq_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		
		in_name="rtabmap.poses.${inlier_dist_a[i]}.${dot_a[j]}"
		
#		printf "\n${seq_a[i]};" | tee -a $out_file		
#		printf "${dot_a[j]};" | tee -a $out_file

#		#Without loop closure
#		python ~/workspace/metrics_eval/evaluate_ate.py --verbose $orig_seq_dir/groundtruth.txt ./${in_name} --plot plot.${dot_a[j]}.png | tee -a $out_file

		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]}.od;" | tee -a $out_file
		printf "${inlier_dist_a[i]};" | tee -a $out_file

		#With loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py --verbose $orig_seq_dir/groundtruth.txt ./${in_name}.od --plot plot.${dot_a[j]}.od.png | tee -a $out_file

	done
done
