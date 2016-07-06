function dist = Collision(lx,ly,iflag,len_un_vel,un_vel_vec,dist,dist2,alambda,gravity,weight,c_s_sq,c_s_dsq,shear_boundary_flag,u_xCF,u_yCF)
%     %disp('Collision')
%     %pause
%     rel_param=-1.d00/alambda;
%     %i1=1:len_un_vel;
%     f_dens = zeros(lx,ly);
%     for j=1:ly
%        for i=1:lx
%           if(iflag(i,j) == -1)   
% 
% %              i1=1:len_un_vel;
% %              f_dens(i,j)=sum(dist2(i1,i,j));       
% %              u_x=sum(dist2(i1,i,j) .* un_vel_vec(i1,1)) ./ f_dens(i,j) + alambda*gravity(1);
% %              u_y=sum(dist2(i1,i,j) .* un_vel_vec(i1,2)) ./ f_dens(i,j) + alambda*gravity(2);
% %              u_sq=u_x*u_x+u_y*u_y;
% 
%              %same as commented code above
%              fluid_dens = 0;
%              sumx = 0;
%              sumy = 0;
%              for k=1:len_un_vel
%                 fluid_dens = fluid_dens+dist2(k,i,j);        %local density
%                 sumx = sumx+dist2(k,i,j)*un_vel_vec(k,1);
%                 sumy = sumy+dist2(k,i,j)*un_vel_vec(k,2);
%              end 
%              f_dens(i,j) = fluid_dens;
%              u_x = sumx/f_dens(i,j)+alambda*gravity(1);      %x-component 
%              u_y = sumy/f_dens(i,j)+alambda*gravity(2);
%
%              if (shear_boundary_flag == 1)
%                 if (j==2)
%                    u_x = -u_xCF/2;
%                    u_y = 0.0;
%                 elseif (j==ly-1)
%                    u_x = u_xCF/2;
%                    u_y = 0.0;
%                 end
%              end
% 
%              %square velocity
%              u_sq=u_x*u_x+u_y*u_y;
% 
%              u_n = zeros(len_un_vel,1);
%              for k=1:len_un_vel
%                 u_n(k)=u_x*un_vel_vec(k,1)+u_y*un_vel_vec(k,2);
%                 equ=weight(k)*f_dens(i,j)*(1.d00+u_n(k)/c_s_sq+(u_n(k)*u_n(k))/(2.d00*c_s_dsq)-u_sq/(2.d00*c_s_sq));
%                 dist(k,i,j)=dist2(k,i,j)+rel_param*(dist2(k,i,j)-equ);
% 
%                 %k,i,j,u_n(k),equ,dist(k,i,j)
%                 %pause
%              end
%           end
%        end
%     end
    
    % Vectorized
    rel_param=-1.d00/alambda;
    mask1=(iflag==-1);
    f_dens=mask1.*squeeze(sum(dist2));
    u_x=squeeze(sum(dist2.*reshape(repmat(un_vel_vec(:,1),lx,ly),len_un_vel,lx,ly)))./f_dens+alambda*gravity(1);
    u_y=squeeze(sum(dist2.*reshape(repmat(un_vel_vec(:,2),lx,ly),len_un_vel,lx,ly)))./f_dens+alambda*gravity(2);
    u_x(iflag~=-1)=0.0;
    u_y(iflag~=-1)=0.0;

%%%Alex's change on May 7
    % Code to handle shear walls
    if (shear_boundary_flag == 1)
        u_x(:,2) = -u_xCF/2;
        u_y(:,2) = 0.0;
        u_x(:,ly-1) = u_xCF/2;
        u_y(:,ly-1) = 0.0;
    end
%%%Alex's change on May 7

    u_sq=u_x.*u_x+u_y.*u_y;
    mask2=permute(reshape(repmat((iflag==-1),1,len_un_vel),lx,ly,len_un_vel),[3,1,2]);
    u_n=(permute(reshape(repmat(u_x,1,len_un_vel),lx,ly,len_un_vel),[3,1,2]).*...
        reshape(repmat(un_vel_vec(:,1),lx,ly),len_un_vel,lx,ly)+...
        permute(reshape(repmat(u_y,1,len_un_vel),lx,ly,len_un_vel),[3,1,2]).*...
        reshape(repmat(un_vel_vec(:,2),lx,ly),len_un_vel,lx,ly));
    equ=reshape(repmat(weight',lx,ly),len_un_vel,lx,ly).*...
        permute(reshape(repmat(f_dens,1,len_un_vel),lx,ly,len_un_vel),[3,1,2]).*...
        (1.0+u_n/c_s_sq+(u_n.*u_n)/(2.0*c_s_dsq)-...
        permute(reshape(repmat(u_sq,1,len_un_vel),lx,ly,len_un_vel),[3,1,2])/(2.0*c_s_sq));
    dist=mask2.*(dist2+rel_param*(dist2-equ))+(1.0-mask2).*dist;
end

