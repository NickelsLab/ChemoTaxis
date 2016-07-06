function [ ln_vn ] = intrabndnodes(idimension,idim,un_vel_vec,ln_ic,k_iter,x_center,y_center,radius)
      
% calculate boundary nodes closest to particle surface
    center = [x_center y_center];
    n_count=0;
    for i=1:k_iter                                                         % number of virtual fluid nodes inside the particle
       num_iter=0;
       for j=1:idim                                                        %search directions
          distan1=0.d00;
          distan2=0.d00;
          for id=1:idimension
             next_node_1(id)=ln_ic(i,id)+un_vel_vec(j,id);
             next_node_2(id)=ln_ic(i,id)-un_vel_vec(j,id);                 % node in the opposite direction
             dist_1(id)=1.0*(next_node_1(id))-center(id);                   % distance of the new node from the center
             dist_2(id)=1.0*(next_node_2(id))-center(id);                  % distance of the opposing new node from the center
             distan1=distan1+dist_1(id)*dist_1(id);
             distan2=distan2+dist_2(id)*dist_2(id);
          end
          distance1=sqrt(distan1);
          distance2=sqrt(distan2);
          if((distance1 < radius) &&(distance2 > radius))
             num_iter=num_iter+1;
          end
       end

% new no-slip nodes at or near the particle surface
       if(num_iter >= 1)
          n_count=n_count+1;                                                %number of virtual fluid nodes/no-slip nearest to the particle's surface
          for id=1:idimension
             ln_vn(n_count,id)=ln_ic(i,id);
          end
       end
    end
    
end

