#!/bin/bash
SLRUM_ARRAY_TASK_ID=0
while [ "$SLRUM_ARRAY_TASK_ID" -lt 10 ]
do
    echo $SLRUM_ARRAY_TASK_ID
    ./build/groundtruth_kitty_to_freiburg -o ~/datasets/kitty/poses/0${SLRUM_ARRAY_TASK_ID}_freiburg.txt -i ~/datasets/kitty/poses/0${SLRUM_ARRAY_TASK_ID}.txt -t ~/datasets/kitty/sequences/0${SLRUM_ARRAY_TASK_ID}/times.txt
    (( SLRUM_ARRAY_TASK_ID++ ))
done
./build/groundtruth_kitty_to_freiburg -i ~/datasets/kitty/poses/10.txt -o ~/datasets/kitty/poses/10_freiburg.txt -t ~/datasets/kitty/sequences/10/times.txt

echo all done!
