import rospy
from geometry_msgs.msg import Pose2D

rospy.init_node('zloc')
pub = rospy.Publisher('/zloc', Pose2D, queue_size=10)
r = rospy.Rate(0.5)  # in Hz

vel = 1;
pose2d = Pose2D()
pose2d.x = 568;
pose2d.y = 200;
pose2d.theta = 0;

print "x=",
while not rospy.is_shutdown():
    print "{} ".format(pose2d.x),
    pose2d.x = pose2d.x + vel;
    if pose2d.x > 1000:
        vel = -1;
    elif pose2d.x < 600:
        vel = 1
    else:
        pass
    pub.publish(pose2d);
    r.sleep()
