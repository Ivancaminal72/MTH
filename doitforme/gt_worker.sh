#!/bin/bash
SLRUM_ARRAY_TASK_ID=0
while [ "$SLRUM_ARRAY_TASK_ID" -lt 10 ]
do
    echo $SLRUM_ARRAY_TASK_ID
    ./build/groundtruth_kitti_to_freiburg -o ~/datasets/kitti/poses/0${SLRUM_ARRAY_TASK_ID}_freiburg.txt -i ~/datasets/kitti/poses/0${SLRUM_ARRAY_TASK_ID}.txt -t ~/datasets/kitti/sequences/0${SLRUM_ARRAY_TASK_ID}/times.txt
    (( SLRUM_ARRAY_TASK_ID++ ))
done
./build/groundtruth_kitti_to_freiburg -i ~/datasets/kitti/poses/10.txt -o ~/datasets/kitti/poses/10_freiburg.txt -t ~/datasets/kitti/sequences/10/times.txt
./build/groundtruth_kitti_to_freiburg -i ~/datasets/kitti/poses/22.txt -o ~/datasets/kitti/poses/22_freiburg.txt -t ~/datasets/kitti/sequences/22/times.txt

echo all done!
