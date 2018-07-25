#!/bin/bash
path="/imatge/icaminal/datasets/TUM_rgbd"
seq_a=("rgbd_dataset_freiburg1_360" 
	 "rgbd_dataset_freiburg1_desk" 
	 "rgbd_dataset_freiburg1_room" 
	 "rgbd_dataset_freiburg2_desk" 
	 "rgbd_dataset_freiburg2_large_no_loop")
cal_a=("1" "1" "1" "2" "2")
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
		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $seq_dir/log.klg.5000 ${test_a[j]} -fl -c ~/datasets/TUM_rgbd/calib_freiburg${cal_a[i]}.txt -s 6 > $seq_dir/worker/out.${dot_a[j]}.txt 2> $seq_dir/worker/err.${dot_a[j]}.od.txt
		mv $seq_dir/log.klg.5000.poses $seq_dir/log.klg.5000.poses.${dot_a[j]}

		printf "\n${dot_a[j]}.od "

		#With loop closure
		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $seq_dir/log.klg.5000 ${test_a[j]} -fl -c ~/datasets/TUM_rgbd/calib_freiburg${cal_a[i]}.txt -s 6 > $seq_dir/worker/out.${dot_a[j]}.od.txt 2> $seq_dir/worker/err.${dot_a[j]}.od.txt
		mv $seq_dir/log.klg.5000.poses $seq_dir/log.klg.5000.poses.${dot_a[j]}.od

	done
done

echo -e "all done!"
