#!/bin/bash
source ~/workspace/install/modules_adapt_kitty_to_png.sh
ID=0
downsampling=1
while [ "$ID" -lt 10 ]
do
    echo $ID
	srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/KITTY/kitty_to_png/build/kitty_to_png -r 120 -d $downsampling -i /imatge/icaminal/projects/world3d/2018-slam/kitty/ -o /imatge/icaminal/projects/world3d/2018-slam/kitty/generated/ -s 0$ID
    (( ID++ ))
done
ID=10
echo $ID
srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/KITTY/kitty_to_png/build/kitty_to_png -r 120 -d $downsampling -i /imatge/icaminal/projects/world3d/2018-slam/kitty/ -o /imatge/icaminal/projects/world3d/2018-slam/kitty/generated/ -s $ID
ID=22
echo $ID
srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/KITTY/kitty_to_png/build/kitty_to_png -r 120 -d $downsampling -i /imatge/icaminal/projects/world3d/2018-slam/kitty/ -o /imatge/icaminal/projects/world3d/2018-slam/kitty/generated/ -s $ID

echo all done!
