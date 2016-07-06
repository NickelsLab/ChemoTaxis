function [f_dens dist] = Initialize(fluid_dens,lx,ly,len_un_vel,weight)
    % fluid densities
    f_dens=fluid_dens*ones(lx,ly);
 
    %distribution function (f populations)
    dist=zeros(len_un_vel,lx,ly);
    for k=1:len_un_vel
        dist(k,1:lx,1:ly)=fluid_dens*weight(k);
    end
end