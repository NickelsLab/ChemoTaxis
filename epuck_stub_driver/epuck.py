# epuck.py 
# basic epuck driver 
#
# This assumes a bluetooth connection on /dev/rfcomm? to an epuck running 
# the DemoGCtronic-complete.hex firmware from
# http://www.gctronic.com/doc/index.php/E-Puck#Programming
#
# Driver by K. Nickels <knickels@trinity.edu>
# June 2015

import sys,os
sys.path.append('/usr/local/lib64/python2.6/site-packages/')
sys.path.append('/usr/local/lib64/python2.7/site-packages/')

import serial,math,time

# Help screen from V1.2.2 firmware
#
# "A"               Accelerometer                      
# "B,#"             Body led 0=off 1=on 2=inverse
# "b"               Battery state (1=ok, 0=low)
# "C"               Selector position
# "D,#,#"           Set motor speed left,right
# "E"               Get motor speed left,right
# "F,#"             Front led 0=off 1=on 2=inverse
# "G"               IR receiver
# "H"               Help
# "I"               Get camera parameter
# "J,#,#,#,#,#,#"   Set camera parameter mode,width,heigth,zoom(1,4 or 8),x1,y1
# "K"               Calibrate proximity sensors
# "L,#,#"           Led number,0=off 1=on 2=inverse
# "M"               Floor sensors
# "N"               Proximity
# "O"               Light sensors
# "P,#,#"           Set motor position left,right
# "Q"               Get motor position left,right
# "R"               Reset e-puck
# "S"               Stop e-puck and turn off leds
# "T,#"             Play sound 1-5 else stop sound
# "U"               Get microphone amplitude
# "V"               Version of SerCom
# "W"               Write I2C (mod,reg,val)
# "Y"               Read I2C val=(mod,reg)

