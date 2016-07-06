function create_obstacle(Xs,Ys,cent,rc)
mid_x = Xs;
mid_y = (Ys + max(cent(:,2)))*1.2/2;
vec = rc - cent;
dist = ((vec(:,1)).^2 + (vec(:,2)).^2).^0.5;
rad = 10*max(dist);

xl = floor(mid_x-rad);
xh = ceil(mid_x+rad)
yl = floor(mid_y-2);
yh = ceil(mid_y+2);
[x1,y1] = create_rectangle(xl,xh,yl,yh,1);

[x2,y2] = create_rectangle(xl,xl+yh-yl,yh,Ys+0.5*rad,1);

[x2,y2] = create_rectangle(xl,xl+yh-yl,yh,Ys+0.5*rad,1);

[x3,y3] = create_rectangle(xh-(yh-yl),xh,yh,Ys+0.5*rad,1);

[x4,y4] = create_rectangle(Xs-0.25*rad,xh,Ys+0.5*rad,Ys+0.5*rad+yh-yl,1);

xg = [x1;x2;x3;x4];
yg = [y1;y2;y3;y4];
fileID = fopen('obstacles','w');
A = [xg yg ones(size(xg))]';
size(A)
fprintf(fileID,'%12.8f %12.8f %5d\n',A);
fclose(fileID);


end

function [xg,yg] = create_rectangle(xl,xh,yl,yh,h)
[xg, yg] = meshgrid(xl:h:xh,yl:h:yh);
size_xg1 = size(xg,1);
size_xg2 = size(xg,2);
xg = reshape(xg,size_xg1*size_xg2,1);
yg = reshape(yg,size_xg1*size_xg2,1);
end