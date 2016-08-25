if ~exist('calib_data','var') load calib_data; end;
    
zumo1 = undistort_fisheye(calib_data.ocam_model,imread('Pics/2016-07-25-171336.jpg'),5,0);
bkgnd = undistort_fisheye(calib_data.ocam_model,imread('Pics/bkgrnd.jpg'),5,0);

% Only analyze portions within the sandbox
mask = make_mask;
zumo1m = zumo1;  zumo1m(mask==0)=0;
bkgndm = bkgnd;  bkgndm(mask==0)=0;

diff_img = imsubtract(zumo1m,bkgndm);
%imshow(diff_img>0);
diff_img = diff_img>0;

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

% Adjust for coordinate system shift caused by undistortImage
%boxes(:, 1:2) = bsxfun(@plus, boxes(:, 1:2), newOrigin); (??)

% Reduce the size of the image for display.
%scale = magnification / 100;
%imDetectedBlobs = imresize(zumo1m, scale);

% Insert labels for the coins.
zumo1m = insertObjectAnnotation(zumo1m, 'rectangle', ...
     boxes, 'zumo');
figure; imshow(zumo1m);
title('Detected Zumos');