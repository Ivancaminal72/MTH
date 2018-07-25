#!/bin/bash
source ~/workspace/install/modules_tool_png_to_klg.sh
ID=0
downsampling=1
while [ "$ID" -lt 10 ]
do
    echo $ID
	srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/png_to_klg/build/pngtoklg -w ~/datasets/kitty/generated/0$ID/ -c ~/datasets/kitty/generated/0$ID/calib_$downsampling.000000.txt -o ~/datasets/kitty/generated/0${ID}_$downsampling/$downsampling.klg -s 10922.66666
    (( ID++ ))
done
ID=10
echo $ID
srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/KITTY/kitty_to_png/build/pngtoklg -w ~/datasets/kitty/generated/$ID/ -c ~/datasets/kitty/generated/${ID}/calib_$downsampling.000000.txt -o ~/datasets/kitty/generated/${ID}_$downsampling/$downsampling.klg -s 10922.66666
ID=22
echo $ID
srun -c1 --mem=8G /imatge/icaminal/workspace/adapt/KITTY/kitty_to_png/build/pngtoklg -w ~/datasets/kitty/generated/$ID/ -c ~/datasets/kitty/generated/${ID}/calib_$downsampling.000000.txt -o ~/datasets/kitty/generated/${ID}_$downsampling/$downsampling.klg -s 10922.66666

echo all done!
