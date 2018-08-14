#!/bin/bash
downsampling=1
path="/imatge/icaminal/datasets/kitty/generated"
out_dir="/imatge/icaminal/results/rtabmap"
out_file="$out_dir/ate_kitty_${downsampling}_scaled.csv" #SCALED surf
#out_file="$out_dir/ate_kitty_${downsampling}_surf.csv"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10") 
#seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "10") #orig
#----seq_a=("02" "03" "04" "05" "06" "07" "08" "10") #SCALED surf
#----seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "10") #surf
#inlier_dist_a=("4.2" "8.0" "1.0" "0.4" "0.5" "0.5" "0.5" "0.2" "0.4" "0.2") #orig
inlier_dist_a=("0.4" "0.8" "0.1" "0.04" "0.12" "0.04" "0.04" "0.02" "0.04" "0.1" "0.02") #SCALED surf (corr)
#inlier_dist_a=("8.0" "3.3" "1.9" "0.6" "0.9" "0.8" "0.8" "0.3" "0.8" "0.3" "0.3") #surf
dot_a=("f2m" )

rm -f $out_file
mkdir -p $out_dir

for ((i=0;i<${#seq_a[@]};++i)); do
	seq_dir=$path/${seq_a[i]}_rtab_${downsampling}_scaled #SCALED
	#seq_dir=$path/${seq_a[i]}_rtab_${downsampling}
	#seq_dir=$path/${seq_a[i]} #for downsampling2 us this (the script was thought later...)
	cd $seq_dir
	rm -f ./*plot*

    echo -e "\n\n Evaluating ate sequence: $seq_dir"

	for ((j=0;j<${#dot_a[@]};++j)); do
		#opt_scale=""
		opt_scale="--scale 20" #SCALED
		#plot="plot.${dot_a[j]}"
		plot="plot.${dot_a[j]}.scaled" #SCALED
				
		#in_name="${downsampling}.rtabmap.poses.${inlier_dist_a[i]}.${dot_a[j]}"
		in_name="${downsampling}.rtabmap.poses.${inlier_dist_a[i]}.${dot_a[j]}.scaled" #SCALED
		
		#Without loop closure		
		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]};" | tee -a $out_file
		printf "${inlier_dist_a[i]};" | tee -a $out_file

		python ~/workspace/metrics_eval/evaluate_ate.py --verbose $opt_scale /imatge/icaminal/datasets/kitty/poses/${seq_a[i]}_freiburg.txt ./${in_name} --plot $plot.png | tee -a $out_file
		
		#With loop closure
		printf "\n${seq_a[i]};" | tee -a $out_file		
		printf "${dot_a[j]}.od;" | tee -a $out_file
		printf "${inlier_dist_a[i]};" | tee -a $out_file

		python ~/workspace/metrics_eval/evaluate_ate.py --verbose $opt_scale /imatge/icaminal/datasets/kitty/poses/${seq_a[i]}_freiburg.txt ./${in_name}.od --plot $plot.od.png | tee -a $out_file

	done
done
