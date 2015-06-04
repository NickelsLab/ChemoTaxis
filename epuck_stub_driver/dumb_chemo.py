import epuck,math,time,sys,random

if __name__ == "__main__":
	ep = epuck.epuck(docal=False)
	tm1=ep.ReadLineSensors()

	for i in range(100):
		lcr=ep.ReadLineSensors()
		print lcr,
		if ((tm1[1]-lcr[1]) > 2): # run 
			ep.SetVel(0.05,0) # fwd
			print "r",
		elif ((lcr[2] - lcr[0]) > 2) :
			ep.SetVel(0.05,-0.9) # spin left
			print "sl",
		elif ((lcr[2]-lcr[0]) < -2):
			ep.SetVel(0.05,+0.9) # spin right
			print "sr",
		else:
			ep.SetVel(0,(random.random()-0.5)) # tumble
			print "t",
		print "\n",
		time.sleep(0.5)
		tm1 = lcr;

