#!/bin/bash
source ~/workspace/install/modules_tool_png_to_klg.sh
path="/imatge/icaminal/datasets/iclnuim/living-room"
cd /imatge/icaminal/workspace/adapt/png_to_klg/build
for ((i=0;i<4;++i)); do

	seq_dir=$path/$i/"orig_tum"
	
    echo -e "\n\n Processing sequence: $seq_dir"
	srun -c1 --mem=8G ./pngtoklg -w $seq_dir

	seq_dir=$path/$i/"noise_tum"
	
    echo -e "\n\n Processing sequence: $seq_dir"
	srun -c1 --mem=8G ./pngtoklg -w $seq_dir
done

echo all done!
