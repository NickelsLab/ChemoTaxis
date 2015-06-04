import epuck,math,time,sys

if __name__ == "__main__":
	ep = epuck.epuck(docal=False)

	minlcr=ep.ReadLineSensors()
	print "start lcr=",minlcr[1]

	# spin left while getting darker
	print "spin left"
	ep.SetVel(0.0,-0.1) # spin left
	lcr=ep.ReadLineSensors()
	while lcr[1]<=minlcr[1]:
		print "minlcr=",minlcr[1],"lcr=",lcr[1]
		minlcr = lcr
		lcr=ep.ReadLineSensors() # continue while getting darker

	# spin right while getting darker
	print "spin right"
	print "start lcr=",minlcr[1]
	ep.SetVel(0.0,+0.1) # spin left
	lcr=ep.ReadLineSensors()
	while lcr[1]<=minlcr[1]:
		print "minlcr=",minlcr[1],"lcr=",lcr[1]
		minlcr = lcr
		lcr=ep.ReadLineSensors() # continue while getting darker
