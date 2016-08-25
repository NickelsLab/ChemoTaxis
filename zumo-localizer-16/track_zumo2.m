if ~exist('calib_data','var') load calib_data; end;
if ~exist('bkgnd','var') bkgnd = undistort_fisheye(calib_data.ocam_model,imread('Pics/bkgrnd.jpg'),5,0); end;

% Only analyze portions within the sandbox
mask = make_mask;
bkgndm = bkgnd;  bkgndm(mask==0)=0;

for i=1:3
zumo = undistort_fisheye(calib_data.ocam_model,imread(sprintf('Pics/zumo%d.jpg',i)),5,0);
zumom = zumo;  zumom(mask==0)=0;

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

% Adjust for coordinate system shift caused by undistortImage
%boxes(:, 1:2) = bsxfun(@plus, boxes(:, 1:2), newOrigin); (??)

% Reduce the size of the image for display.
%scale = magnification / 100;
%imDetectedBlobs = imresize(zumo1m, scale);

% Insert labels for the coins.
zumom = insertObjectAnnotation(zumom, 'rectangle', boxes, 'zumo');
imshow(zumom);
title('Detected Zumo');
drawnow;
end