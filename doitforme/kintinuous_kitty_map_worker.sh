#!/bin/bash
downsampling=1
map_dir="/work/icaminal/reconstructions/kitty"
path="/imatge/icaminal/datasets/kitty/generated"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "22") 
#test_a=("" "-r" "-fod" "-fod -r" "-ri" "-fod -ri")
#dot_a=("i" "r" "if" "rf" "ri" "rif")
test_a=("-r")
dot_a=("r")

sensor=visible
#sensor=infrared #infrared 

source ~/workspace/install/modules_kintinuous.sh
cd /imatge/icaminal/workspace/Kintinuous/src/build

for ((i=0;i<${#seq_a[@]};++i)); do
	seq_dir=$path/${seq_a[i]}_${downsampling}
	#seq_dir=$path/${seq_a[i]} #for downsampling2 us this (the script was thought later...)
	calib=$path/${seq_a[i]}/calib_${downsampling}.000000.txt.scaled
	
	maps=$map_dir/$sensor/kint/${seq_a[i]}
	logs=$map_dir/$sensor/kint/${seq_a[i]}/worker
	rm -fr $maps
	mkdir -p $logs

    echo -e "\n\n Running sequence: $seq_dir"

	for ((j=0;j<${#test_a[@]};++j)); do
		
		printf "\n${dot_a[j]} "

		#Without loop closure
		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $seq_dir/${downsampling}.klg.10922 ${test_a[j]} -c $calib -t 16 -cw 1 -m -f > $logs/out.${dot_a[j]}.txt 2> $logs/err.${dot_a[j]}.txt
		rm -f $seq_dir/${downsampling}.klg.10922.poses
		mv $seq_dir/${downsampling}.klg.10922.pcd $maps/${downsampling}.klg.10922.${dot_a[j]}.pcd
		mv $seq_dir/${downsampling}.klg.10922.ply $maps/${downsampling}.klg.10922.${dot_a[j]}.ply

		printf "\n${dot_a[j]}.od "

#		#With loop closure
#		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $seq_dir/${downsampling}.klg.10922 ${test_a[j]} -od -c $calib -t 16 -cw 1 -m > $logs/out.${dot_a[j]}.od.txt 2> $logs/err.${dot_a[j]}.od.txt
#		rm -f $seq_dir/${downsampling}.klg.10922.poses
#		mv $seq_dir/${downsampling}.klg.10922_opt.pcd $maps/${downsampling}.klg.10922.${dot_a[j]}.od.pcd
#		mv $seq_dir/${downsampling}.klg.10922_opt.ply $maps/${downsampling}.klg.10922.${dot_a[j]}.od.ply

	done
done

echo all done!
