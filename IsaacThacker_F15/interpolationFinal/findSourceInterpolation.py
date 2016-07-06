from math import sqrt
import math
import random
from scipy.io import loadmat
from scipy.interpolate import griddata
import numpy as np


class Vector:
  def __init__(self, xx, yy):
    self.x = xx
    self.y = yy
  def mag(self):
    return sqrt((self.x*self.x) + (self.y*self.y))
  def unit(self):
    return Vector(self.x/self.mag(), self.y/self.mag())
  def __str__(self):
    return "<" + str(self.x) + "," + str(self.y) + ">"
  def dot(self, v):
    return (self.x*v.x) + (self.y*v.y)
  def mult(self, s):
    return Vector(self.x*s, self.y*s)

class Player:
  def __init__(self, xx, yy, v):
    self.x = xx
    self.y = yy
    self.vel = v
    self.perpendicularVel = perpendicular(v)
    self.rvel = Vector(0,0) 
  def move(self):
    self.x += self.vel.x
    self.y += self.vel.y
  def perpendicularMovePos(self):
    self.x += self.perpendicularVel.x
    self.y += self.perpendicularVel.y
  def perpendicularMoveNeg(self):
    self.x -= self.perpendicularVel.x
    self.y -= self.perpendicularVel.y
  def randomWalk(self):
    self.rvel.x = (random.uniform(-self.vel.x, self.vel.x))*self.vel.x
    self.rvel.y = (random.uniform(-self.vel.y, self.vel.y))*self.vel.y
  def randMove(self):
    self.x += self.rvel.x
    self.y += self.rvel.y
  def __str__(self):
    return "<" + str(self.x) + "," + str(self.y) + ">"


def checkBoundsTup(pos):
  return (pos[0] < width and pos[0] >= 0 and pos[1] < height and pos[1] >= 0)
def checkBounds(x,y):
  return (x < width and x >= 0 and y < height and y >= 0)
def checkBoundsP(player):
  return (player.x < width and player.x >= 0 and player.y < height and player.y >= 0)
def perpendicular(vec):
  return Vector(vec.y, -vec.x)


f = open('path.txt', 'w')

#finds interpolated velocity
def getInterpolatedVel(player, winds):
  return Vector(-10*winds[player.x][player.y][0], -10*winds[player.x][player.y][1])

#writes position to file
def writePosition(player, f):
  f.write(str(player.x) + " " + str(player.y) + '\n')



#-----------------------------

def outOfBounds(player):
  return player.x < 0 or player.x > 400 or player.y < 0 or player.y > 200 

#-----------------------------------------------------------------------------
def findSourceAccurate(player, concentration, winds):
  delta = 1
  rand = random.random()
  prevVel = player.vel
  inPlume = False
  while(delta <= 10):
    #in plume
    while(player.vel.x != 0 and player.vel.y != 0):
      player.move()
      prevVel = player.vel
      writePosition(player, f)
      player.vel = getInterpolatedVel(player, winds)
      #ensured it would realize if it went out of bounds, it was out of the plume 
      if(player.x < 0 or player.y < 0):
        player.vel = Vector(0,0)

    #out of plume 
    #does the back-and-forth movement 7 times until it doesn't find the plume again
    #picks randomly left or right and goes back-and-forth with an increasing delta
    inPlume = False
    delta = 3
    player.perpendicularVel = perpendicular(prevVel)
    if(player.perpendicularVel.mag() == 0):
      player.perpendicularVel.x /= 100
      player.perpendicularVel.y /= 100
    else:
      player.perpendicularVel = player.perpendicularVel.unit()
    for x in range(0,10):
      if(rand < 0.5):
        for d in range(0,delta):
          player.perpendicularMovePos()
          writePosition(player, f)
        player.vel = getInterpolatedVel(player, winds) 
        if(not outOfBounds(player) and (player.vel.x != 0 or player.vel.y != 0)):
          inPlume = True
          break
        for d in range(0, 2*delta):
          player.perpendicularMoveNeg()
          writePosition(player, f)
        player.vel = getInterpolatedVel(player, winds)
        if(not outOfBounds(player) and (player.vel.x != 0 or player.vel.y != 0)):
          inPlume = True
          break
        for d in range(0, delta):
          player.perpendicularMovePos()
          writePosition(player, f)
      else:
        for d in range(0,delta):
          player.perpendicularMoveNeg()
          writePosition(player, f)
        player.vel = getInterpolatedVel(player, winds)
        if(not outOfBounds(player) and (player.vel.x != 0 or player.vel.y != 0)):
          inPlume = True
          break
        for d in range(0, 2*delta):
          player.perpendicularMovePos()
          writePosition(player, f)
        player.vel = getInterpolatedVel(player, winds)
        if(not outOfBounds(player) and (player.vel.x != 0 or player.vel.y != 0)):
          inPlume = True
          break
        for d in range(0, delta):
          player.perpendicularMoveNeg()
          writePosition(player, f)

    delta += 1
    #finds itself back in the plume, resets delta and the left or right choice
    if(inPlume):
      delta = 1
      rand = random.random()
    else:
      #print "Finished: " + str(player)
      return
#--------------------------------------------------------------------------------


    


xs = loadmat('Isaac_xmid.mat')
xs = xs['xmid'].tolist()
xs = xs[0]
ys = loadmat('Isaac_ymid.mat')
ys = ys['ymid'].tolist()
ys = ys[0]
us = loadmat('isaac_umid.mat')
us = us['u_mid'].flatten().tolist()


xArr = np.asarray(xs)
yArr = np.asarray(ys)
uArr = np.asarray(us)

points = []
values = []

for i in range(0, len(xs)):
  points.append((xs[i], ys[i]))
  values.append(us[i])


#makes a grid with x in [0,1.0] and y in [0,1.0] with lots of points in between
grid_x, grid_y = np.mgrid[0:1.0:1000j, 0:1.0:1000j]   

points = np.asarray(points)
values = np.asarray(values)

#creates griddata from points in xmid, ymid and concentration u_mid
#makes a map from (x,y) -> concentration u
concentration = griddata(points, values, (grid_x, grid_y), method='linear')

velx = loadmat('velx2.mat')
velx = velx['velx']
vely = loadmat('vely2.mat')
vely = vely['vely']


wind = []

for x in range(0, len(velx)):
  for y in range(0, len(velx[x])):
    wind.append((velx[x][y], vely[x][y]))

wind = np.asarray(wind)

windPoints = []
for x in range(0, 400):
  for y in range(0, 200):
    windPoints.append((x,y))
windPoints = np.asarray(windPoints)

#makes grid with x in [0,400] and y in [0,200]
grid_wind_x, grid_wind_y = np.mgrid[0:400, 0:200]   

#creates griddata of winds form velx2.mat and vely2
#makes a map from (x,y) -> (velx, vely)
winds = griddata(windPoints, wind, (grid_wind_x, grid_wind_y), method='linear')


visited = {}

#if you want to change xPos and yPos, pick xPos in (5,395) and yPos in (5,195) so it starts in the plume
for x in range(0,100):
  xPos = random.uniform(5,395)
  yPos = random.uniform(5,195)
  startPos = (xPos, yPos)
  while(xPos in visited):
    xPos = random.uniform(5,395)
    yPos = random.uniform(5,195)
    startPos = (xPos, yPos)
  visited[xPos] = 0
  player = Player(startPos[0], startPos[1], Vector(0,0)) 
  findSourceAccurate(player, concentration, winds)



print "Finished, loading window"


