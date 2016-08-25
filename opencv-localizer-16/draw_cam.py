#!/usr/bin/python
import numpy as np
import cv2

cap = cv2.VideoCapture(0)

while(True):
    # Capture frame-by-frame
    ret, frame = cap.read()
    # Our operations on the frame come here
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    #gray = np.zeros((512,512,3),np.uint8)


    # draw stuff - cv2.line(), cv2.circle() , cv2.rectangle(),
    # cv2.ellipse(), cv2.putText() etc.
    cv2.line(gray,(0,0),(511,511),(255,0,0),5)
    cv2.rectangle(gray,(384,0),(510,128),(0,255,0),3)
    cv2.circle(gray,(447,63), 63, (0,0,255), -1)
    cv2.ellipse(gray,(256,256),(100,50),0,0,180,255,-1)
    pts = np.array([[10,5],[20,30],[70,20],[50,10]], np.int32)
    pts = pts.reshape((-1,1,2))
    cv2.polylines(gray,[pts],True,(0,255,255))
    font = cv2.FONT_HERSHEY_SIMPLEX
    cv2.putText(gray,'OpenCV',(10,500), font, 4,(255,255,255),2)

    # Display the resulting frame
    cv2.imshow('frame',gray)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()
