function [f_dens vel velx vely] = FluidDensVel(lx,ly,iflag,len_un_vel,un_vel_vec,dist)
%     % calculate densities and velocities
%     i1=1:len_un_vel;
%     velx = zeros(lx,ly);
%     vely = zeros(lx,ly);
%     vel = zeros(lx,ly);
%     for j=1:ly
%         for i=1:lx
%            if (iflag(i,j) == -1)
%               f_dens(i,j) = sum(dist(i1,i,j));
%               velx(i,j)=sum(dist(i1,i,j) .* un_vel_vec(i1,1)) ./ f_dens(i,j);
%               vely(i,j)=sum(dist(i1,i,j) .* un_vel_vec(i1,2)) ./ f_dens(i,j);
%               vel(i,j)=sqrt(velx(i,j)*velx(i,j)+vely(i,j)*vely(i,j));
%             end
%         end
%     end
    
    % Vectorized
    mask=(iflag==-1);
    f_dens=mask.*squeeze(sum(dist));
    velx=squeeze(sum(dist.*reshape(repmat(un_vel_vec(:,1),lx,ly),len_un_vel,lx,ly)))./f_dens;
    vely=squeeze(sum(dist.*reshape(repmat(un_vel_vec(:,2),lx,ly),len_un_vel,lx,ly)))./f_dens;
    velx(iflag~=-1)=0.0;
    vely(iflag~=-1)=0.0;
    vel=mask.*sqrt(velx.*velx+vely.*vely);
    %vel=mask.*velx;
end