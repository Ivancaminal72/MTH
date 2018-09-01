#!/bin/bash
source ~/workspace/install/modules_icl.sh
map_dir="/work/icaminal/reconstructions/icl"
out_dir="/imatge/icaminal/results/kintinuous"
out_file="$out_dir/surfreg_icl.csv"

#rm -f $out_file
#mkdir -p $out_dir

#version="orig_tum"

#for ((i=0;i<4;++i)); do
#	cd $map_dir/$i/$version/kint_cloud/
#	for filename in ./*; do
#		printf "\n$filename;" | tee -a $out_file 
#		printf "$version;" | tee -a $out_file 
#		printf "$i;" | tee -a $out_file 
#		srun --x11 --mem=4G --gres=gpu:1 vglrun ~/workspace/metrics_eval/SurfReg/build/SurfReg -r $filename -m ~/datasets/ICL-NUIM_synthetic/living-room/model.ply -t $i -o $out_file
#	done
#done

#version="noise_tum"

#for ((i=0;i<4;++i)); do
#	cd $map_dir/$i/$version/kint_cloud/
#	for filename in ./*; do
#		printf "\n$filename;" | tee -a $out_file 
#		printf "$version;" | tee -a $out_file 
#		printf "$i;" | tee -a $out_file 
#		srun --x11 --mem=4G --gres=gpu:1 vglrun ~/workspace/metrics_eval/SurfReg/build/SurfReg -r $filename -m ~/datasets/ICL-NUIM_synthetic/living-room/model.ply -t $i -o $out_file
#	done
#done

out_dir="/imatge/icaminal/results/rtabmap"
out_file="$out_dir/surfreg_icl.csv"

rm -f $out_file
mkdir -p $out_dir

version="orig_tum"

for ((i=0;i<4;++i)); do
	cd $map_dir/$i/$version/rtab_cloud
	for filename in ./*; do
		printf "\n$filename;" | tee -a $out_file
		printf "$version;" | tee -a $out_file 
		printf "$i;" | tee -a $out_file 
		srun --x11 --mem=4G --gres=gpu:1 vglrun ~/workspace/metrics_eval/SurfReg/build/SurfReg -r $filename -m ~/datasets/ICL-NUIM_synthetic/living-room/model.ply -t $i -o $out_file
	done
done

version="noise_tum"

for ((i=0;i<4;++i)); do
	cd $map_dir/$i/$version/rtab_cloud
	for filename in ./*; do
		printf "\n$filename;" | tee -a $out_file
		printf "$version;" | tee -a $out_file  
		printf "$i;" | tee -a $out_file 
		srun --x11 --mem=4G --gres=gpu:1 vglrun ~/workspace/metrics_eval/SurfReg/build/SurfReg -r $filename -m ~/datasets/ICL-NUIM_synthetic/living-room/model.ply -t $i -o $out_file
	done
done



