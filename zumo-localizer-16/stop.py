import rospy
from geometry_msgs.msg import Twist

pub = rospy.Publisher('cmd_vel',Twist,queue_size=1)
rospy.init_node('stop_node',anonymous=True)
cmd = Twist()
cmd.linear.x = 0
cmd.angular.z = 0
pub.publish(cmd)
exit()

