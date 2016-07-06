#!/usr/bin/python

# chemo.py


# Simple controller that uses principles of chemotaxis
# Get concentration from Dr. Nguyen's function
# Compare methylation state from two points, run or tumble
# Tim Davison Feb 2015

# to run player server - "player tim_bb.cfg" in one window
# to run controller - "python chemo.py" in another window

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
def gradientberg ( Max, Xc, Yc, D, Xpos, Ypos, t):
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

#note D is diffusion rate
def gradient( Max, Xs, Ys, D, Xc, Yc, t ):
	r2 = (Xc - Xs)**2 + (Yc - Ys)**2
	G = Max*math.exp(-r2/(4*D*t))/(4*math.pi*D*t)
	return G

Max = 1.5
Xc = 0.0
Yc = 0.0
D = 0.16 
t = 10.0 #the higher this is, the higher concentration intensity
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
#       pp.SetSpeed(0,turnrate)
#       time.sleep(random.random()*tmax)
#       pp.SetSpeed(0,0)
        t = random.random()-0.5
        if t >= 0:
                pp.SetSpeed(0,turnrate)
                time.sleep(t*tmax)
                pp.SetSpeed(0,0)
        else:
                pp.SetSpeed(0,-1.0*turnrate)
                time.sleep(-1.0*t*tmax)
	return abs(t)*tmax


def sample(x,y):
#       print 'sampling'
        return gradient( Max, Xc, Yc, D, x, y, t)

def pos():
        robot.Read()
        x = pp.GetXPos()
        y = pp.GetYPos()
	yaw = pp.GetYaw()
	yaw = pp.GetYaw()
	#this calculates the position of the front of the bot (the nose)
        newx = x + 0.5*math.cos(yaw)
        newy = y + 0.5*math.sin(yaw)
	print 'Xpos:', newx, 'Ypos:', newy
	return newx, newy


#def chemo():
#	x1, y1 = pos()
#       C1 = sample(x1, y1)
#       run(0.2,4.0)
#       x2, y2 = pos()
#       C2 = sample(x2, y2)
#       print 'Inital Conc:', C1, 'Current Conc:', C2
#       if C2 >=  C1:
#               chemo()
#       else:
#               #the product of these two parameters should be 2Pi
#               tumble(2.0, math.pi)
#               chemo()
def eps_val(m):
	eps = [1.0, 0.5, 0.0, -0.3, -0.6, -0.85, -1.1, -2.0, -3.0]
	if m <= 0:
		eps_val = eps[1]
	elif m >= 8:
		eps_val = eps[9]
	else:
		upper = int(math.ceil(m+1))
		lower = int(math.floor(m+1))
		slope = eps[upper] - eps[lower]
		eps_val = eps[lower] + slope*(m+1-lower)
	return eps_val

def dm(cheR, cheB, a, b, A):
	dm = a*(1-A)*cheR-b*A*cheB
	return dm

def ccw_motor_bias(cheYp, mb0, H):
	mb = (1+(1/mb0-1)*(cheYp)**H)**(-1)
	return mb

def rapidcell(S, m, dt):
	K_on = 12e-3
	K_off = 1.7e-3
	Ks_on = 1e6
	Ks_off = 100
	n = 6
	ns = 12
	cheR = 0.16
	cheB = 0.28
	mb0 = 0.65
	H = 10.3
	a = 0.0625
	b = 0.0714
	cheYt = 9.7

#After Eq(7) pg. 3, Eq 8, p. 4
	K_y = 100
	K_z = 30
	G_y = 0.1
	K_s = 0.45
#Receptor free energy
	f = n*(eps_val(m) + math.log((1+S/K_off)/(1+S/K_on))) +ns*(eps_val(m) + math.log((1+S/Ks_off)/(1+S/Ks_on)))
#Cluster activity (Table 2, p.4)
	print 'f is', f
	A = 1/(1+math.exp(f))

#Rate of receptor methylation (Table 2, p.4)
	m = m+dm(cheR, cheB, a, b, A)*dt
	print 'm is', m
	cheYp = 3*(K_y*K_s*A)/(K_y*K_s*A + K_z + G_y)
	print 'cheYp is', cheYp
#	print cheYp
	mb = ccw_motor_bias(cheYp, mb0, H)
	return m,mb

def chemo(m,dt):
	x1, y1 = pos()
	C1 = sample(x1, y1)
	print 'C1', C1
	m,mb = rapidcell(C1, m,dt)
	print mb
	if random.random() <  mb:
		run(0.6,0.3)
		chemo(mb,0.3)
	else:
		tnew = tumble(4.0,math.pi/2)
		chemo(mb,tnew)
		
		

while(1):
    # read from the proxies
        robot.Read()
	x1, y1 = pos()
	m = 5
        C1 = sample(x1, y1)
        for x in range (0,40):
        	time.sleep(0.1)
                m,mb = rapidcell(C1, m,0.5)
	print m
	chemo(m,0.5)

