#!/usr/bin/python

# tim_wander.py


# Simple controller that uses principles of chemotaxis
# Get concentration from Dr. Nguyen's function
# Compare, either run or tumble
# Tim Davison Feb 2015

# to run player server - "player tim_bb.cfg" in one window
# to run controller - "python tim_wander.py" in another window

import math
import random
import time
#def dtor (deg):
 #   return deg*math.pi/180.0;
    
import sys, os
# this should be whereever "playercpp.py" is.  
# On linux, you can find this out with "locate playercpp.py"
sys.path.append('/usr/local/lib/python2.7/site-packages/')
sys.path.append('/usr/local/lib64/python2.7/site-packages/')
from playercpp import *

#gradient function for inputs center, diameter, position, intensity
def gradient ( Max, Xc, Yc, D, Xpos, Ypos, t):
        rc_cm = 0.01 #cm
        rc= rc_cm*1e4 #um
        r0 = 0.0
        r = ((Xc-Xpos)**2 + (Yc-Ypos)**2)**0.5
        r1 = r-r0
        t1_num = Max*rc*rc #um*um
        t1_den = 2*r1*(math.pi*D*t)**0.5 #um*um
        t_exp = math.exp(-(r1*r1)/(4*D*t))
        den = 1 + (3*rc*r1/(4*D*t))
        asp = (t1_num/t1_den)*(t_exp/den)
        return (asp)

Max = 2.0
Xc = 0.0
Yc = 0.0
D = 10.0 #size of arena
t = 0.5 #the higher this is, the higher concentration intensity
# Make proxies for Client, Sonar, Position2d
robot = PlayerClient("localhost");
rp = RangerProxy(robot,0);
pp = Position2dProxy(robot,0);
sp = SimulationProxy(robot,0);

#robot.RequestGeometry();
rp.RequestConfigure(); # fills up angle structures

def run(speed, tm):
	print 'running'
	print "\n"
	pp.SetSpeed(speed, 0)
	time.sleep(tm)

def tumble(tmax, turnrate):
	print 'tumbling'
	print "\n"
#	pp.SetSpeed(0,turnrate)
#	time.sleep(random.random()*tmax)
#	pp.SetSpeed(0,0)
	t = random.random()-0.5
        if t >= 0:
	        pp.SetSpeed(0,turnrate)
       		time.sleep(t*tmax)
        	pp.SetSpeed(0,0)
        else:
                pp.SetSpeed(0,-1.0*turnrate)
                time.sleep(-1.0*t*tmax)


def sample(x,y):
	print 'sampling'
	return gradient( Max, Xc, Yc, D, x, y, t)

def pos():
	robot.Read()
	x = pp.GetXPos() 
	y = pp.GetYPos()
	yaw = pp.GetYaw()
	print 'Xpos:', x, 'Ypos:', y
	newx = x + 0.5*math.cos(yaw)
	newy = y + 0.5*math.sin(yaw)
	return x, y

def chemo():
	x1, y1 = pos()
	C1 = sample(x1, y1)
	run(0.8,1.0)
	x2, y2 = pos()
	C2 = sample(x2, y2)
	print 'Inital Conc:', C1, 'Current Conc:', C2
	if C2 >=  C1:
		chemo()
	else:
		#the product of these two parameters should be 2Pi
		#Pi/2 is the maximum speed
		tumble(4.0, math.pi/2.0)
		chemo()
	
while(1):
    # read from the proxies
	robot.Read()
	chemo()

##while(1):
    # read from the proxies
  ##  robot.Read()

    # where are you?
    #px = float();
    #py = float();
    #opz = float();
    #sp.GetPose2d("r0",px,py,pz);

    # sometimes you miss a scan, just start over
   ## if rp.GetRangeCount() < 4:
     ##   continue;

    # print out sonars, for fun
   ## sonarstr="Sonar scan: "
   ## for i in range(rp.GetRangeCount()):
    ##    sonarstr += '%.3f ' % rp.GetRange(i)
##      pos = pp.GetXPos()
  ##  print sonarstr, pos



     # do simple collision avoidance
   ## short = 0.5;
   ## if rp.GetRange(0) < short or rp.GetRange(2)<short:
     ## turnrate = dtor(-20); # turn 20 degrees per second
   ## elif rp.GetRange(1) <short or rp.GetRange(3)<short:
     ## turnrate = dtor(20);
   ## else:
     ## turnrate = 0;

   ## if rp.GetRange(0) < short or rp.GetRange(1) < short:
     ## speed = 0;
   ## else:
    ##  speed = 0.100;

    # command the motors
   ## pp.SetSpeed(speed, turnrate);

