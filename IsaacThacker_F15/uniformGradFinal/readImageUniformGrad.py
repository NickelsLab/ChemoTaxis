from math import sqrt
import math
import os, sys
import Image
import random

#Vector class to represent velocities
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

#Player class to represent the player
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




#image to be read
#You can change it to be one of these four

#uniform gradient
#gradient = Image.open("gradient.png")    #use runGrad32.sh or runGrad64.sh or runGrad.sh
#gradient = Image.open("gradient1.png")   #use runGrad1_32.sh or runGrad1_64.sh or runGrad1.sh

#irregular gradient
#gradient = Image.open("gradient2.png")   #use runGrad2_32.sh or runGrad2_64.sh or runGrad2.sh
gradient = Image.open("gradient3.png")  #use runGrad3_32.sh or runGrad3_64.sh or runGrad3.sh

width = gradient.size[0]
height = gradient.size[1]


def getGradPlayer(player):
  return gradient.getpixel((player.x, player.y))
def getGrad(x, y):
  return gradient.getpixel((x,y))
def getGradTup(tup):
  return gradient.getpixel(tup)
def checkBoundsTup(pos):
  return (pos[0] < width and pos[0] >= 0 and pos[1] < height and pos[1] >= 0)
def checkBounds(x,y):
  return (x < width and x >= 0 and y < height and y >= 0)
def checkBoundsP(player):
  return (player.x < width and player.x >= 0 and player.y < height and player.y >= 0)
def perpendicular(vec):
  return Vector(vec.y, -vec.x)










f = open('path.txt', 'w')


def writePosition(player, f):
  f.write(str(player.x) + " " + str(player.y) + '\n')




def findSource(player):  
  #print "In find source"
  delta = 1
  white = (255,255,255,255)
  while(delta <= 10):
    while(getGradPlayer(player) != white):
      ##print "Cur grad: " + str(getGradPlayer(player))
      player.move()
      writePosition(player, f)
    #out of plume
    delta = 5
    inPlume = False
    rand = random.random() 
    for x in range(0,10):
      ##print "delta: " + str(delta)
      if(rand < 0.5):
        for d in range(0,delta):
          ##print str(player)
          #print "delta: " + str(delta);
          #print str(d)
          #print "perpendicularMovePos()"
          player.perpendicularMovePos()
          #print str(player)
          writePosition(player, f)
        if(getGradPlayer(player) != white): 
          inPlume = True
          break
        for d in range(0, 2*delta):
          #print str(player)
          #print "delta: " + str(delta);
          #print str(d)
          #print "perpendicularMoveNeg()"
          player.perpendicularMoveNeg()
          #print str(player)
          writePosition(player, f)
        if(getGradPlayer(player) != white): 
          inPlume = True
          break
        for d in range(0, delta):
          player.perpendicularMovePos()
          writePosition(player, f)
      else:
        for d in range(0,delta):
          #print str(player)
          #print "delta: " + str(delta);
          #print str(d)
          #print "perpendicularMoveNeg()"
          player.perpendicularMoveNeg()
          #print str(player)
          writePosition(player, f)
        if(getGradPlayer(player) != white): 
          inPlume = True
          break
        for d in range(0, 2*delta):
          #print str(player)
          #print "delta: " + str(delta);
          #print str(d)
          #print "perpendicularMovePos()"
          player.perpendicularMovePos()
          #print str(player)
          writePosition(player, f)
        if(getGradPlayer(player) != white):
          inPlume = True
          break
        for d in range(0, delta):
          player.perpendicularMoveNeg()
          writePosition(player, f)
      delta += 1    
    if(inPlume):
      delta = 1
      rand = random.random()
    #else:
      #print "Can't find plume"


def findWindDirection(source, player):
  return Vector(source[0]-player.x, source[1]-player.y).unit()
  




def findPlume(cnt, player):
  print str(getGradPlayer(player))
  while(getGradPlayer(player) == (255,255,255)):
    player.randomWalk()
    cnt += 1
    print str(cnt)
    print str(player.rvel)
    for x in range(0,10):
      player.randMove()
      if(getGradPlayer(player) != (255,255,255)):
        break
      print str(player)
      writePosition(player, f)
  findSource(player)



class color:
  def __init__(self, rr, gg, bb):
    self.r = rr
    self.g = gg
    self.b = bb
  def __str__(self):
    return str(self.r) + "," + str(self.g) + "," + str(self.b)

colors = [color(255,0,0),color(0,150,0), color(0,0,150), color(150,150,0), color(150,0,150), color(0,150,150)]
wind1 = Vector(0,-1)
wind2 = Vector(0,1)
wind3 = Vector(1,0)
wind4 = Vector(-1,0)
wind5 = Vector(-1,-1)
wind6 = Vector(-1,1)
winds = [wind1, wind2, wind3, wind4, wind5, wind6]

"""For each gradient, I picked points inside the plume so 
If you change the startPos, it might go out of bounds
Uncomment one based on which gradient you chose on line 56"""

#startPos = (150, 525)    #gradient
#startPos = (475, 500)    #gradient
#startPos = (289, 400)   #gradient 

#startPos = (500, 300)    #gradient1
#startPos = (475, 100)    #gradient1
#startPos = (425, 500)   #gradient1

#startPos = (400, 50)    #gradient2
#startPos = (200, 75)    #gradient2
#startPos = (300, 35)   #gradient2

startPos = (575, 450)    #gradient3
#startPos = (550, 150)    #gradient3
#startPos = (550, 275)   #gradient3

#vel = wind
#player = Player(startPos[0], startPos[1], vel)



#Tests with each wind
for x in range(0, 6):
  f.write("color " + str(colors[x]) + '\n') 
  wind = winds[x]
  vel = wind
  player = Player(startPos[0], startPos[1], vel)
  findSource(player)



print "Finished, loading window"

    













