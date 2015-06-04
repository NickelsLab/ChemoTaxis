
import epuck,math,time

if __name__ == "__main__":
	ep = epuck.epuck(docal=False)

	ep.SetVel(0,0.5) # spin right
	time.sleep(1)
	ep.SetVel(0,-0.5) # spin left
	time.sleep(1)
	ep.SetVel(0,0)

