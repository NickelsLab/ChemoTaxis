function m = make_mask
if ~exist('calib_data','var') load calib_data; end;
b = undistort_fisheye(calib_data.ocam_model,imread('Pics/bkgrnd.jpg'),5,0);
roi = [ 296 629 622 283; ...  % Y pts
        783 800 1087 1079]';  % X pts 
[ix,iy] = meshgrid(1:size(b,2),1:size(b,1));
ix = ix(:);
iy = iy(:);
in = inpolygon(ix,iy,roi(:,1),roi(:,2));
m=reshape(in,size(b,1),size(b,2));
%imshow(m);