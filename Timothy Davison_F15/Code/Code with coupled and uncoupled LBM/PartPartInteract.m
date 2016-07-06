function [force_cc pp_torque] = PartPartInteract(it,it_coll,lx,ly,idimension,num_coll_par,center_coll,rad_coll,search_distance,index_att_rep_cc,index_att_rep_cw,threshold_mindist,rep_strength_cc,att_strength_cc,stiff_param_cc,electrostat_exp_cc)
    force_cc=zeros(num_coll_par,idimension);
    pp_torque=zeros(num_coll_par);
    iflag_col=zeros(lx,ly);

    % calculate the repulsive forces between the particles
    %-----------------------------------------------------------------------------------------------------------------------
    for i_colp=1:num_coll_par
        if((it > it_coll)&&(index_att_rep_cc ~= 0))
            % reference particle
            for id=1:idimension
                center(id)=center_coll(i_colp,id+1);    %use the particle position from the previous time step
            end
            rad_par=rad_coll(i_colp);
            rad_search=rad_par+search_distance;
            ix_left  = max(floor(center(1)-rad_search),1);
            ix_right = min(floor(center(1)+rad_search),lx);
            iy_down  = max(floor(center(2)-rad_search),1);
            iy_up    = min(floor(center(2)+rad_search),ly);

            % search if there is any no-flow nodes in the search direction
            num_pp=0;
            for i=ix_left:ix_right
                for j=iy_down:iy_up
                    dx_c=i-center(1);
                    dy_c=j-center(2);
                    distance=sqrt((dx_c*dx_c)+(dy_c*dy_c));
                    if((distance>=rad_par)&&(distance<=rad_search))
                        num_pp=num_pp+1;
                        dist_pp(num_pp)=distance;   %record all no-flow nodes in the vicinity of the particle
                        ix_pp(num_pp)=i;
                        iy_pp(num_pp)=j;
                    end
                end
            end

            % other particles
            for i_colp_pair=1:num_coll_par
                if(i_colp ~= i_colp_pair)                                       % different particles
                    for id=1:idimension
                        center_pair(id)=center_coll(i_colp_pair,id+1);
                    end

                    rad_par_pair=rad_coll(i_colp_pair);
                    rad_search_pair=rad_par_pair+search_distance;

                    ix_left_pair  = max(floor(center_pair(1)-rad_search_pair),1);
                    ix_right_pair = min(floor(center_pair(1)+rad_search_pair),lx);
                    iy_down_pair  = max(floor(center_pair(2)-rad_search_pair),1);
                    iy_up_pair    = min(floor(center_pair(2)+rad_search_pair),ly);

                    for i=ix_left_pair:ix_right_pair
                        for j=iy_down_pair:iy_up_pair
                            dx_c_pair=i-center_pair(1);
                            dy_c_pair=j-center_pair(2);
                            distance_pair=sqrt((dx_c_pair*dx_c_pair)+(dy_c_pair*dy_c_pair));
                            if(distance_pair<=rad_par_pair)
                                iflag_col(i,j)=1;
                            end
                        end
                    end

                    % check to see if other particles' inner nodes are within a threshold repulsive distance from teh reference coll
                    num_cc=0;
                    for i=1:num_pp
                        if(iflag_col(ix_pp(i),iy_pp(i))==1)
                            num_cc=num_cc+1;
                            ix_cc(num_cc)=ix_pp(i);
                            iy_cc(num_cc)=iy_pp(i);
                            dist_cc(num_cc)=dist_pp(i);
                        end
                    end

                    for i=1:num_cc
                        un_vel_vec_pp(1)=(center(1)-ix_cc(i))/dist_cc(i);  %x component
                        un_vel_vec_pp(2)=(center(2)-iy_cc(i))/dist_cc(i);  %y component

                        dist_min_pp=dist_cc(i)-rad_coll(i_colp);
                        if(dist_min_pp >= threshold_mindist)

                            if(index_att_rep_cw == 2) %LJ
                                dist_min_rep=dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*...
                                    dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp;
                                dist_min_att=dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp*dist_min_pp;
                                part_part_potential=(rep_strength_cc/dist_min_rep)-(att_strength_cc/dist_min_att);
                            elseif(index_att_rep_cw == 3) %ES
                                part_part_potential=stiff_param_cc*exp(-1.00*electrostat_exp_cc*dist_min_pp);
                            end

                            force_pp(i,1)=part_part_potential*un_vel_vec_pp(1);
                            force_pp(i,2)=part_part_potential*un_vel_vec_pp(2);

                            % calculate the partile-wall interaction force
                            force_cc(i_colp,1)=force_cc(i_colp,1)+force_pp(i,1); %x component of the interaction force
                            force_cc(i_colp,2)=force_cc(i_colp,2)+force_pp(i,2); %x component of the interaction force
                        end
                    end

                    for i=1:num_cc
                        pp_torque(i_colp)=pp_torque(i_colp)+(ix_cc(i)-center(1))...
                                 *force_pp(i,2)-(iy_cc(i)-center(2))*force_pp(i,1);
                    end
 
                    iflag_col(:,:)=0;

                end
            end     % different particles
  
        end

    end   %*****
end

