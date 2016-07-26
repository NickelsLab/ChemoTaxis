
debug_Mode = 1; %toggle 1 to turn on debug mode.





rosshutdown; %shut down any matlab_ros nodes still running
rosinit('http://ros2:11311/');%This should initialize the roscore that  you give to matlab, so they can talk to each other.
locPub = rospublisher('/zloc', 'turtlesim/Pose');
msg = rosmessage(locPub);
msg.Theta = 0 ; %initialized to zero

logicalVideo = false;
tic;
numImages = 13;
files = cell(1, numImages);
for i = 1:numImages
    %files{i} = fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', ...
    %    'calibration', 'kinectCalib', sprintf('image%d.jpg', i));
	files{i} = fullfile('CameraLocationCalibration', sprintf('image%d.jpg', i));
end

[imagePoints, boardSize] = detectCheckerboardPoints(files);
squareSize = 22;
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
load('cameraParams.mat');
ctime = toc;
% Detect the checkerboard.
[imagePoints, boardSize] = detectCheckerboardPoints(files{i});

% Compute rotation and translation of the camera.
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams);
fprintf('\n Calibration time equals; %4.4f', ctime);

%//Finished with calibration loads.


kinect_mex(); % call one to initialize the freenect interface
pause(2);
kinect_mex(); % get first data...

unattainable_constant = -100;

old_Center_X = unattainable_constant;
old_Center_Y = unattainable_constant;

[imagePoints, boardSize] = detectCheckerboardPoints(files{2});
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams);

counter = 1;

while logicalVideo == false
	[a,b]=kinect_mex();
	 if (length(b)>307200),
	        img = permute(reshape(b,[3,640,480]),[3 2 1]);
	 else
	        img = repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]);
	 end
	detector = vision.CascadeObjectDetector('zD2.xml');
	bbox = step(detector,img);
	detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'Look at my Zumo');
	bboxBool = isempty(bbox);
	if (bboxBool == 0)
        xy_pixel = [bbox(1)+(bbox(3)/2) bbox(2)+(bbox(4)/2)];
        marker_Image = insertMarker(detectedImg, xy_pixel);
        
        if (debug_Mode == true)
        	imshow(marker_Image);
        end
        imshow(marker_Image);

        worldPoints_Center = pointsToWorld(cameraParams, R, t, xy_pixel);
        center_Dimensions = [worldPoints_Center(1)*.0393701 worldPoints_Center(2)*-.0393701];
		yBoundary = 90;

		if (old_Center_X == unattainable_constant)
			old_Center_X = center_Dimensions(1);
			old_Center_Y = center_Dimensions(2);
		end

		if (center_Dimensions(2) < yBoundary & center_Dimensions(1)>0)
            x_difference = (center_Dimensions(1)-old_Center_X);
            y_difference = (center_Dimensions(2)-old_Center_Y);
            if (debug_Mode == true)
            	fprintf('(x_diff, y_diff) =  (%0.2f,%0.2f)\n', x_difference, y_difference);
            	fprintf('theta_Val = %0.2f\n', msg.Theta);
            end
            if (debug_Mode == true & msg.Theta > 2)
            	
            end

            distance_threshold = 1;
            distance_traveled = (x_difference^2 + y_difference^2)^(1/2);

            if (distance_traveled>distance_threshold & distance_traveled < 5)
                msg.Theta = atan2(y_difference,x_difference);
            	if (msg.Theta < 0)
            		msg.Theta = msg.Theta + 2*pi ;
            	end

            	if (debug_Mode == true)
            		fprintf('theta_Val changed to = %0.2f\n', msg.Theta);
            	end
                old_Center_X = center_Dimensions(1);
                old_Center_Y = center_Dimensions(2);
            end

            if (distance_traveled < 5)
        		msg.X = center_Dimensions(1);
        		msg.Y = center_Dimensions(2);
				send(locPub, msg);
				B(counter,:) = [center_Dimensions(1) center_Dimensions(2) msg.Theta];
				counter = counter + 1;
			end
			fprintf('center (x,y)_Inch = (%0.2f, %0.2f)\n', center_Dimensions(1), center_Dimensions(2));
			fprintf('Distance_traveled = %0.2f\n', distance_traveled);
		end
		if (debug_Mode == true)
			fprintf('center (x,y)_Inch = (%0.2f, %0.2f)\n', center_Dimensions(1), center_Dimensions(2));
		end
	end


%figure;
%plot (B(:,1), B(:,2));

end















