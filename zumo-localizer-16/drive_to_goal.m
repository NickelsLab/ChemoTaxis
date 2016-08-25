function drive_straight
    rosshutdown; % shut down any existing matlab_nodes
    rosinit('http://ros2.engr.trinity.edu:11311/'); % start roscore if necc, connect to it

    %% Ensure that serial node is going
%     nodelist = rosnode('list');
%     while (~ismember('/serial_node',nodelist))
%         warning('Serial Node not running... call "roslaunch rosserial_python zumo.lauch" on pi1');
%         pause(1);
%         nodelist = rosnode('list');
%     end

    %% send slow forward to /cmd_vel
    pub_cmd_vel = rospublisher('/cmd_vel',rostype.geometry_msgs_Twist);
    cmd_msg = rosmessage(rostype.geometry_msgs_Twist);
    cmd_msg.Linear.X = 0.05;
    cmd_msg.Angular.Z = 0;
    send(pub_cmd_vel,cmd_msg);

    %sub = rossubscriber('/zloc',@zlocCallback);
    sub_zloc = rossubscriber('/zloc');
    zloc = rosmessage(sub_zloc);
    goal = rosmessage(rostype.geometry_msgs_Pose2D);
    goal.X = 1000;
    goal.Y = 350;
    
 try   
    zloc = receive(sub_zloc,2);
    while (isempty(zloc))
        warning('Couldnt connect to zloc... will keep trying\n');
        zloc = receive(sub_zloc,2);
    end
    dtg = dist_pose2d(goal,zloc)
    while dtg>20
        fprintf(1,'dist=%.1f g=(%.1f,%.1f) z=(%.1f,%.1f,%.1f) ', dtg,goal.X,goal.Y,zloc.X,zloc.Y,zloc.Theta);
        heading_to_goal = atan2(goal.Y-zloc.Y,goal.X-zloc.X);
        bearing_error = heading_to_goal - zloc.Theta;
        Kp = 0.5;
        cmd_msg.Angular.Z = min(0.5,max(-0.5,Kp*bearing_error));
        
        if (cmd_msg.Angular.Z < 0.25 && dtg>100) cmd_msg.Linear.X = 0.2;
        elseif dtg>50
                cmd_msg.Linear.X=0.05;
        else
            cmd_msg.Linear.X=0.02;
        end;
      
        fprintf(1,'htg=%.2f, be=%.2f, z=%.2f\n',heading_to_goal,bearing_error,cmd_msg.Angular.Z);
        send(pub_cmd_vel,cmd_msg);    
        pause(0.25);
%        zloc = sub_zloc.LatestMessage;
        zloc = receive(sub_zloc,2);
        dtg = dist_pose2d(goal,zloc);
    end;
    cmd_msg.Linear.X = 0.0;
    cmd_msg.Angular.Z = 0;
    send(pub_cmd_vel,cmd_msg);

%% Stop robot and Shut down
 catch
    cmd_msg.Linear.X = 0.0;
    cmd_msg.Angular.Z = 0;
    send(pub_cmd_vel,cmd_msg);
 end
