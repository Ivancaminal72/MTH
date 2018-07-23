#!/bin/bash
ID=0
while [ "$ID" -lt 10 ]
do
    echo $ID
	./build/pngtoklg -w ~/datasets/kitty/generated/0$ID/ -c ~/datasets/kitty/generated/0$ID/calib_2.000000.txt -o ~/datasets/kitty/generated/0$ID/2.klg -s 10922.66666
    (( ID++ ))
done
ID=10
echo $ID
./build/pngtoklg -w ~/datasets/kitty/generated/$ID/ -c ~/datasets/kitty/generated/$ID/calib_2.000000.txt -o ~/datasets/kitty/generated/$ID/2.klg -s 10922.66666
ID=22
echo $ID
./build/pngtoklg -w ~/datasets/kitty/generated/$ID/ -c ~/datasets/kitty/generated/$ID/calib_2.000000.txt -o ~/datasets/kitty/generated/$ID/2.klg -s 10922.66666

echo all done!
