# measure_speed.py

import math
import random
import time
import datetime
import matplotlib.pyplot as plt
import numpy as np

import sys, os
# this should be whereever "playercpp.py" is.  
# On linux, you can find this out with "locate playercpp.py"
sys.path.append('/usr/local/lib/python2.7/site-packages/')
sys.path.append('/usr/local/lib64/python2.7/site-packages/')
from playercpp import *


if __name__ == "__main__":

	fig = plt.figure(1,figsize=(4,4))
	ax = fig.add_subplot(111)
	fig.show()
	xpos = np.array([])
	ypos = np.array([])

	robot = PlayerClient("localhost")
	pp = Position2dProxy(robot,0)
	sp = SimulationProxy(robot,0)

	robot.Read()	 # read from the proxies

	#pp.SetSpeed(0.0,900*math.pi/180.0) # spin
	pp.SetSpeed(10.0,0*math.pi/180.0) # move forward 

	pos_x = pp.GetXPos()
	pos_y = pp.GetYPos()
	pos_yaw = pp.GetYaw()
	pos_t = pp.GetDataTime()
	robot.Read()	 # read from the proxies
	print 'robot went %.3f micron and %f rad (%d deg) in %.3f ms' %\
			(math.sqrt((pp.GetXPos()-pos_x)**2+(pp.GetYPos()-pos_y)**2),\
			(pp.GetYaw()-pos_yaw),\
			180/math.pi*(pp.GetYaw()-pos_yaw),\
			1e3*(pp.GetDataTime()-pos_t))

	pos_x = pp.GetXPos()
	pos_y = pp.GetYPos()
	pos_yaw = pp.GetYaw()
	pos_t = pp.GetDataTime()
	robot.Read()	 # read from the proxies
	print 'robot went %.3f micron and %f rad (%d deg) in %.3f ms' %\
			(math.sqrt((pp.GetXPos()-pos_x)**2+(pp.GetYPos()-pos_y)**2),\
			(pp.GetYaw()-pos_yaw),\
			180/math.pi*(pp.GetYaw()-pos_yaw),\
			1e3*(pp.GetDataTime()-pos_t))

	pos_x = pp.GetXPos()
	pos_y = pp.GetYPos()
	pos_t = pp.GetDataTime()
	pos_yaw = pp.GetYaw()
	robot.Read()	 # read from the proxies
	print 'robot went %.3f micron and %f rad (%d deg) in %.3f ms' %\
			(math.sqrt((pp.GetXPos()-pos_x)**2+(pp.GetYPos()-pos_y)**2),\
			(pp.GetYaw()-pos_yaw),\
			180/math.pi*(pp.GetYaw()-pos_yaw),\
			1e3*(pp.GetDataTime()-pos_t))


	pos_x = pp.GetXPos()
	pos_y = pp.GetYPos()
	pos_t = pp.GetDataTime()
	pos_yaw = pp.GetYaw()
	robot.Read()	 # read from the proxies
	print 'robot went %.3f micron and %f rad (%d deg) in %.3f ms' %\
			(math.sqrt((pp.GetXPos()-pos_x)**2+(pp.GetYPos()-pos_y)**2),\
			(pp.GetYaw()-pos_yaw),\
			180/math.pi*(pp.GetYaw()-pos_yaw),\
			1e3*(pp.GetDataTime()-pos_t))


	for i in range(10):
		robot.Read()	 # read from the proxies
		xpos = np.append(xpos,pp.GetXPos())
		ypos = np.append(ypos,pp.GetYPos())
		plt.plot(xpos,ypos,'o-')
		plt.ylim((-100,100))
		plt.xlim((-100,100))
		plt.draw()
		plt.cla()
		print "robot at %f,%f\n" % (pp.GetXPos(),pp.GetYPos())

	pp.SetSpeed(0.0,0.0) # move forward at 1.0 m/s, 0 rad/s

	#robot.Stop()
	del sp
	del pp
	del robot
