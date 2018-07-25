#!/bin/bash
path="/imatge/icaminal/datasets/TUM_rgbd"
seq_a=("rgbd_dataset_freiburg1_360" 
	 "rgbd_dataset_freiburg1_desk" 
	 "rgbd_dataset_freiburg1_room" 
	 "rgbd_dataset_freiburg2_desk" 
	 "rgbd_dataset_freiburg2_large_no_loop")
dot_a=("i" "r" "if" "rf" "ri" "rif")

for ((i=0;i<${#seq_a[@]};++i)); do
	seq_dir=$path/${seq_a[i]}
	cd $seq_dir
    echo -e "\n\n Evaluating ate sequence: $seq_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		
		printf "\n${dot_a[j]} "

		#Without loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py --verbose  ./log.klg.5000.poses.r ./groundtruth.txt --plot plot.r.png | tee ate.rpython ~/workspace/metrics_eval/evaluate_ate.py --verbose  ./2.klg.10922.poses.${dot_a[j]} ./groundtruth.txt --plot plot.${dot_a[j]}.png | tee ate.${dot_a[j]}

		printf "\n${dot_a[j]}.od "

		#With loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py --verbose  ./log.klg.5000.poses.r ./groundtruth.txt --plot plot.r.png | tee ate.rpython ~/workspace/metrics_eval/evaluate_ate.py --verbose  ./log.klg.5000.poses.${dot_a[j]}.od ./groundtruth.txt --plot plot.${dot_a[j]}.png | tee ate.${dot_a[j]}.od

	done
done
