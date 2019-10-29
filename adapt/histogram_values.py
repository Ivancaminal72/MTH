#!/usr/bin/python


from __future__ import print_function
import sys
import numpy as np
import argparse
import cv2
import matplotlib.pyplot as plt

def plot_histogram(vals):
    plt.hist(vals, bins=256, range=(1,255))
    plt.title("Intensity Kitti image 07/000000.png")
    plt.show()

def adjust_gamma(image, gamma=1.0):
	# build a lookup table mapping the pixel values [0, 255] to
	# their adjusted gamma values
	invGamma = 1.0 / gamma
	table = np.array([((i / 255.0) ** invGamma) * 255
		for i in np.arange(0, 256)]).astype("uint8")

	# apply gamma correction using the lookup table
	return cv2.LUT(image, table)

if __name__=="__main__":
    # Lvals=[]
    # for i in range(1,2):
    #     path = "/imatge/icaminal/datasets/Beamagine/3captures_30-08-2018/hist_intensity/0"+str(i)+".txt"
    #     with open(path) as fp:
    #         vals=[]
    #         for line in fp:
    #             act_vals=[]
    #             act_vals = [np.uint32(val) for val in line.split(';') if val.isdigit()]
    #             vals.extend(act_vals)
    #     Lvals.extend(np.array(vals))

    img = cv2.imread("/imatge/icaminal/datasets/kitty/generated/07/infrared_mint_three/000000.png")

    # img = adjust_gamma(img, gamma=1)
    # cv2.imshow("some", img)
    # cv2.waitKey()

    Lvals = np.asarray(img)
    plot_histogram(Lvals.flatten())
