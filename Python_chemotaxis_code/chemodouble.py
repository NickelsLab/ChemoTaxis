#!/usr/bin/python

# chemo.py

# Simple controller that uses principles of chemotaxis
# Get concentration from Dr. Nguyen's function
# Compare methylation state from two points, run or tumble
# Tim Davison Feb 2015
# Duncan Frasch May 2015

# Working on scaling - using 1uM = 1M (x10^6) 

# to run player server - "player PetriDish.cfg" in one window
# to run controller - "python chemo.py" in another window

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


# from http://stackoverflow.com/questions/273192/in-python-check-if-a-directory-exists-and-create-it-if-necessary
# 
def ensure_dir(f):
	if not os.path.exists(f):
		os.makedirs(f)

#note D is diffusion rate
# Xs,Ys = center of chemical plume
# Xc,Yc = location of sample
def Green_gradient( Max, Xs, Ys, D, Xc, Yc, t ):
	r2 = (Xc - Xs)**2 + (Yc - Ys)**2
	G = Max*math.exp(-r2/(4*D*t))/(4*math.pi*D*t)
	return G

# Plots the gradient function 
def draw_Green_gradient(Max,Xs1,Ys1,Xs2,Ys2,D,size_grad,t1,t2,mag,factor):
	scale = 0.5*factor;
	grid = np.arange(-mag*size_grad,mag*size_grad,scale)
	X,Y = np.meshgrid(grid,grid)
	r2_1=(X-Xs1)**2+(Y-Ys1)**2
	r2_2=(X-Xs2)**2+(Y-Ys2)**2
	G=Max*np.exp(-r2_1/(4*D*t1))/(4*math.pi*D*t1)+Max*np.exp(-r2_2/(4*D*t2))/(4*math.pi*D*t2)
	contour1 = plt.contour(X,Y,G,linewidths=2)
	colorbar = plt.colorbar(contour1, shrink=0.8, extend='both')
	plt.clabel(contour1, inline=1, fontsize=10)
	plt.ylim((-mag*size_grad,mag*size_grad))
	plt.xlim((-mag*size_grad,mag*size_grad))
	plt.draw()


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

# Compute position of the nose of the robot
def nose_pos():
	nose_dist = 8*factor # dist from centroid to nose (in units of factor)

	x = pp.GetXPos() # position of (centroid of) the robot
	y = pp.GetYPos()
	yaw = pp.GetYaw()

	#this calculates the position of the front of the bot (the nose)
	nosex = x + nose_dist*math.cos(yaw)
	nosey = y + nose_dist*math.sin(yaw)
	return nosex, nosey

# Compute the absolute distances of the robot from the center of the chemical
def abs_dist(Xs, Ys):
	x = pp.GetXPos() # x coord of (centroid of) the robot
	y = pp.GetYPos() # y coord of (centroid of) the robot
	x1 = x - Xs
	y1 = y - Ys
	return x1, y1

# Run for one time step
def run(dt):
	speed = 20 # microns per second
	pp.SetSpeed(speed, 0)

# tumble one time step
def tumble(dt):
	deg_to_tumble = random.randrange(-179,180)
	rad_to_tumble = deg_to_tumble*math.pi/180.0
	speed_to_tumble = rad_to_tumble/dt
	pp.SetSpeed(0,speed_to_tumble)

def chemo(m,dt,dbg):
	xc, yc = nose_pos()
	current_asp = Green_gradient( Max, Xs1, Ys1, diff_rate, xc, yc, grad_time1) + Green_gradient( Max, Xs2, Ys2, diff_rate, xc, yc, grad_time2) # superposition of two nearby chemical plumes
	#print 'current_asp, ', current_asp,', ',
	m,mb,cheYp = rapidcell(current_asp, m,dt)
	#if (dbg):
		#print '\nasp,%.3g, ' % current_asp
		#print 'mb = %.3g, ' % mb
	if random.random() <  mb:
		run(dt) # run one time step
		#sys.stdout.write('r')
		#sys.stdout.flush()
		run_or_tumble = 1
	else:
		tumble(dt) # for dt
		#sys.stdout.write('t')
		#sys.stdout.flush()
		run_or_tumble = 0

	t=pp.GetDataTime()
	robot.Read() # runs sim 1 timestep, re-reads positions
	#print 'dt=%.0f ms' % (1000*(pp.GetDataTime()-t))
	return m,cheYp,run_or_tumble,current_asp
		
# ---------------------------------------------------
# Main program
# ---------------------------------------------------

