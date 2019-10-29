#!/bin/bash
map_dir="/work/icaminal/reconstructions/icl"
path="/imatge/icaminal/datasets/ICL-NUIM_synthetic/living-room"
source ~/workspace/install/modules_kintinuous.sh
cd /imatge/icaminal/workspace/Kintinuous/src/build

test_a=(" " "-r" "-fod" "-fod -r" "-ri" "-fod -ri") 
dot_a=("i" "r" "if" "rf" "ri" "rif")

version="orig_tum"
#version="noise_tum"

for ((i=2;i<3;++i)); do
	rm -fr $path/$i/$version/worker/
	rm -fr $map_dir/$i/$version/kint_*
	mkdir -p $path/$i/$version/worker/
	mkdir -p $map_dir/$i/$version/kint_poses/
	mkdir -p $map_dir/$i/$version/kint_cloud/
	mkdir -p $map_dir/$i/$version/kint_mesh/
	echo -e "\n\n Running sequence: $i - $version"
	
	for ((j=0;j<${#dot_a[@]};++j)); do
		
		printf "\n${dot_a[j]} "

		#Without loop closure
		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $path/$i/$version/log_5000.klg ${test_a[j]} -c $path/calib.txt -m > $path/$i/$version/worker/out.${dot_a[j]}.txt 2> $path/$i/$version/worker/err.${dot_a[j]}.txt
		mv $path/$i/$version/log_5000.klg.poses $map_dir/$i/$version/kint_poses/log_5000.klg.poses.${dot_a[j]}
		mv $path/$i/$version/log_5000.klg.pcd $map_dir/$i/$version/kint_cloud/log_5000.klg.pcd.${dot_a[j]}
		mv $path/$i/$version/log_5000.klg.ply $map_dir/$i/$version/kint_mesh/log_5000.klg.ply.${dot_a[j]}

		printf "\n${dot_a[j]}.od "

		#With loop closure
		srun --x11 --mem=16GB -c4 --gres=gpu:maxwell:1 vglrun ./Kintinuous -v ../../vocab.yml.gz -l $path/$i/$version/log_5000.klg ${test_a[j]} -od -c $path/calib.txt -m > $path/$i/$version/worker/out.${dot_a[j]}.od.txt 2> $path/$i/$version/worker/err.${dot_a[j]}.od.txt1
		mv $path/$i/$version/log_5000.klg.poses $map_dir/$i/$version/kint_poses/log_5000.klg.poses.${dot_a[j]}.od
		mv $path/$i/$version/log_5000.klg_opt.pcd $map_dir/$i/$version/kint_cloud/log_5000.klg.pcd.${dot_a[j]}.od
		mv $path/$i/$version/log_5000.klg_opt.ply $map_dir/$i/$version/kint_mesh/log_5000.klg.ply.${dot_a[j]}.od
	done
done

echo all done!
