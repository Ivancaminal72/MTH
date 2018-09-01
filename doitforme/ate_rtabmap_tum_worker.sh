#!/bin/bash
kpfeat="test"
path="/imatge/icaminal/datasets/TUM_rgbd"
out_dir="/imatge/icaminal/results/rtabmap"
out_file="$out_dir/ate_tum_${kpfeat}.csv"

seq_a=("rgbd_dataset_freiburg1_desk" 
	 "rgbd_dataset_freiburg1_room" 
	 "rgbd_dataset_freiburg2_desk"
     "rgbd_dataset_freiburg2_large_no_loop"
	 "rgbd_dataset_freiburg2_pioneer_slam2"
     "rgbd_dataset_freiburg3_long_office_household")
proj_a=("--threedim" 
		"--vertical" 
		"--vertical" 
		"" 
		"" 
		"--threedim")
inlier_dist_a=("0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1" "0.1") #FIXED
cal_a=("1" "1" "2" "2" "2" "3")

dot_a=("f2m")

rm -f $out_file
mkdir -p $out_dir

for ((i=0;i<${#seq_a[@]};++i)); do
	seq_dir=$path/${seq_a[i]}_rtab_1
	orig_seq_dir=$path/${seq_a[i]}
	cd $seq_dir
	
    echo -e "\n\n Evaluating ate sequence: $seq_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		#inlier_dist_a=("0.035" "0.015" "0.005" "0.030" "0.210" "0.005") #surf_orb
		#inlier_dist_a=("0.025" "0.010" "0.005" "0.025" "0.470" "0.005") #gftt_brief (1) 
		in_name="rtabmap.poses.${inlier_dist_a[i]}.${dot_a[j]}"
		
		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]};" | tee -a $out_file
		printf "${inlier_dist_a[i]};" | tee -a $out_file

		#Without loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py --verbose $orig_seq_dir/groundtruth.txt ./${in_name} ${proj_a[i]} --plot plot.${dot_a[j]}.${kpfeat}.png | tee -a $out_file
		
		#inlier_dist_a=("0.025" "0.015" "0.005" "0.025" "0.400" "0.005") #surf_orb.od
		#inlier_dist_a=("0.020" "0.010" "0.005" "0.030" "0.485" "0.005") #gftt_brief (1) 
		in_name="rtabmap.poses.${inlier_dist_a[i]}.${dot_a[j]}"
		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]}.od;" | tee -a $out_file
		printf "${inlier_dist_a[i]};" | tee -a $out_file

		#With loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py	--verbose $orig_seq_dir/groundtruth.txt ./${in_name}.od ${proj_a[i]} --plot plot.${dot_a[j]}.${kpfeat}.od.png | tee -a $out_file

	done
done
