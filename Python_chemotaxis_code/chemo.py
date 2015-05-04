#!/usr/bin/python

# chemo.py

# Simple controller that uses principles of chemotaxis
# Get concentration from Dr. Nguyen's function
# Compare methylation state from two points, run or tumble
# Tim Davison Feb 2015

# to run player server - "player PetriDish.cfg" in one window
# to run controller - "python chemo.py" in another window

import math
import random
import time
import datetime

import sys, os
# this should be whereever "playercpp.py" is.  
# On linux, you can find this out with "locate playercpp.py"
sys.path.append('/usr/local/lib/python2.7/site-packages/')
sys.path.append('/usr/local/lib64/python2.7/site-packages/')
from playercpp import *

#note D is diffusion rate
# Xs,Ys = center of chemical plume
# Xc,Yc = location of sample
def green_gradient( Max, Xs, Ys, D, Xc, Yc, t ):
	r2 = (Xc - Xs)**2 + (Yc - Ys)**2
	G = Max*math.exp(-r2/(4*D*t))/(4*math.pi*D*t)
	return G


def run(speed, dt):
	#print 'state,running,speed,',speed,',cm/s,duration,',1000*dt,',ms,',
	print >>logfile, 'state,run,',
	pp.SetSpeed(speed, 0)
	#robot.Read()
	#time.sleep(dt)
	#pp.SetSpeed(0,0)

def tumble(turnrate,dt):
	#print 'state,tumbling,rate,', turnrate,'rad/s, duration,',1000*dt,'ms, ',
	print >>logfile, 'state,tumble,',
	pp.SetSpeed(0,turnrate)
	#robot.Read()
# time.sleep(dt)
	#pp.SetSpeed(0,0)

def nose_pos():
	nose_dist = 0.08 # dist from centroid to nose
	robot.Read()
	x = pp.GetXPos() # position of (centroid of) the robot
	y = pp.GetYPos()
	yaw = pp.GetYaw()

	#this calculates the position of the front of the bot (the nose)
	nosex = x + nose_dist*math.cos(yaw)
	nosey = y + nose_dist*math.sin(yaw)
	#print 'Xpos, %0.2f, Ypos, %0.2f, ' % (nosex, nosey),
	return nosex, nosey


def eps_val(m):
	eps = [1.0, 0.5, 0.0, -0.3, -0.6, -0.85, -1.1, -2.0, -3.0]
	if m <= 0:
		eps_val = eps[0]
	elif m >= 8:
		eps_val = eps[8]
	else:
		upper = int(math.ceil(m))
		lower = int(math.floor(m))
		slope = eps[upper] - eps[lower]
		eps_val = eps[lower] + slope*(m-lower)
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
	f = n*(eps_val(m) + math.log((1+S/K_off)/(1+S/K_on))) +\
	   ns*(eps_val(m) + math.log((1+S/Ks_off)/(1+S/Ks_on)))
#Cluster activity (Table 2, p.4)
	#print 'f, ', f,', ',
	A = 1/(1+math.exp(f))

#Rate of receptor methylation (Table 2, p.4)
	m = m+dm(cheR, cheB, a, b, A)*dt
	#print 'm, ', m,', ',
	cheYp = 3*(K_y*K_s*A)/(K_y*K_s*A + K_z + G_y)
	#print 'cheYp, ', cheYp,', ',
#	print cheYp
	mb = ccw_motor_bias(cheYp, mb0, H)
	return m,mb

def chemo(m,dt):
	x1, y1 = nose_pos()
	current_asp = green_gradient( Max, Xc, Yc, diff_rate, x1, y1, fixed_time)
	#print 'current_asp, ', current_asp,', ',
	print 'asp,%.3f, ' % current_asp
	print >>logfile, 'asp,%.3f, ' % current_asp,
	m,mb = rapidcell(current_asp, m,dt)
	if random.random() <  mb:
		run(0.20,dt) # 20cm/s for dt
	else:
		deg_to_tumble = random.randrange(-179,180)
		rad_to_tumble = deg_to_tumble*math.pi/180.0
		speed_to_tumble = rad_to_tumble/dt
		tumble(speed_to_tumble,dt) # random speed for dt
	return m
		
# ---------------------------------------------------
# Main program
# ---------------------------------------------------

if __name__ == "__main__":

	now = datetime.datetime.now()
	logfilename = "logfile-%s-%s-%s-%s-%s-%s.csv" %\
			(now.year,now.month,now.day,now.hour,now.minute,now.second)
	logfile = open(logfilename,'w+')

	fsize=24
	factor = 10**(-2)

	time=1;

	Max = 400 # milli-moles (?)
	Xc = 0.0
	Yc = 0.0
# D = 0.16 # moles/micro-meter (??)
	diff_rate = 0.05*factor**2 # moles/cm (?)
	fixed_time = 2000/factor # fixed_time

	total_time_steps = 80000
	N_frame =  20 #%number of frames to be printed out
	N_step = round(total_time_steps/N_frame) #%number of steps between each frame
	delta_t = 0.01 #%time-step
		
	vel_mag = 20*factor #%in Micron/s (average running velocity)

# Make proxies for simulated robot
	robot = PlayerClient("localhost");
	pp = Position2dProxy(robot,0);
#sp = SimulationProxy(robot,0);
	robot.Read()	 # read from the proxies

# find steady-state methylation for each cell, 5 is the initial guess
	m = 5
	x1, y1 = nose_pos()
	current_asp = green_gradient( Max, Xc, Yc, diff_rate, x1, y1, fixed_time)
	for x in range (0,400):
			print >>logfile, '\nt=',time,',',
			print >>logfile, 'x,%.3f,y,%.3f,' % (x1,y1),
			time = time+1;
			# time.sleep(0.1)
			m,mb = rapidcell(current_asp, m,delta_t)
			print >>logfile, 'asp,%.3f, ' % current_asp,
			print >>logfile, 'state,equilibrate,',
			print >>logfile, 'm,%.2f, ' % m,
			print >>logfile, 'mb,%.3f, ' % mb,

	for x in range (0,total_time_steps):
			print >>logfile, '\nt=',time,',',
			x1, y1 = nose_pos()
			print >>logfile, 'x,%.3f,y,%.3f,' % (pp.GetXPos(),pp.GetYPos()),
			time = time+1;
			m=chemo(m,delta_t)
			print >>logfile, 'm,%.2f, ' % m,
			print >>logfile, 'mb,%.3f, ' % mb,
