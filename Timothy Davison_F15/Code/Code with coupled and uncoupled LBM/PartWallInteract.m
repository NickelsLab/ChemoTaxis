function [force_cw pw_torque] = PartWallInteract(lx,ly,idimension,iflag,num_coll_par,center_coll,rad_coll,search_distance,index_att_rep_cw,spring_cons,rep_strength_cw,att_strength_cw,stiff_param_cw,electrostat_exp_cw)
    force_cw=zeros(num_coll_par,idimension);  % set all partile-wall interaction forces to zero in each time step
    pw_torque=zeros(num_coll_par);

    % calculate particle-wall interaction forces
    % check if there are stationary objects nearby a particle

    for i_colp=1:num_coll_par

        for id=1:idimension
            center(id)=center_coll(i_colp,id+1);
        end
        rad_par=rad_coll(i_colp);
        rad_search=rad_par+search_distance;

        ix_left  = max(floor(center(1)-rad_search),1);
        ix_right = min(floor(center(1)+rad_search),lx);
        iy_down  = max(floor(center(2)-rad_search),1);
        iy_up    = min(floor(center(2)+rad_search),ly);

        % search if there is any no-flow nodes in the search direction
        num_anchor=0;
        for i=ix_left:ix_right
            for j=iy_down:iy_up
                dx_c=i-center(1);
                dy_c=j-center(2);
                distance=sqrt((dx_c*dx_c)+(dy_c*dy_c));
                if ((distance>=rad_par)&&(distance<=rad_search))
                    if (iflag(i,j) == 1)
                        num_anchor=num_anchor+1;
                        iflag_col_anchor(i_colp)=0;         %anchored particle  
                        dist_anchor(num_anchor)=distance;   %record all no-flow nodes in the vicinity of the particle
                        ix_immob(num_anchor)=i;
                        iy_immob(num_anchor)=j;
                    end
                end
            end
        end

        if(num_anchor > 0)   %if there is at least one anchor point
            % compute all anchor points and associated forces 
            for i=1:num_anchor  

                % calculate the unit vector between the particle and a solid node it would anchored to
                un_vel_vec_anchor(1)=(center(1)-ix_immob(i))/dist_anchor(i);  %x component
                un_vel_vec_anchor(2)=(center(2)-iy_immob(i))/dist_anchor(i);  %y component

                % repulsive force occurs between the particle surface and the channel wall surface; 
                dist_min=dist_anchor(i)-rad_coll(i_colp);

                % calculate the particle-wall interaction potential

                if(index_att_rep_cw == 1) %HS 
                    part_wall_potential=(spring_cons/2.0)*(2.0*rad_coll(i_colp)-dist_min)*...
                        (rad_coll(i_colp)+rad_coll(i_colp_pair)-dist_min);
                elseif(index_att_rep_cw == 2) %LJ
                    dist_min_rep=dist_min*dist_min*dist_min*dist_min*dist_min*dist_min*...
                        dist_min*dist_min*dist_min*dist_min*dist_min*dist_min*dist_min;
                    dist_min_att=dist_min*dist_min*dist_min*dist_min*dist_min*dist_min*dist_min;
                    part_wall_potential=(rep_strength_cw/dist_min_rep)-(att_strength_cw/dist_min_att);
                elseif(index_att_rep_cw == 3) %ES
                    part_wall_potential=stiff_param_cw*exp(-1.00*electrostat_exp_cw*dist_min);
                end

                force_anchor(i,1)=part_wall_potential*un_vel_vec_anchor(1);
                force_anchor(i,2)=part_wall_potential*un_vel_vec_anchor(2);

                % calculate the partile-wall interaction force
                force_cw(i_colp,1)=force_cw(i_colp,1)+force_anchor(i,1); %x component of the interaction force
                force_cw(i_colp,2)=force_cw(i_colp,2)+force_anchor(i,2); %y component of the interaction force

            end
        end

        for i=1:num_anchor
            pw_torque(i_colp)=pw_torque(i_colp)+(ix_immob(i)-center(1))...
                *force_anchor(i,2)-(iy_immob(i)-center(2))*force_anchor(i,1);
        end
    end
end

