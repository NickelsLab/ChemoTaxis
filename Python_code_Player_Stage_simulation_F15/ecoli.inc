# ecoli.inc
# model for the robot "ecoli"
# based on BigBob by Jenny Owens
# Author: Kevin Nickels
# Date: 5/1/2015

define ecoli_sonar sensor
(
    # define the size of each transducer [xsize ysize zsize] in meters
    size [0.1 0.1 0.1 ] 
    # define the range bounds [min max]
    range [0.3 100]
    # define the angular field of view (by default in degrees)
    fov 10
    # define the color that ranges are drawn in the gui
    color_rgba [0 1 0 0.5] 
)

define ecoli_sonars ranger
( 
  # one line for each sonar [xpos ypos zpos heading]
  ecoli_sonar( pose [ 0.75 0.1875 0 0])
  ecoli_sonar( pose [ 0.75 -0.1875 0 0])
  ecoli_sonar( pose [ 0.25 0.5 0 30])
  ecoli_sonar( pose [ 0.25 -0.5 0 -30])
)

define ecoli position
(
		  # actual size
		  size [16 4 1]
		  # centre of rotation offset
		  origin [0 0 0 0]

		  # the shape of Bigbob
		  block
		  (
					 points 4
					 point[3] [0 0]
					 point[2] [0 1]
					 point[1] [1 1]
					 point[0] [1 0]
					 z [0 1]
		  )
		  #positional things
		  drive "diff"

		  #sensors attached to ecolib
		  #ecoli_sonars( ) 
		  #ecoli_eyes( )
		  #ecoli_laser( )

		  # Per http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1855780/ we see
		  # body rotation rates of 12.5 Hz = 12.5 rot/s * 360 deg/rot 
		  # = 4500 deg/s
		  # = 450 deg / 100ms (too fast for us to simulate!)
		  # 
		  # body swim rates of 25uM/s

		  # [ xmin xmax ymin ymax zmin zmax amin amax ] (m/s or deg/s)
		  # our scaling is 1m==1micron

		  velocity_bounds [-25 25 -25 25 -25 25 -3600 3600 ]					
		  acceleration_bounds [-25 25 -25 25 -25 25 -3600 3600]
		  update_interval 1
)
