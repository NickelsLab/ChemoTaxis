import epuck,math,time

if __name__ == "__main__":
	ep = epuck.epuck('/dev/rfcomm0',docal=False)

	ep.TurnBy(-math.pi)
