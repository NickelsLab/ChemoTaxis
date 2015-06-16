#!/usr/bin/python

# chemoreal.py
# implementing chemotaxis on the real robot

# Simple controller that uses principles of chemotaxis
# Get concentration from Dr. Nguyen's function
# Compare methylation state from two points, run or tumble
# Duncan Frasch May 2015

# Working on scaling - using 1uM = 1M (x10^6) 

import math
import random
import time
import datetime
import matplotlib.pyplot as plt
import numpy as np
import epuck
import sys, os
# this should be whereever "playercpp.py" is.  
# On linux, you can find this out with "locate playercpp.py"
sys.path.append('/usr/local/lib/python2.7/site-packages/')
sys.path.append('/usr/local/lib64/python2.7/site-packages/')

def grey_to_asp(sensor):
	sensfactA=0.0002
	sensfactB=-0.008
	sensfactC=-1000
	asp=sensfactA*math.exp(sensfactB*(sensor+sensfactC))
	return asp

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
	Ks_off = 100.0
	n = 6.0
	ns = 12.0
	cheR = 0.16
	cheB = 0.28
	mb0 = 0.65
	H = 10.3
	a = 0.0625
	b = 0.0714
	cheYt = 9.7

#After Eq(7) pg. 3, Eq 8, p. 4
	K_y = 100.0
	K_z = 30.0
	G_y = 0.1
	K_s = 0.45
#Receptor free energy
	f = n*(eps_val(m) + math.log((1+S/K_off)/(1+S/K_on))) +\
	   ns*(eps_val(m) + math.log((1+S/Ks_off)/(1+S/Ks_on)))
	
#Cluster activity (Table 2, p.4)
	#print 'f, ', f,', '
	A = 1/(1+math.exp(f))
	#print 'a, ', A,','

#Rate of receptor methylation (Table 2, p.4)
	m = m+dm(cheR, cheB, a, b, A)*dt
	#print 'm, ', m,', ',
	cheYp = 3*(K_y*K_s*A)/(K_y*K_s*A + K_z + G_y)
	#print 'cheYp, ', cheYp,', ',
	#print cheYp
	mb = ccw_motor_bias(cheYp, mb0, H)

	return m,mb,cheYp

# Run for one time step
def run():
	speed = 0.08 # actual units for robot
	ep.SetVel(speed, 0)
	time.sleep(0.25)

# tumble one time step
def tumble():
	deg_to_tumble = random.randrange(-179,180)
	rad_to_tumble = deg_to_tumble*math.pi/180.0
	max_tumble=4.0
	if deg_to_tumble>0:
		speed_to_tumble = max_tumble
	else:
		speed_to_tumble = -max_tumble
	ep.SetVel(0,speed_to_tumble)
	time.sleep(rad_to_tumble/speed_to_tumble)

def chemo(m,dt,sensor):
	current_asp = grey_to_asp(sensor)
	#print 'current_asp, ', current_asp,', ',
	m,mb,cheYp = rapidcell(current_asp, m,dt)
	if random.random() <  mb:
		run() # run one time step
		#sys.stdout.write('r')
		#sys.stdout.flush()
		run_or_tumble = 1
	else:
		tumble() # for dt
		#sys.stdout.write('t')
		#sys.stdout.flush()
		run_or_tumble = 0

	t=time.time()
	return m,cheYp,run_or_tumble,current_asp
		
# ---------------------------------------------------
# Main program
# ---------------------------------------------------

if __name__ == "__main__":
	
	ep = epuck.epuck('/dev/rfcomm0',docal=False)

	now = datetime.datetime.now()
	logfilename = "logfile-%s-%s-%s-%s-%s-%s.csv" %\
			(now.year,now.month,now.day,now.hour,now.minute,now.second)
	logfile = open(logfilename,'w+')

	while_time = 400
	delta_t = 0.1 #%time-step		

# find steady-state methylation for each cell, 5 is the initial guess
	m = 5
	lcr=ep.ReadLineSensors()
	if len(lcr)>2:	# if an error in the reading occurs, use previous reading
		sensor=lcr[1] # reads middle sensor only
	current_asp = grey_to_asp(sensor)
	tic = time.time()
	for x in range (0,400):
			# time.sleep(0.1)
			m,mb,cheYp = rapidcell(current_asp, m,delta_t)
	# print 'm after ss %.3f, ' % m,

	#print >>logfile,'simtime, delta_t, asp, m, x, y, cheY-P, r(1)/t(0)'

# Now, do the chemotaxis
	t0 = time.time()
	prev_t = t0 - 0.1 # initial time of the controller
	tf = t0 + while_time
	t = t0
	while (t<tf):
			#time.sleep(2)
			t = time.time()
			runtime = t - tic
			delta_t = t - prev_t
			lcr=ep.ReadLineSensors()
			if len(lcr)>2:	# if an error in the reading occurs, use previous reading
				sensor=lcr[1] # reads middle sensor only
			m,cheYp, run_or_tumble, asp = chemo(m,delta_t,sensor)
			sys.stdout.flush()
			prev_t = t

			print >>logfile,'%.3f, %.3f, %.3g, %.2f, %.2f, %.2f, %d' % (runtime, delta_t, asp, sensor, m, cheYp, run_or_tumble)

			#if (x%100==0):
				#print '\ncycle=',cycle,',',
				#print  'm=%.2f, ' % m,
			
	ep.SetVel(0.0,0.0) # stop the robot at the end
	del ep
	toc = time.time()
	print 'total elapsed time = %.2f s = %.2f min' % (toc-tic, (toc-tic)/60)
	raw_input("press enter to continue")


