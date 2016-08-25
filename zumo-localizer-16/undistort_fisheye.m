%UNDISTORT unwrap part of the image onto a plane perpendicular to the
%camera axis
%   B = UNDISTORT(OCAM_MODEL, A, FC, DISPLAY)
%   A is the input image
%   FC is a factor proportional to the distance of the camera to the plane;
%   start with FC=5 and then tune the parameter to change the result.
%   DISPLAY visualizes the output image if set to 1; its default value is
%   0.
%   B is the final image
%   Note, this function uses nearest neighbour interpolation to unwrap the
%   image point. Better undistortion methods can be implemented using
%   bilinear or bicub interpolation.
%   Note, if you want to change the size of the final image, change Nwidth
%   and Nheight
%   Author: Davide Scaramuzza, 2009

function Nimg = undistort( ocam_model, img , fc, display)

% Parameters of the new image
%Nwidth = 640; %size of the final image
%Nheight = 480;
Nwidth = 1080;
Nheight = 1920;
Nxc = Nheight/2;
Nyc = Nwidth/2;
Nz  = -Nwidth/fc;

if ~isfield(ocam_model,'pol') 
    width = ocam_model.width;
    height = ocam_model.height;
    %The ocam_model does not contain the inverse polynomial pol
    ocam_model.pol = findinvpoly(ocam_model.ss,sqrt((width/2)^2+(height/2)^2));
end

if nargin < 3
    fc = 5;%distance of the plane from the camera, change this parameter to zoom-in or out
    display = 0;
end
    
if length(size(img)) == 3;
    Nimg = zeros(Nheight, Nwidth, 3);
else
    Nimg = zeros(Nheight, Nwidth);
end

[i,j] = meshgrid(1:Nheight,1:Nwidth);
Nx = i-Nxc;
Ny = j-Nyc;
Nz = ones(size(Nx))*Nz;
M = [Nx(:)';Ny(:)';Nz(:)'];
m = world2cam_fast( M , ocam_model );

if length(size(img)) == 2 % make BW into RGB
    I(:,:,1) = img;
    I(:,:,2) = img;
    I(:,:,3) = img;    
else
    I = img;
end
[r,g,b] = get_color_from_imagepoints( I, m' );
Nimg = reshape(r,Nwidth,Nheight)';


% Nimg = uint8(Nimg);
if display
    figure; imagesc(Nimg); colormap(gray);
end

% M = cam2world( distorted_points' , ocam_model );
% M = M./(ones(3,1)*M(3,:))*(Nz);
% 
% ti = M(1,:) + Nxc;
% tj = M(2,:) + Nyc;
% 
% scale_factor = abs(Nz);
% 
% und_points = [ti ; tj]';



%WORLD2CAM projects a 3D point on to the image
%   m=WORLD2CAM_FAST(M, ocam_model) projects a 3D point on to the
%   image and returns the pixel coordinates. This function uses an approximation of the inverse
%   polynomial to compute the reprojected point. Therefore it is very fast.
%   
%   M is a 3xN matrix containing the coordinates of the 3D points: M=[X;Y;Z]
%   "ocam_model" contains the model of the calibrated camera.
%   m=[rows;cols] is a 2xN matrix containing the returned rows and columns of the points after being
%   reproject onto the image.
%   
%   Copyright (C) 2008 DAVIDE SCARAMUZZA, ETH Zurich  
%   Author: Davide Scaramuzza - email: davide.scaramuzza@ieee.org

function m = world2cam_fast(M, ocam_model)

ss = ocam_model.ss;
xc = ocam_model.xc;
yc = ocam_model.yc;
width = ocam_model.width;
height = ocam_model.height;
c = ocam_model.c;
d = ocam_model.d;
e = ocam_model.e;
pol = ocam_model.pol;

npoints = size(M, 2);
theta = zeros(1,npoints);

NORM = sqrt(M(1,:).^2 + M(2,:).^2);

ind0 = find( NORM == 0); %these are the scene points which are along the z-axis
NORM(ind0) = eps; %this will avoid division by ZERO later

theta = atan( M(3,:)./NORM );

rho = polyval( pol , theta ); %Distance in pixel of the reprojected points from the image center

x = M(1,:)./NORM.*rho ;
y = M(2,:)./NORM.*rho ;

%Add center coordinates
m(1,:) = x*c + y*d + xc;
m(2,:) = x*e + y   + yc;




%FINDINVPOLY finds the inverse polynomial specified in the argument.
%   [POL, ERR, N] = FINDINVPOLY(SS, RADIUS, N) finds an approximation of the inverse polynomial specified in OCAM_MODEL.SS.
%   The returned polynomial POL is used in WORLD2CAM_FAST to compute the reprojected point very efficiently.
%   
%   SS is the polynomial which describe the mirrror/lens model.
%   RADIUS is the radius (pixels) of the omnidirectional picture.
%   ERR is the error (pixel) that you commit in using the returned
%   polynomial instead of the inverse SS. N is searched so that
%   that ERR is < 0.01 pixels.
%
%   Copyright (C) 2008 DAVIDE SCARAMUZZA, ETH Zurich
%   Author: Davide Scaramuzza - email: davide.scaramuzza@ieee.org

function [pol, err, N] = findinvpoly(ss, radius)

if nargin < 3
    maxerr = inf;
    N = 1;
    while maxerr > 0.01 %Repeat until the reprojection error is smaller than 0.01 pixels
        N = N + 1;
        [pol, err] = findinvpoly2(ss, radius, N);
        maxerr = max(err);  
    end
else
    [pol, err, N] = findinvpoly2(ss, radius, N)
end

function [pol, err, N] = findinvpoly2(ss, radius, N)

theta = [-pi/2:0.01:1.20];
r     = invFUN(ss, theta, radius);
ind   = find(r~=inf);
theta = theta(ind);
r     = r(ind);

pol = polyfit(theta,r,N);
err = abs( r - polyval(pol, theta)); %approximation error in pixels

function r=invFUN(ss, theta, radius)

m=tan(theta);

r=[];
poly_coef=ss(end:-1:1);
poly_coef_tmp=poly_coef;
for j=1:length(m)
    poly_coef_tmp(end-1)=poly_coef(end-1)-m(j);
    rhoTmp=roots(poly_coef_tmp);
    res=rhoTmp(find(imag(rhoTmp)==0 & rhoTmp>0 & rhoTmp<radius ));
    if isempty(res) | length(res)>1
        r(j)=inf;
    else
        r(j)=res;
    end
end



function [r,g,b] = get_color_from_imagepoints( im1, key1 )

height = size(im1,1);
width  = size(im1,2);

key1 = round(key1);

% Correct points which are outside image borders
indH = find( key1(:,1)<1 | key1(:,1)>height | isnan(key1(:,1)) );
key1(indH,1) = 1;
key1(indH,2) = 1;
indW = find( key1(:,2)<1 | key1(:,2)>width  | isnan(key1(:,2)) );
key1(indW,1) = 1;
key1(indW,2) = 1;

im1(1,1,1) = 0;
im1(1,1,2) = 0;
im1(1,1,3) = 0;

RI = im1(:,:,1);
GI = im1(:,:,2);
BI = im1(:,:,3);

r = RI(sub2ind( [height,width], key1(:,1), key1(:,2) ));
g = GI(sub2ind( [height,width], key1(:,1), key1(:,2) ));
b = BI(sub2ind( [height,width], key1(:,1), key1(:,2) ));

