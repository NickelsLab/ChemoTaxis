import serial, struct
import time
import sys,os
sys.path.append('/usr/local/lib64/python2.6/site-packages/')
sys.path.append('/usr/local/lib64/python2.7/site-packages/')


ser = serial.Serial('/dev/rfcomm3',115200,timeout=1)

x = ser.readline() # clear out welcome message if necc
print 'read ', len(x), ' bytes, ',x
print 'read', x.encode('hex')

# Version String
ser.write("\x01") 
# get response
x = ser.readline()
print 'read', x.encode('hex')
x_ints = struct.unpack('h',x)
print 'this is ', x_ints[0]

# LEDs
ser.write("\x18\xff\x03") # turn all LEDs on
x = ser.readline()
print 'read', x.encode('hex')


# velocity
ser.write("\x13"+struct.pack('hh',100,00))
x = ser.readline()
print 'read', x.encode('hex')

time.sleep(1)

# velocity
ser.write("\x13"+struct.pack('hh',00,00))
x = ser.readline()
print 'read', x.encode('hex')

# LEDs
ser.write("\x18\x00\x01") # turn body LED on, rest off
x = ser.readline()
print 'read', x.encode('hex')

# LEDs
ser.write("\x18\x00\x00") # turn all LEDs off
x = ser.readline()
print 'read', x.encode('hex')

# read steps
ser.write("\x14");
x = ser.readline()
print 'read', x.encode('hex')
x_ints = struct.unpack('hh',x);
print 'steps_right = ',x_ints[0],', steps_left = ',x_ints[1]

ser.close()