if __name__ == "__main__":

	ensure_dir('simulation_robot');

	now = datetime.datetime.now()
	logfilename = "logfile-%s-%s-%s-%s-%s-%s.csv" %\
			(now.year,now.month,now.day,now.hour,now.minute,now.second)
	logfile = open(logfilename,'w+')

	cycle=1;

	Max = 4000 # milli-moles (?)
	Xs1 = 0.0 # location of first attractant plume
	Ys1 = 0.0
	Xs2 = -50.0 # location of second attractant plume
	Ys2 = 0.0	
	factor = 10**(0) # scaling factor - conversion from UNITS to meters
	diff_rate = 0.125*factor**2 # moles/cm (?)
	fixed_time = 2000.0/factor # fixed_time
	size_grad = 20*factor # how often to compute gradient (for display)
	mag = 5.6 # how far out to compute gradient (for display) (??)

	#total_time_steps = 80000
	#total_time_steps = 5000
	#total_time_steps = 1000
	while_time = 300.0 # simulated time of growth/decay loop in seconds
	alpha = 1
	N_frame =  20 #%number of frames to be printed out
	#N_step = round(total_time_steps/N_frame) #%number of steps between each frame
	delta_t = 0.1 #%time-step
		
	vel_mag = 20*factor #%in Micron/s (average running velocity)

# Make proxies for simulated robot
	robot = PlayerClient("localhost");
	pp = Position2dProxy(robot,0);logfile
#sp = SimulationProxy(robot,0);
	robot.Read()	 # read from the proxies

# Set up graphics
	#fig = plt.figure(1,figsize=(4,4))
	plt.ion()
	plt.figure(1)
	#ax = fig.add_subplot(111)
	plt.ylim((-mag*size_grad,mag*size_grad))
	plt.xlim((-mag*size_grad,mag*size_grad))

	#fig.show()
	xnpos = np.array([]) # nose position
	ynpos = np.array([])
	xpos = np.array([]) # robot centroid position
	ypos = np.array([])

# find steady-state methylation for each cell, 5 is the initial guess
	m = 5
	xc, yc = nose_pos()
	grad_time1 = fixed_time
	grad_time2 = fixed_time + alpha*while_time
	current_asp = Green_gradient( Max, Xs1, Ys1, diff_rate, xc, yc, grad_time1) + Green_gradient( Max, Xs2, Ys2, diff_rate, xc, yc, grad_time2)
	tic = time.time()
	x1, y1 = abs_dist(Xs1, Ys1) # robot distance from center of chemical
	for x in range (0,400):
			cycle = cycle+1;
			# time.sleep(0.1)
			m,mb,cheYp = rapidcell(current_asp, m,delta_t)
	# print 'm after ss %.3f, ' % m,

	#print >>logfile,'simtime, delta_t, asp, m, x, y, cheY-P, r(1)/t(0)'

# Now, do the chemotaxis on the first plume
	t0 = pp.GetDataTime()
	prev_simtime = t0 - 0.1 # initial time of the controller
	tf = t0 + while_time
	simtime = t0
	while (simtime<tf):
			#time.sleep(1)
			cycle = cycle+1
			simtime = pp.GetDataTime()
			delta_t = simtime - prev_simtime
			grad_time1 = fixed_time
			grad_time2 = fixed_time + alpha*math.exp(math.sqrt(while_time))
			m,cheYp,run_or_tumble,asp=chemo(m,delta_t,x%100==0)
			sys.stdout.flush()

			prev_simtime = simtime

			xc, yc = nose_pos()
			x1, y1 = abs_dist(Xs1, Ys1)
			xnpos = np.append(xnpos,xc)
			ynpos = np.append(ynpos,yc)
			xpos = np.append(xpos,pp.GetXPos())
			ypos = np.append(ypos,pp.GetYPos())
			
			print >>logfile,'%.3f, %.3f, %.3g, %.2f, %.2f, %.2f, %.2f, %d' % (simtime, delta_t, asp, m, x1, y1, cheYp, run_or_tumble)

			#if (cycle%100==0):
				#plt.cla()
				#plt.clf()
				#draw_Green_gradient(Max,Xs1,Ys1,Xs2,Ys2,diff_rate,size_grad,grad_time1,grad_time2,mag,factor)
				##plt.plot(xnpos,ynpos,'o',color='0.75')
				#plt.plot(xpos,ypos,'b.-')
				#plt.ylim((-mag*size_grad,mag*size_grad))
				#plt.xlim((-mag*size_grad,mag*size_grad))
				#plt.draw() # uncomment to see display as it goes - slows down
				##plt.savefig("simulation_robot/frame_%d" % (t))

