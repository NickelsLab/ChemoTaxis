#!/usr/bin/python
import numpy as np
import cv2

img = cv2.imread('bkgrnd.jpg',0)
img = cv2.resize(img,(0,0),fx=0.5,fy=0.5);
cv2.namedWindow('title',cv2.WINDOW_NORMAL)
#cv2.namedWindow('title',cv2.WINDOW_OPENGL)
cv2.resizeWindow('title',640,480)
cv2.imshow('title',img)
k=cv2.waitKey(0)
cv2.destroyAllWindows()

# save image
if k & 0xFF==ord('s'): # wait for 's' key to save
    cv2.imwrite('bkgrnd_grey.jpg',img)

# plot image
from matplotlib import pyplot as plt
if k & 0xFF == ord('p'):
    plt.imshow(img,cmap = 'gray', interpolation = 'bicubic')
    #plt.xticks([]), plt.yticks([]) # to hid tick values on X and Y axis
    plt.show()
