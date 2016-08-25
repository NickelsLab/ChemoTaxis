%% track_zumo - find a zumo
%% track_zumo2 - loop through 10 images
%% track_zumo3 - drop the fisheye calibration as undistort is very slow.


% Only analyze portions within the sandbox
if ~exist('mask_img','var') load('mask_img.mat'); end;
if ~exist('bkgnd','var') bkgnd=rgb2gray(imread('Pics/bkgrnd.jpg')); end;
bkgndm = bkgnd; bkgndm(mask_img==0)=0;

for i=1:10
zumo = rgb2gray(imread(sprintf('Pics/zumo%d.jpg',i)));
zumom = zumo;  zumom(mask_img==0)=0;

diff_img = imsubtract(bkgndm,zumom);
diff_img = diff_img>max(max(diff_img))/2;

% Find connected components.
blobAnalysis = vision.BlobAnalysis('AreaOutputPort', true,...
    'CentroidOutputPort', false,...
    'BoundingBoxOutputPort', true,...
    'MinimumBlobArea', 20, 'ExcludeBorderBlobs', true);
[areas, boxes] = step(blobAnalysis, diff_img);

% Sort connected components in descending order by area
[~, idx] = sort(areas, 'Descend');

% Get the largest component.
boxes = double(boxes(idx(1:1), :));
fprintf(1,'found zumo at %.1f, %.1f\n',...
    boxes(1)+boxes(3)/2, boxes(2)+boxes(4)/2);

% Adjust for coordinate system shift caused by undistortImage
%boxes(:, 1:2) = bsxfun(@plus, boxes(:, 1:2), newOrigin); (??)

% Reduce the size of the image for display.
%scale = magnification / 100;
%imDetectedBlobs = imresize(zumo1m, scale);

% Insert labels for the coins.
%zumom = insertObjectAnnotation(zumom, 'rectangle', boxes, 'zumo');
%imshow(zumom);
%title('Detected Zumo');
%drawnow;
end