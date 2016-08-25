% mask polygon came from impoly() function
% make_mask2 - use impoly

function m = make_mask2
if ~exist('calib_data','var') load calib_data; end;
b = imread('Pics/bkgrnd.jpg');
if ~exist('mask','var') load mask; end;
[ix,iy] = meshgrid(1:size(b,2),1:size(b,1));
ix = ix(:);
iy = iy(:);
in = inpolygon(ix,iy,mask(:,1),mask(:,2));
m=reshape(in,size(b,1),size(b,2));
imshow(m);