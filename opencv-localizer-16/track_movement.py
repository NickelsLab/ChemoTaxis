#!/usr/bin/python
import numpy as np
import cv2

# chnage this if you move the camera
roi = (119,765,507,1172)

bkgnd = cv2.imread('bkgrnd.jpg',0)
#bkgnd = bkgnd[roi[0]:roi[1],roi[2]:roi[3]] # grab the part we care about

cv2.namedWindow('overhead')
#cv2.namedWindow('overhead',cv2.WINDOW_NORMAL)
#cv2.namedWindow('overhead',cv2.WINDOW_OPENGL)
#cv2.namedWindow('overhead',cv2.WINDOW_AUTOSIZE)

blobParams = cv2.SimpleBlobDetector_Params()
#params.filterByInertia = True
#params.minInertiaRatio = 0.01
blobParams.filterByArea = True
blobParams.minArea = 20
blobParams.maxArea = 500
blobAnalysis = cv2.SimpleBlobDetector(blobParams)

t=1
while t<=3:
    fname = 'frame0'+str(t)+'.jpg'
    frame = cv2.imread(fname,0)
    if frame==None:
        raise ImportError('Couldnt find file:'+fname)
        break
    else:
        print "Read image: ",fname
    #frame = frame[roi[0]:roi[1],roi[2]:roi[3]] # grab the part we care about

    diffimg = 128 + bkgnd - frame
    absdiff = abs(diffimg.astype(int)-128)
    absdiff = absdiff.astype(np.uint8)

    thresh = absdiff.max()/2.0
    ret,absdiff = cv2.threshold(absdiff,absdiff.max()/2,255,cv2.THRESH_BINARY)
    blobs = blobAnalysis.detect(absdiff)

    cv2.imshow('overhead',absdiff)
    cv2.namedWindow('blobs')
    # Draw detected blobs as red circles.
    # cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS ensures the size of the
    # circle corresponds to the size of blob
    im_with_keypoints = cv2.drawKeypoints(absdiff, blobs, np.array([]),
            (0,0,255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

    print len(blobs)," blobs found"
    print "sizes: "
    for i in range(0,len(blobs)):
        print blobs[i].pt, ": ",blobs[i].size
        cv2.circle(im_with_keypoints,(int(blobs[i].pt[0]),int(blobs[i].pt[1])), 20, (0,0,255), -1)

    cv2.imshow('blobs',im_with_keypoints)
    
    cv2.waitKey(0)
    cv2.destroyWindow('blobs')

    t+=1

cv2.destroyAllWindows()
