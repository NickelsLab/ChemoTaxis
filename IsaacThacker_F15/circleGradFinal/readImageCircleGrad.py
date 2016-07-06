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
gradient = Image.open("circleGradient.png")

width = gradient.size[0]
height = gradient.size[1]


def getGradPlayer(player):
  return gradient.getpixel((player.x, player.y))
def perpendicular(vec):
  return Vector(vec.y, -vec.x)

#where the movements are recorded
f = open('path.txt', 'w')

#specific get wind direction function for the circle gradient based on source
def findWindDirection(source, player):
  return Vector(source[0]-player.x, source[1]-player.y).unit()

def writePosition(player, f):
  f.write(str(player.x) + " " + str(player.y) + '\n')


def findSourceCircleGrad(source, player):  
  delta = 1
  white = (255,255,255)    #color when out of plume
  iterations = 0
  while(delta < 10):
    iterations += 1
    if(iterations >= 100):
      "Over 500 iterations"
      return  
    if((player.x, player.y) == source):
      return 
    while(getGradPlayer(player) == white):
      rand = random.random()
      #stores perpendicular movement to wind
      player.perpendicularVel = perpendicular(findWindDirection(source,player))
      if(rand < 0.5):
        for x in range(0,delta):
          player.perpendicularMovePos()
          writePosition(player, f)
        if(getGradPlayer(player) != white):
          break
        else:
          for d in range(0,2*delta):
            player.perpendicularMoveNeg()
            writePosition(player, f)
          if(getGradPlayer(player) != white):
            break
          for d in range(0,delta):
            player.perpendicularMovePos()
            writePosition(player, f)
          else:
            for x in range(0,delta):
              player.perpendicularMoveNeg()
              writePosition(player, f)
              if(getGradPlayer(player) != white):
                break
              else:
                for d in range(0,2*delta):
                  player.perpendicularMovePos()
                  writePosition(player, f)
                if(getGradPlayer(player) != white):
                  break
                for d in range(0,delta):
                  player.perpendicularMoveNeg()
                  writePosition(player, f)
      delta += 1
    wind = findWindDirection(source, player)
    player.vel.x = wind.x
    player.vel.y = wind.y
    player.vel = player.vel.mult(5)
    player.move()
    writePosition(player, f)

    


#source used to find wind direction
source = (gradient.size[0]/2.0, gradient.size[1]/2.0)
rad = 274
#to run multiple tests
#to change start position, set startPos = (start_x,start_y)
for x in range(0,1):
  ang = random.uniform(0,2*math.pi)
  startPos = (rad*math.cos(ang) + source[0], rad*math.sin(ang) + source[1])
  player = Player(startPos[0], startPos[1], Vector(0,0))
  player.vel = findWindDirection(source, player)
  #player.vel.mult(5)
  findSourceCircleGrad(source, player)



print "Finished, loading window"
    