# Chemotaxis for the plume transition
	t0 = pp.GetDataTime()
	tf = t0 + while_time
	simtime = t0
	while (simtime<tf):
			#time.sleep(1)
			cycle = cycle+1
			simtime = pp.GetDataTime()
			delta_t = simtime - prev_simtime
			grad_time1 = fixed_time + alpha*math.exp(math.sqrt(simtime-t0))
			grad_time2 = fixed_time + alpha*math.exp(math.sqrt(1+tf-simtime))
			m,cheYp,run_or_tumble,asp=chemo(m,delta_t,x%100==0)
			sys.stdout.flush()

			prev_simtime = simtime	

			xc, yc = nose_pos()
			x1, y1 = abs_dist(Xs1, Ys1)
			xnpos = np.append(xnpos,xc)
			ynpos = np.append(ynpos,yc)
			xpos = np.append(xpos,pp.GetXPos())
			ypos = np.append(ypos,pp.GetYPos())
			
			print >>logfile,'%.3f, %.3f, %.3g, %.2f, %.2f, %.2f, %.2f, %d' % (simtime, delta_t, asp, m, x1, y1, cheYp, run_or_tumble)

			#if (cycle%100==0):
				#plt.cla()
				#plt.clf()
				#draw_Green_gradient(Max,Xs1,Ys1,Xs2,Ys2,diff_rate,size_grad,grad_time1,grad_time2,mag,factor)
				#plt.plot(xnpos,ynpos,'o',color='0.75')
				#plt.plot(xpos,ypos,'b.-')
				#plt.ylim((-mag*size_grad,mag*size_grad))
				#plt.xlim((-mag*size_grad,mag*size_grad))
				#plt.draw() # uncomment to see display as it goes - slows down
				##plt.savefig("simulation_robot/frame_%d" % (t))

# Now, do the chemotaxis on the second plume
	t0 = pp.GetDataTime()
	tf = t0 + while_time
	simtime = t0
	while (simtime<tf):
			#time.sleep(1)
			cycle = cycle+1
			simtime = pp.GetDataTime()
			delta_t = simtime - prev_simtime
			grad_time1 = fixed_time + alpha*math.exp(math.sqrt(while_time))
			grad_time2 = fixed_time
			m,cheYp,run_or_tumble,asp=chemo(m,delta_t,x%100==0)
			sys.stdout.flush()

			prev_simtime = simtime	

			xc, yc = nose_pos()
			x1, y1 = abs_dist(Xs1, Ys1)
			xnpos = np.append(xnpos,xc)
			ynpos = np.append(ynpos,yc)
			xpos = np.append(xpos,pp.GetXPos())
			ypos = np.append(ypos,pp.GetYPos())
		
			print >>logfile,'%.3f, %.3f, %.3g, %.2f, %.2f, %.2f, %.2f, %d' % (simtime, delta_t, asp, m, x1, y1, cheYp, run_or_tumble)

			#if (cycle%100==0):
				#plt.cla()
				#plt.clf()
				#draw_Green_gradient(Max,Xs1,Ys1,Xs2,Ys2,diff_rate,size_grad,grad_time1,grad_time2,mag,factor)
				##plt.plot(xnpos,ynpos,'o',color='0.75')
				#plt.plot(xpos,ypos,'b.-')
				#plt.ylim((-mag*size_grad,mag*size_grad))
				#plt.xlim((-mag*size_grad,mag*size_grad))
				#plt.draw() # uncomment to see display as it goes - slows down
				##plt.savefig("simulation_robot/frame_%d" % (t))

	plt.cla()
	plt.clf()
	draw_Green_gradient(Max,Xs1,Ys1,Xs2,Ys2,diff_rate,size_grad,grad_time1,grad_time2,mag,factor)
	plt.plot(xpos,ypos,'b.-')
	plt.ylim((-mag*size_grad,mag*size_grad))
	plt.xlim((-mag*size_grad,mag*size_grad))
	plt.draw()

	pp.SetSpeed(0.0,0.0) # move forward at 1.0 m/s, 0 rad/s
	del pp
	del robot
	toc = time.time()
	print 'total elapsed time = %.2f s = %.2f min' % (toc-tic, (toc-tic)/60)
	raw_input("press enter to continue")
