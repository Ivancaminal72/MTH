#!/bin/bash
path="/imatge/icaminal/datasets/TUM_rgbd"
out_dir="/imatge/icaminal/results/kintinuous"
out_file="$out_dir/ate_tum.csv"
seq_a=("rgbd_dataset_freiburg1_desk" 
	 "rgbd_dataset_freiburg1_room" 
	 "rgbd_dataset_freiburg2_desk"
     "rgbd_dataset_freiburg2_large_no_loop"
	 "rgbd_dataset_freiburg2_pioneer_slam2"
     "rgbd_dataset_freiburg3_long_office_household")
proj_a=("--vertical" 
		"--vertical" 
		"--vertical" 
		"" 
		"" 
		"--threedim")
dot_a=("i" "r" "if" "rf" "ri" "rif")

rm -f $out_file
mkdir -p $out_dir

for ((i=0;i<${#seq_a[@]};++i)); do
	seq_dir=$path/${seq_a[i]}
	cd $seq_dir

    echo -e "\n\n Evaluating ate sequence: $seq_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		
		in_name="log.klg.5000.poses.${dot_a[j]}"
		
		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]};" | tee -a $out_file

		#Without loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py --verbose ./groundtruth.txt ./${in_name} ${proj_a} --plot plot.${dot_a[j]}.png | tee -a $out_file

		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]}.od;" | tee -a $out_file

		#With loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py --verbose ./groundtruth.txt ./${in_name}.od ${proj_a} --plot plot.${dot_a[j]}.od.png | tee -a $out_file

	done
done
