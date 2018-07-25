#!/bin/bash
path="/imatge/icaminal/datasets/kitty/generated"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "22") 
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
