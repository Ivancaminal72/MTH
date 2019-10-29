#!/bin/bash
module purge
module load opencv
path="/imatge/icaminal/datasets/Beamagine/3captures_30-08-2018/generated"
source ~/workspace/install/modules_icl.sh

for id in {1..8}; do
	echo -e "\n\nProcessing sequence: $id"	
	pathseq="$path/0$id"
	rm -rf $pathseq/infrared_mint/ && mkdir -p $pathseq/infrared_mint/
	rm -rf $pathseq/infrared_mint_three/ && mkdir -p $pathseq/infrared_mint_three/
	i=0
	for imgpath in $pathseq/infrared/*; do
		echo "Frame: $i"		
		convert $imgpath $imgpath.ras
		/imatge/josep/workspace/softimage/bin/release_noxml2_nofftw3/B_EX_MINT $imgpath.ras ${imgpath}.ras 8
		filename=$(basename -- "$imgpath"); 
		convert $imgpath.ras $pathseq/infrared_mint/$filename
		rm -f $imgpath.ras
		~/workspace/adapt/three_channels/build/three_channels $pathseq/infrared_mint/$filename $pathseq/infrared_mint_three/$filename
		((i++))
	done

	sed -i 's:./infrared/:./infrared_mint_three/:g' $pathseq/associations.txt 
	sed 's/infrared.png/infrared_mint_three.png/g' $pathseq/infrared.txt > $pathseq/infrared_mint_three.txt

done

echo all done!
