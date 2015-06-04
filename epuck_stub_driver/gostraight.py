import epuck,math,time,sys,datetime

if __name__ == "__main__":
	ep = epuck.epuck(docal=False)
	t0 = time.time()

	now = datetime.datetime.now()
	logfilename = "logfile-%s-%s-%s-%s-%s-%s.csv" %\
			(now.year,now.month,now.day,now.hour,now.minute,now.second)
	logfile = open(logfilename,'w+')

	ep.SetVel(0.05,0) # straight forward
	print >>logfile,'time,l,c,r'

	for i in range(300):
		lcr = ep.ReadLineSensors()
		print >>logfile,time.time()-t0,",",lcr[0],",",lcr[1],",",lcr[2]

	logfile.close()
