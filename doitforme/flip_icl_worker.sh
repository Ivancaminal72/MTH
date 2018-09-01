#!/bin/bash
source ~/workspace/install/modules_icl.sh

#Process orig_tum
for ((i=0;i<4;++i)); do
	srun --mem=2G /imatge/icaminal/workspace/adapt/flip-imgs/build/flip_imgs \
				--seq ~/datasets/ICL-NUIM_synthetic/living-room/$i/orig_tum/ \
				--dat depth,rgb
done


#Process noise_tum
for ((i=0;i<4;++i)); do
	srun --mem=2G /imatge/icaminal/workspace/adapt/flip-imgs/build/flip_imgs \
				--seq ~/datasets/ICL-NUIM_synthetic/living-room/$i/noise_tum/ \
				--dat depth,rgb
done


echo all done!
