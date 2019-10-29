#!/usr/bin/python
import numpy as np
import cv2
import time
from matplotlib import pyplot as plt

#path="/imatge/icaminal/datasets/Beamagine/3captures_30-08-2018/generated/02/infrared_mint_three/"
path="/imatge/icaminal/datasets/kitty/generated/07/infrared_mint_three/"
import os
for file in sorted(os.listdir(path)):
    if file.endswith(".png"):
        img = cv2.imread(path+file)
        gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

        corners = cv2.goodFeaturesToTrack(gray,1500,0.1,6)
        corners = np.int0(corners)

        print(corners.size)

        for i in corners:
            x,y = i.ravel()
            cv2.circle(img,(x,y),3,255,-1)

        plt.imshow(img)
        plt.pause(0.5)

plt.show()
