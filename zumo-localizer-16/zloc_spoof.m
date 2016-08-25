%% Start up ROS
rosshutdown; % shut down any existing matlab_nodes
rosinit('http://ros2.engr.trinity.edu:11311/'); % start roscore if necc, connect to it
pub_zloc = rospublisher('/zloc',rostype.geometry_msgs_Pose2D);
zloc = rosmessage(rostype.geometry_msgs_Pose2D);

zloc.X = 0;
zloc.Y = 0;

fprintf(1,'x=');
while (zloc.X < 1000)
    zloc.X = zloc.X + 1;
    fprintf(1,'%d ',zloc.X);
    send(pub_zloc,zloc); % publish to ROS
    pause(2);
end