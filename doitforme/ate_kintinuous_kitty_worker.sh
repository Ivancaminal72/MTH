#!/bin/bash
downsampling=2
path="/imatge/icaminal/datasets/kitty/generated"
out_dir="/imatge/icaminal/results/kintinuous"
out_file="$out_dir/ate_kitty_$downsampling.csv"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10") 
dot_a=("i" "r" "if" "rf" "ri" "rif")

rm -f $out_file
mkdir -p $out_dir

for ((i=0;i<${#seq_a[@]};++i)); do
	#seq_dir=$path/${seq_a[i]}_${downsampling}
	seq_dir=$path/${seq_a[i]} #for downsampling2 us this (the script was thought later...)
	cd $seq_dir

    echo -e "\n\n Evaluating ate sequence: $seq_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		
		in_name="${downsampling}.klg.10922.poses.${dot_a[j]}"
		
		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]};" | tee -a $out_file

		#Without loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py --verbose /imatge/icaminal/datasets/kitty/poses/${seq_a[i]}_freiburg.txt ./${in_name} --plot plot.${dot_a[j]}.png | tee -a $out_file

		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]}.od;" | tee -a $out_file

		#With loop closure
		python ~/workspace/metrics_eval/evaluate_ate.py --verbose /imatge/icaminal/datasets/kitty/poses/${seq_a[i]}_freiburg.txt ./${in_name}.od --plot plot.${dot_a[j]}.od.png | tee -a $out_file

	done
done
