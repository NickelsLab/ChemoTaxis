import epuck,math,time,sys

if __name__ == "__main__":
	ep = epuck.epuck(docal=False)

	print ep.ReadLineSensors()
