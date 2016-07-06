function f = ffuncint(p,t,u,time)
% load('velx_object.mat')
% load('vely_object.mat')
load('velx2.mat')
load('vely2.mat')
velx = velx';
vely = vely';
% % velx = velx(2:3,2:21);
% % vely = vely(2:3,2:21);
% velx = -2*ones(2,20);
% % v = [0 2 3 4; 5 6 7 4];
% % Triangle point indices
[ux, uy] = pdegrad(p,t,u);
it1 = t(1,:);
it2 = t(2,:);
it3 = t(3,:);
% Find centroids of triangles
xpts = (p(1,it1)+p(1,it2)+p(1,it3))/3;
ypts = (p(2,it1)+p(2,it2)+p(2,it3))/3;
xval = round(xpts*1000);
yval = round(ypts*1000);
x = linspace(0,1,400);
y = linspace(0,1,200);
% xq = 0:0.0001:1;
% yq = 0:0.0001:1;
[xq yq] = meshgrid(0:0.001:1,0:0.001:1);
vx = griddata(x,y,velx,xq,yq);
vy = griddata(x,y,vely,xq,yq);
cox = zeros(length(t),1);
coy = zeros(length(t),1);

for i = 1:length(t)
cox(i) = vx(xval(i),yval(i));
coy(i) = vy(xval(i),yval(i));
end

f =  -20*cox'.*ux - 10*coy'.*uy; % f on subdomain 1
end
% f = -ux-uy;