# triplesample.py
# samples in the same location 3 times in a row, then moves to the next point
# tests noise on the robot sensors

import epuck,math,time,sys,datetime

if __name__ == "__main__":
	ep = epuck.epuck('/dev/rfcomm0',docal=False)
	t0 = time.time()

	now = datetime.datetime.now()
	logfilename = "logfile-%s-%s-%s-%s-%s-%s.csv" %\
			(now.year,now.month,now.day,now.hour,now.minute,now.second)
	logfile = open(logfilename,'w+')

	print >>logfile,'time,l,c,r'

	ep.SetVel(0.0,0.0)

	lcr = ep.ReadLineSensors()
	print >>logfile,time.time()-t0,",",lcr[0],",",lcr[1],",",lcr[2]
	time.sleep(2)

	lcr = ep.ReadLineSensors()
	print >>logfile,time.time()-t0,",",lcr[0],",",lcr[1],",",lcr[2]
	time.sleep(2)

	lcr = ep.ReadLineSensors()
	print >>logfile,time.time()-t0,",",lcr[0],",",lcr[1],",",lcr[2]
	time.sleep(2)

	for i in range(4):
		ep.SetVel(0.05,0.0)
		time.sleep(2)

		ep.SetVel(0.0,0.0)
		time.sleep(0.5)

		lcr = ep.ReadLineSensors()
		print >>logfile,time.time()-t0,",",lcr[0],",",lcr[1],",",lcr[2]
		time.sleep(2)

		lcr = ep.ReadLineSensors()
		print >>logfile,time.time()-t0,",",lcr[0],",",lcr[1],",",lcr[2]
		time.sleep(2)

		lcr = ep.ReadLineSensors()
		print >>logfile,time.time()-t0,",",lcr[0],",",lcr[1],",",lcr[2]
		time.sleep(2)

		


	logfile.close()
