rosshutdown; % shut down any existing matlab_nodes
rosinit('http://ros2.engr.trinity.edu:11311/'); % start roscore if necc, connect to it

%% Ensure that serial node is going
nodelist = rosnode('list');
while (~ismember('/serial_node',nodelist))
    warning('Serial Node not running... call "roslaunch rosserial_python zumo.lauch" on pi1');
    pause(1);
    nodelist = rosnode('list');
end

%% Fire up webcam
if ~exist('cam','var') cam = webcam; end;
figure(1), imshow(snapshot(cam));

%% send slow forward to /cmd_vel
pub_cmd_vel = rospublisher('/cmd_vel',rostype.geometry_msgs_Twist);
msg = rosmessage(rostype.geometry_msgs_Twist);
msg.Linear.X = 0.1;
msg.Angular.Z = 0;
send(pub_cmd_vel,msg);

%% take ten pictures, one sec apart
for i=1:10
    img{i} = snapshot(cam);
    figure(1), imshow(img{i});
    pause(1);
end;

%% Stop robot and Shut down
msg.Linear.X = 0.0;
msg.Angular.Z = 0;
send(pub_cmd_vel,msg);
clear cam;

for i=1:10
    imwrite(img{i},sprintf('zumo%d.jpg',i));
end;

