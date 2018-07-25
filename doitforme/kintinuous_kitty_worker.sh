#!/bin/bash
path="/imatge/icaminal/datasets/kitty/generated"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "22") 
test_a=("" "-r" "-fod" "-fod -r" "-ri" "-fod -ri")
dot_a=("i" "r" "if" "rf" "ri" "rif")

source ~/workspace/install/modules_kintinuous.sh
cd /imatge/icaminal/workspace/Kintinuous/src/build

for ((i=0;i<${#seq_a[@]};++i)); do
	seq_dir=$path/${seq_a[i]}
	rm -fr $seq_dir/worker/
	mkdir $seq_dir/worker/
	rm -f $seq_dir/*poses*
	rm -f $seq_dir/*ate*
	rm -f $seq_dir/*plot*
    echo -e "\n\n Running sequence: $seq_dir"

	for ((j=0;j<${#test_a[@]};++j)); do
		
		printf "\n${dot_a[j]} "

		#Without loop closure
		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $seq_dir/2.klg.10922 ${test_a[j]} -fl -c $seq_dir/calib_2.000000.txt.scaled -t 16 > $seq_dir/worker/out.${dot_a[j]}.txt 2> $seq_dir/worker/err.${dot_a[j]}.od.txt
		mv $seq_dir/2.klg.10922.poses $seq_dir/2.klg.10922.poses.${dot_a[j]}

		printf "\n${dot_a[j]}.od "

		#With loop closure
		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $seq_dir/2.klg.10922 ${test_a[j]} -fl -c $seq_dir/calib_2.000000.txt.scaled -t 16 > $seq_dir/worker/out.${dot_a[j]}.od.txt 2> $seq_dir/worker/err.${dot_a[j]}.od.txt
		mv $seq_dir/2.klg.10922.poses $seq_dir/2.klg.10922.poses.${dot_a[j]}.od

	done
done
