#!/usr/bin/python
import numpy as np
import cv2

cap = cv2.VideoCapture(0)

# Capture frame-by-frame
ret, frame = cap.read()
# Our operations on the frame come here
gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

cv2.imwrite('frame.jpg',gray)

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()
