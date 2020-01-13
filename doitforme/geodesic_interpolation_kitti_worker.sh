#!/bin/bash
module purge
module load opencv
path="/projects/world3d/2018-slam/kitti/generated"
seq_a=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10")
source ~/workspace/install/modules_icl.sh

for ((i=0;i<${#seq_a[@]};++i)); do
	pathseq="$path/${seq_a[i]}"
	rm -rf $pathseq/infrared_mint/ && mkdir -p $pathseq/infrared_mint/
	rm -rf $pathseq/infrared_mint_three/ && mkdir -p $pathseq/infrared_mint_three/
	count=0
	for imgpath in $pathseq/infrared/*; do
		echo "Processing sequence: ${seq_a[i]}   Frame: $count"		
		convert $imgpath $imgpath.ras
		/imatge/josep/workspace/softimage/bin/release_noxml2_nofftw3/B_EX_MINT $imgpath.ras ${imgpath}.ras 8
		filename=$(basename -- "$imgpath"); 
		convert $imgpath.ras $pathseq/infrared_mint/$filename
		rm -f $imgpath.ras
		~/workspace/adapt/three_channels/build/three_channels $pathseq/infrared_mint/$filename $pathseq/infrared_mint_three/$filename
		((count++))
	done
	
	cp $pathseq/associations.txt $pathseq/associations_visible.txt 
	sed -i 's:./visible/:./infrared_mint_three/:g' $pathseq/associations.txt
	sed 's/infrared.png/infrared_mint_three.png/g' $pathseq/infrared.txt > $pathseq/infrared_mint_three.txt 

done

echo all done!
