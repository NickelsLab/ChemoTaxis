
import epuck,math,time

if __name__ == "__main__":
	ep = epuck.epuck('/dev/rfcomm0',docal=False)

	ep.SetVel(0.2,0) # run
	ep.RingLED(0,1);
	ep.RingLED(1,1);
	ep.RingLED(7,1);
	time.sleep(1)
	ep.SetVel(0,math.radians(-20)) # spin right @ 10 deg/s
	ep.RingLED(0,0);
	ep.RingLED(1,0);
	ep.RingLED(7,0);

	for i in range(8):
		ep.RingLED(i,0)
	a=180
	while (a>=0):
		led = ep.LEDAtAngle(a)
		ep.RingLED(led,1)
		print "led=%d" % led
		time.sleep(0.5)
		ep.RingLED(led,0)
		a = a-10
	ep.SetVel(0,0)
