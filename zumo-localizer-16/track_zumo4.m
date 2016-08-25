%% track_zumo - find a zumo
%% track_zumo2 - loop through 10 images
%% track_zumo3 - drop the fisheye calibration as undistort is very slow.
%% track_zumo4 - don't imshow() (slow) and publish result as a Pose2D

live_robot=0; 
live_imgs=1;
plotlocs=0;

%% Start up ROS
rosshutdown; % shut down any existing matlab_nodes
rosinit('http://ros2.engr.trinity.edu:11311/'); % start roscore if necc, connect to it
if (live_imgs)
    if ~exist('cam','var') cam = webcam; end;
end;
pub_zloc = rospublisher('/zloc',rostype.geometry_msgs_Pose2D);
zloc = rosmessage(rostype.geometry_msgs_Pose2D);
last_zloc = rosmessage(rostype.geometry_msgs_Pose2D);
zloc.X = -1; zloc.Y = -1; zloc.Theta = 0;
last_zloc.X = -1; last_zloc.Y = -1; last_zloc.Theta = 0;

% Only analyze portions within the sandbox
if ~exist('mask_img','var') load('mask_img.mat'); end;
if ~exist('bkgnd','var') bkgnd=rgb2gray(imread('Pics/bkgrnd.jpg')); end;
bkgndm = bkgnd; bkgndm(mask_img==0)=0;

blobAnalysis = vision.BlobAnalysis('AreaOutputPort', true,...
    'CentroidOutputPort', true,...
    'BoundingBoxOutputPort', true,...
    'MinimumBlobArea', 20, 'ExcludeBorderBlobs', true);

%last_zloc = zloc;

%for i=1:10
while true
    if (live_imgs)  zumom = rgb2gray(snapshot(cam));
    else            zumom = rgb2gray(imread(sprintf('Pics/zumo%d.jpg',i)));
    end;
zumom(mask_img==0)=0;

diff_img = imsubtract(bkgndm,zumom);
diff_img = diff_img>max(max(diff_img))/2;

% Find connected components.
[areas, centroids, boxes] = step(blobAnalysis, diff_img);

if ~isempty(areas)
    % Sort connected components in descending order by area
    [~, idx] = sort(areas, 'Descend');
    % Get the largest component.
    centroid = double(centroids(idx(1:1),:));
    fprintf(1,'centroid at %.1f, %.1f',centroid(1),centroid(2));
    zloc.X = centroid(1);
    zloc.Y = centroid(2);
    
    fprintf(1,'.   change of %.1f.',dist_pose2d(zloc,last_zloc));
    if (last_zloc.X==-1) % initialize old location 
        zloc.Theta = 0;
        last_zloc.X = zloc.X;
        last_zloc.Y = zloc.Y;
        last_zloc.Theta = zloc.Theta;
    elseif (dist_pose2d(zloc,last_zloc)>10) % only update if significant motion
        zloc.Theta = atan2(zloc.Y-last_zloc.Y,zloc.X-last_zloc.X);
        fprintf(1,' T=%.2f',zloc.Theta);
        last_zloc.X = zloc.X;
        last_zloc.Y = zloc.Y;
        last_zloc.Theta = zloc.Theta;
    end
    fprintf(1,'\n');
    
    if (plotlocs)
        figure(2);
        quiver(last_zloc.X,last_zloc.Y,50*cos(last_zloc.Theta),50*sin(last_zloc.Theta));
        hold on;
        quiver(zloc.X,zloc.Y,50*cos(zloc.Theta),50*sin(zloc.Theta));
        axis([550 1000 200 800]);
        view(0,270);
    end
    send(pub_zloc,zloc); % publish to ROS
    %hold on; quiver(zloc.X,zloc.Y,50*cos(zloc.Theta),50*sin(zloc.Theta)); hold off;
else
    fprintf(1,'Sorry, no zumo in that frame\n');
    imshow(zumom);
    title('Zumo-less image??');
end
end % for i=1:10