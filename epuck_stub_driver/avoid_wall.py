import epuck,math,time

if __name__ == "__main__":
	ep = epuck.epuck('/dev/rfcomm0',docal=True)

	while (True):
		obstacles = ep.ReadProx()
		if (obstacles[0]<100 and obstacles[1]<100 and obstacles[6]<100 and obstacles[7]<100): # nothing in front
			ep.RingLED(0,1)
			ep.RingLED(1,1)
			ep.RingLED(7,1)
			ep.SetVel(0.125,0) # go forward, max speed
		else:
			ep.RingLED(9,1) # turn all on
			ep.TurnBy(-math.pi/2,speed=500)
			ep.RingLED(9,0) # turn all off