class epuck:
	"""A simple epuck driver using sercom"""

	# wait for a particular response to a command.
	# flush out any other (old) responses, etc...
	def expectresponse(self,parent,chartoexpect):
		response = self.ser.readline()
		while (response and response[0] != chartoexpect):
			print parent,": unexpected response \'",response[:-2],"\' trying again"
			response = self.ser.readline()
		if not response:
			print "Warning: timed out"
		return response

	# Send a command to the epuck
	def sendcommand(self,cmd):
		nw = self.ser.write(cmd)
		if nw != len(cmd):
			print 'warning: wrote %d bytes, not %d - %s' % (nw,len(cmd),cmd)
		return nw

	# Startup a new connection with an epuck.
	def __init__(self,portname='/dev/rfcomm3',docal=True):
		# Diameter of e-puck wheels[m]
		self.WHEEL_DIAMETER = 0.0412;
		# Distance between e-puck wheels [m]
		self.TRACK = 0.05255;
		# Wheel radius divided by TRACK [m]
		self.r_DIV_L = 0.392007612;
		# Half of wheel radius [m]
		self.r_DIV_2 = 0.0103;
		# Angular displacement of one motor step [rad]
		self.STEP_ANG_DISP = 6.283185308e-3;

		self.ser = serial.Serial(portname,115200,timeout=1)

		x = self.ser.readline() # clear out welcome message if necc
		#print 'discarded %d bytes', len(x),
		#if len(x)>0:
		#	print '%s',x.encode('hex')
		#else:
		#	print ' '

		# calibrate proximetry sensors
		if docal:
			self.CalProx() 

	# Set the speed of the epuck in steps (left wheel, right wheel)
	def SetSpeedSteps(self,Rstep,Lstep):
		# print 'SetSpeedSteps(%d,%d)' % (Rstep,Lstep)
		self.sendcommand("d,"+str(int(Rstep))+","+str(int(Lstep))+"\n")
		self.expectresponse("SetSpeedSteps()()",'d')

	# Set the speed of the epuck in m/s and rad/sec
	# Taken from the player epuckPosition2d driver by 
	#    Renato Florentino Garcia <fgar.renato@gmail.com>
	def SetVel(self,px,pa):
		# print "SetVel(px=%.3f m/s,pa=%.3f rad/s)" % (px,pa)
		
		#  Angular speed for each wheel [rad/s]
		angSpeedRw = ( 2*px + self.TRACK*pa )/( self.WHEEL_DIAMETER );
		angSpeedLw = ( 2*px - self.TRACK*pa )/( self.WHEEL_DIAMETER );

		#  Speed for each motor [steps/s]
		stepsR = int( ( 1000*angSpeedRw )/ (2*math.pi) );
		stepsL = int( ( 1000*angSpeedLw )/ (2*math.pi) );

		if (stepsR > 1000):
			print "R Rotational speed %d saturated @ max value (+1000)" % (stepsR)
			stepsR = 1000
		if (stepsR < -1000):
			print "R Rotational speed %d saturated @ min value (-1000)" % (stepsR)
			stepsR = -1000;

		if (stepsL > 1000):
			print "L Rotational speed %d saturated @ max value (+1000)" % (stepsL)
			stepsL = 1000
		if (stepsL < -1000):
			print "L Rotational speed %d saturated @ min value (-1000)" % (stepsL)
			stepsL = -1000;

		self.SetSpeedSteps(stepsR,stepsL)


	# Read the line sensors (floor sensors)
	def ReadLineSensors(self):
		# print "ReadLineSensors()"
		self.sendcommand("m\n")
		x = self.expectresponse("ReadLineSensors()",'m')
		s = x.split(','); # m,lsensor,csensor,rsensor,0,0
		return [int(a) for a in s[1:4]]

	# Manipulate the LEDs
	def FrontLED(self,state=2): # 1=on, 0=off, 2=toggle
		#print "FrontLED(%d)" % state
		self.sendcommand("f,"+str(int(state))+"\n")
		self.expectresponse("FrontLED()",'f')

	# Manipulate the LEDs
	def BodyLED(self,state=2): # 1=on, 0=off, 2=toggle
		#print "BodyLED(%d)" % state
		self.sendcommand("B,"+str(int(state))+"\n")
		self.expectresponse("BodyLED()",'B')

	# Manipulate the LEDs
	def RingLED(self,num,state=2): # 1=on, 0=off, 2=toggle
		#print "RingLED(%d)" % state
		self.sendcommand("L,"+str(int(num))+","+str(int(state))+"\n")
		self.expectresponse("RingLED()",'l')

	# Calibrate the IR proximity sensors
	# Normally, done only once on startup
	def CalProx(self): 
		#print "CalProx"
		self.sendcommand("K\n")
		x = self.expectresponse("CalProx()",'k')
		print x[3:],
		time.sleep(2)
		x = self.expectresponse("CalProx()",'k')
		print x[3:],

	# Read the IR proximity sensors
	def ReadProx(self):
		#print "ReadProx()"
		self.sendcommand("n\n")
		x = self.expectresponse("ReadProx()",'n')
		if (not x):
			return

		s = x.split(','); # n,ir0,ir1,...,ir7
		reading = [int(a) for a in s[1:]]
		#print "Raw IR readings: ", reading, "(reflectivity)"

		# Mapping from raw reading to dinstance (m)
		def map(r):
			 if r>941:
				 return -4.2260e-06*r+2.3378e-02
			 elif r>403:
				 return -1.8174e-05*r+3.6798e-02
			 else:
				 return -1.2936e-04*r+7.6357e-02

		ranges = [map(r) for r in reading]
		#print "Pocessed IR readings: ", 
		#print ["%0.2f" % i for i in ranges],
		#print  "(m)"
		return ranges

	# Play cute sounds over speaker
	def PlaySound(self,sound=1): # sounds 1-5
		self.sendcommand("t,"+str(int(sound))+"\n")
		self.expectresponse("PlaySound()",'t')

	# Print Firmware version
	def Version(self):
		self.sendcommand("v\n")
		ver = self.expectresponse("Version()",'v')
		print ver[2:],
		ver = self.expectresponse("Version()",'v')
		print ver,

	# On shutdown, stop and close serial connection
	def __del__(self):
		self.SetSpeedSteps(0,0)
		self.ser.close()

# Demo of capabilities
if __name__ == "__main__":
	import time
	ep = epuck('/dev/rfcomm3')

	ep.Version()

	ep.SetSpeedSteps(100,100)

	ep.FrontLED(1)
	time.sleep(1)
	for i in range(8):
		ep.RingLED(i,1)
	for i in range(8):
		ep.RingLED(i,0)
	ep.FrontLED(0)

	time.sleep(1)
	ep.SetSpeedSteps(0,0)

	ep.SetVel(0,90*math.pi/180.0)
	for i in range(5):
		ep.PlaySound(i)
		print "IR = ",
		ir = ep.ReadProx()
		print ["%0.3f" % i for i in ir],
		print "\n"
		sys.stdout.flush()
		time.sleep(2)

	ep.SetVel(0.20,0)
	time.sleep(1)
	ep.SetVel(0,0)
    


