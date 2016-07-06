function [ ln_ic ] = intraparticlenodes(x_center,y_center,radius)

% calculates boundary nodes along the particle surface

r2=radius^2;                             %particle radius
% defining a box around the circular particle
ix_left=floor(x_center-radius);           
ix_right=ceil(x_center+radius);
iy_down=floor(y_center-radius);
iy_up=ceil(y_center+radius);
error_tol=0.1;

% % corner points of a box
% ix_left;
% ix_right;
% iy_down;
% iy_up;

% calculate boundary nodes
k_iter=0;
surfnodes=[];
ln_ic=[];

   k_iter=0;
     for i=ix_left:1:ix_right
        for j=iy_down:1:iy_up
            dx_c=1.0*i-x_center;
            dy_c=1.0*j-y_center;
            distance=sqrt((dx_c*dx_c)+(dy_c*dy_c));
            if(distance <= radius) 
              k_iter=k_iter+1;                                             %number of fluid nodes inside the solid particle
              ln_ic(k_iter,1)=i;                             %x_component of the lattice nodes covered by the colloid
              ln_ic(k_iter,2)=j;                             %y_component of the lattice nodes covered by the colloid
            end
        end
     end




% ln_ic    ;                                    % boundary nodes
% length(ln_ic)                               % number of boundary nodes


end

