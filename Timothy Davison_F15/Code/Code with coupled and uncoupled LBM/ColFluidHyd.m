function [ln_ic_old k_iter_old prev_sum_force prev_par_torque center_coll par_veloc par_ang_vel u_b...
    rc cent rotation_at_rc ang_vel] = ...
    ColFluidHyd(it,it_coll,n_iter,idimension,ln_ic,k_iter,ln_mlink_vn,ln_mlink_vn_pair,i_dir_vec,direc_vec,...
    f_dens,dist,weight,c_s_sq,u_b,un_vel_vec,center_coll,dens_par,mass_par,val_inertia,prev_sum_force,prev_par_torque,...
    par_veloc,par_ang_vel,iflag_immob_col,delX,delT,gravity,force_unc,torques_un,force_cnc,torques_cn,sampleint,...
    num_coll_par,force_cw,force_cc,pw_torque,f_run,angr,rc,cent,rotation_at_rc,ang_vel,fac_tumble)

    delX3 = delX*delX*delX;
    vec=rc-cent;

    if(it >= it_coll)
        ln_ic_old=[];
        for i_colp=1:num_coll_par
            sum_forces(1:idimension)=0.d0;
            for im=1:n_iter(i_colp)
                ix_i=ln_mlink_vn(i_colp,im,1);                        %inside the particle
                iy_i=ln_mlink_vn(i_colp,im,2);
                ix_o=ln_mlink_vn_pair(i_colp,im,1);                   %outside the particle
                iy_o=ln_mlink_vn_pair(i_colp,im,2);
                i_vec=i_dir_vec(i_colp,im);                           %directional vector
                i_vec_op=direc_vec(i_vec-1,2)+1;                         %opposite direction of the directional vector

                % hydrodynamic force acting on boundary nodes -half-way between the lattice node at the half-time step
                fluid_dens=f_dens(ix_o,iy_o);

                force_t(im)=-2.0*(delX3/delT)*(dist(i_vec_op,ix_o,iy_o)...
                            +(fluid_dens*weight(i_vec)/c_s_sq)*(u_b(i_colp,ix_i,iy_i,i_vec,1)*un_vel_vec(i_vec,1)...
                            +u_b(i_colp,ix_i,iy_i,i_vec,2)*un_vel_vec(i_vec,2)));
                %fprintf(fileID,'%i %i %i %f %f\n',it,im,i_vec_op,dist(i_vec_op,ix_o,iy_o),force_t(im));
                for id=1:idimension
                    force(im,id)= force_t(im)*un_vel_vec(i_vec,id);
                    sum_forces(id)=sum_forces(id)+force(im,id);          %x-component of the total particle force
                end
            end
            %fprintf(fileID,'%i %f %f\n',it,sum_forces(1),sum_forces(2));
            % include the transferred force due to covered and uncovered virtual nodes
            if(it > it_coll)
                sum_forces=sum_forces+force_unc(i_colp,:)+force_cnc(i_colp,:)+f_run(i_colp,:);
            end

            sum_par_torque=0.0;

            % compute contributions of forces to particle torque (rB X F)
            for im=1:n_iter(i_colp)
                ix_i=ln_mlink_vn(i_colp,im,1);                        %inside the particle
                iy_i=ln_mlink_vn(i_colp,im,2);
                i_vec=i_dir_vec(i_colp,im);                 %directional vector

                % first compute coordinates of boundary nodes
                coor_bnd(ix_i,iy_i,i_vec,1)=real(ix_i)+5.d-1*un_vel_vec(i_vec,1)*delT;     %x-component
                coor_bnd(ix_i,iy_i,i_vec,2)=real(iy_i)+5.d-1*un_vel_vec(i_vec,2)*delT;     %y-component

                % next compute the distance between boundary nodes and the centroid of the particle
                rb_R_bnd(ix_i,iy_i,i_vec,1)=coor_bnd(ix_i,iy_i,i_vec,1)-center_coll(i_colp,2);
                rb_R_bnd(ix_i,iy_i,i_vec,2)=coor_bnd(ix_i,iy_i,i_vec,2)-center_coll(i_colp,3);

                % and the particle torque (rB X F)
                sum_par_torque=sum_par_torque+rb_R_bnd(ix_i,iy_i,i_vec,1)...
                                    *force(im,2)-rb_R_bnd(ix_i,iy_i,i_vec,2)*force(im,1);
            end
            
            %%%Hoa
            sum_par_torque=sum_par_torque+vec(i_colp,1)*f_run(i_colp,2)-vec(i_colp,2)*f_run(i_colp,1); %torque due to running force 

            %T_tumble = (val_inertia/delT)*(angr/delT - ang_vel);  
            T_tumble = (fac_tumble/delT)*(angr(i_colp)/delT - ang_vel(i_colp)); %let intertia = 1
            sum_par_torque = sum_par_torque+T_tumble;  
            ang_vel(i_colp) = ang_vel(i_colp) + delT*T_tumble/val_inertia(i_colp);            
            %%%Hoa
            
            % include the transferred torque due to covered and uncovered virtual nodes
            if(it > it_coll)
                sum_par_torque=sum_par_torque+torques_un(i_colp)+torques_cn(i_colp);
            end

            % include the additional force arising from distribution of extra mass and inter-particle forces (van der Waals)
            sum_forces=sum_forces+force_cw(i_colp,:)+force_cc(i_colp,:);

            % smooth out the force term
            sum_forces=0.5*(sum_forces+prev_sum_force(i_colp,:));

            % store them for the next time step
            prev_sum_force(i_colp,:)=sum_forces;

            % include the additional torque arising from distribution of extra mass
            sum_par_torque=sum_par_torque+pw_torque(i_colp);

            % smooth out the torque term
            sum_par_torque=0.5*(sum_par_torque+prev_par_torque(i_colp));

            % store it for the next time step
            prev_par_torque(i_colp)=sum_par_torque;

            % particle angular velocity
            if (iflag_immob_col(i_colp) == 1)                      %change 8
                %angr
                %par_ang_vel
                %val_inertia
                %pause
                par_ang_vel(i_colp)=par_ang_vel(i_colp)+delT*(sum_par_torque/val_inertia(i_colp)); % + angr;
                %par_ang_vel
            else
                par_ang_vel(i_colp)=0.0;
            end

            rotation_at_rc(i_colp) = rotation_at_rc(i_colp) + par_ang_vel(i_colp)*delT; % AJC 2/16/2015
            
            % compute local components of the angular velocity (n X (rB-R))
            if (iflag_immob_col(i_colp) == 0)                      %change 9
                for im=1:n_iter(i_colp)
                    ix_i=ln_mlink_vn(i_colp,im,1);                        %inside the particle
                    iy_i=ln_mlink_vn(i_colp,im,2);
                    i_vec=i_dir_vec(i_colp,im);                 %directional vector
                    ang_loc_vel(ix_i,iy_i,i_vec,1)=0.0;
                    ang_loc_vel(ix_i,iy_i,i_vec,2)=0.0;
                end
            else
                for im=1:n_iter(i_colp)
                    ix_i=ln_mlink_vn(i_colp,im,1);                        %inside the particle
                    iy_i=ln_mlink_vn(i_colp,im,2);
                    i_vec=i_dir_vec(i_colp,im);                 %directional vector
                    ang_loc_vel(ix_i,iy_i,i_vec,1)=-1.0*rb_R_bnd(ix_i,iy_i,i_vec,2)*par_ang_vel(i_colp);
                    ang_loc_vel(ix_i,iy_i,i_vec,2)=rb_R_bnd(ix_i,iy_i,i_vec,1)*par_ang_vel(i_colp);
                end
            end

            if (iflag_immob_col(i_colp) == 1)                      %change 10
                for id=1:idimension
                    %x-component of the particle velocity
                    %sum_forces(id)
                    %pause
                    par_veloc(i_colp,id)=par_veloc(i_colp,id)+delT*((sum_forces(id))/mass_par(i_colp)...
                                    +((dens_par(i_colp)-1.0)/dens_par(i_colp))*gravity(id));
                end
            else
                par_veloc(i_colp,1)=0.0;
                par_veloc(i_colp,2)=0.0;
            end

            par_vel=sqrt(par_veloc(i_colp,1)*par_veloc(i_colp,1)+par_veloc(i_colp,2)*par_veloc(i_colp,2));

            % compute the local velocity of particle surfaces
            for im=1:n_iter(i_colp)
                ix_i=ln_mlink_vn(i_colp,im,1);                        %inside the particle
                iy_i=ln_mlink_vn(i_colp,im,2);
                i_vec=i_dir_vec(i_colp,im);                 %directional vector
                for ii=1:idimension
                    u_b(i_colp,ix_i,iy_i,i_vec,ii)=par_veloc(i_colp,ii)+ang_loc_vel(ix_i,iy_i,i_vec,ii);
                end
            end

            %rc
            %par_veloc
            %(rc - cent)
            %(rc - cent)*par_ang_vel
            %par_ang_vel
            %pause
            %rc = rc + delT*(par_veloc + (rc - cent)*par_ang_vel);
            %pause

            % store particle velocities
            par_velocity=par_veloc;

            % record the coordinates of the particle centroid before updating them
            if (it > it_coll)
                cent_coll_old=center_coll;
            end

            % move the particle (its centroid) to its next position in accordance with the solid particle velocity
            for id=1:idimension
                center_coll(i_colp,id+1)=center_coll(i_colp,id+1)+par_velocity(i_colp,id)*delT;
                cent(i_colp,id) = center_coll(i_colp,id+1); % AJC 2/16/2015
            end

            %rc(i_colp,:)
            %rotation_at_rc
            %angr
            rc(i_colp,1) = cent(i_colp,1) + norm(vec(i_colp,:))*cos(rotation_at_rc(i_colp)); % AJC 2/16/2015
            rc(i_colp,2) = cent(i_colp,2) + norm(vec(i_colp,:))*sin(rotation_at_rc(i_colp)); % AJC 2/16/2015
            %rc(i_colp,:)
            %pause
            
            %-----------------------------------------------------------------------
            k_iter_old=k_iter;             % number of fluid nodes covered by the solid particle

            % x- and y- coordinates of the fluid nodes covered by the solid particle in the previous time-step
            for i=1:k_iter_old(i_colp)
                for id=1:idimension
                    ln_ic_old(i_colp,i,id)=ln_ic(i_colp,i,id);
                end
            end                         % fluid nodes covered by the solid particle in the previous time-step
            
                    % Write output information
%             if(mod(it,sampleint)==0)
%                 fprintf(fileID(i_colp),'%i %f %f %f %f\n',it,center_coll(i_colp,2),center_coll(i_colp,3),par_vel,par_ang_vel(i_colp));
%             end
        end
        
    %-------------------- end of colloidal transport section ----------------------------------------------------------!
    else
        
        ln_ic_old=[];
        k_iter_old=zeros(num_coll_par);
    
    end
end

