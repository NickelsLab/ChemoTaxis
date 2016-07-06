function [force_unc torques_un force_cnc torques_cn u_b iflag_immob_col] = Cover(ln_ic,k_iter,ln_ic_old,k_iter_old,idimension,idim,un_vel_vec,dist2,f_dens,par_veloc,iflag_immob_col,u_b,center_coll,num_coll_par)
    for i_colp=1:num_coll_par
        
        num_cfn_max = -100;
        num_ufn_max = -100;

        % compute coordinates of newly uncovered nodes
        num_ufn=0;                         %number of exposed fluid nodes
        for i=1:k_iter_old(i_colp)
            % compare the old intra-particle fluid nodes with the new ones to find out which ones have been uncovered in the current time step
            iter_ufn=0;                     %k_iter is the number of nodes inside the particle at the current time step
            for j=1:k_iter(i_colp)
                if((ln_ic_old(i_colp,i,1) ~= ln_ic(i_colp,j,1)) || (ln_ic_old(i_colp,i,2) ~= ln_ic(i_colp,j,2)))
                    iter_ufn=iter_ufn+1;
                end
            end

            if(iter_ufn == k_iter(i_colp))                           %if they are equal,then the fluid node ix_ic_old(i) has been uncovered
                num_ufn=num_ufn+1;
                ln_ic_ufn(num_ufn,:)=ln_ic_old(i_colp,i,:);              %record the coordinates of the new (uncovered) fluid nodes
            end
        end 

        % compute coordinates of newly covered nodes
        num_cfn=0;                                                   %number of covered fluid nodes
        for i=1:k_iter(i_colp)                                            %compare new intra-particle fluid nodes with the old ones to find out which ones have been covered in the current time step
            iter_cfn=0;                                               %k_iter is the number of nodes inside the particle at the current time step
            for j=1:k_iter_old(i_colp)
                if((ln_ic(i_colp,i,1) ~= ln_ic_old(i_colp,j,1)) || (ln_ic(i_colp,i,2) ~= ln_ic_old(i_colp,j,2)))
                    iter_cfn=iter_cfn+1;
                end
            end

            if(iter_cfn == k_iter_old(i_colp))                          %if they are equal,then the fluid node ix_ic_(i) has been the newly covered node
                num_cfn=num_cfn+1;
                ln_ic_cfn(num_cfn,:)=ln_ic(i_colp,i,:);                  %record the coordinates of the new (covered) fluid nodes
            end
        end                                                      % now we have identified coordinates of all -covered- fluid nodes.

        % report the number of covered and uncovered nodes
        if(num_ufn > num_ufn_max)
            num_ufn_max = num_ufn;
        end
        if(num_cfn > num_cfn_max)
            num_cfn_max = num_cfn;
        end

        % compute the forces and torques to be exerted on particles due to covered and uncovered nodes
        for i=1:num_ufn
            i_ufn=ln_ic_ufn(i,1);                                            %x-coor of the nodes uncovered due to (icp)th particle motion
            j_ufn=ln_ic_ufn(i,2);
            vel_un=zeros(idimension,1);

            for k=1:idim
                for id=1:idimension
                    vel_un(id)=vel_un(id)+dist2(k,i_ufn,j_ufn)*un_vel_vec(k,id);
                end
            end
            for id=1:idimension
                u_ufn(i,id)=vel_un(id)/f_dens(i_ufn,j_ufn);
            end
        end

        sum_force_un=zeros(1,idimension);
        sum_torque_un=0.0;
        % a small impulse of force is applied to the solid particle when a virtual node is UNcovered
        for i=1:num_ufn
            i_ufn=ln_ic_ufn(i,1);
            j_ufn=ln_ic_ufn(i,2);
            for id=1:idimension
                force_un(i,id)=-f_dens(i_ufn,j_ufn)*(u_ufn(i,id)-par_veloc(i_colp,id));
                sum_force_un(id)=sum_force_un(id)+force_un(i,id);
            end
                sum_torque_un=sum_torque_un+(real(i_ufn)-center_coll(i_colp,2))*force_un(i,2)...
                              -(real(j_ufn)-center_coll(i_colp,3))*force_un(i,1);
        end

        % compute the total force and torque exterted on the particle due to all uncovered fluid nodes

        force_unc(i_colp,:)=sum_force_un;
        torques_un(i_colp)=sum_torque_un;

        % transferred force and torque when a virtual node is Covered

        n_solid=0;
        for i=1:num_cfn
            i_cfn=ln_ic_cfn(i,1);
            j_cfn=ln_ic_cfn(i,2);
            if(f_dens(i_cfn,j_cfn) == 0)
                n_solid=n_solid+1;            %Change 1 check if particle overlaps any solid latiice node
            end
        end

        if(n_solid > 0)
            iflag_immob_col(i_colp)=0;                     %Change 2 immobilize the colloid and tag the immobile colloid
        end

        for i=1:num_cfn
            i_cfn=ln_ic_cfn(i,1);
            j_cfn=ln_ic_cfn(i,2);
            vel_cn=zeros(idimension,1);

            for k=1:idim
                for id=1:idimension
                    vel_cn(id)=vel_cn(id)+dist2(k,i_cfn,j_cfn)*un_vel_vec(k,id);
                end
            end

            for id=1:idimension
                if (iflag_immob_col(i_colp)== 1)       %if no colloid is immobilized
                    u_cfn(i,id)=vel_cn(id)/f_dens(i_cfn,j_cfn);
                else
                    u_cfn(i,id)=0.0;           %change 3 if so, fluid velocity at those points must be zero
                end
            end

        end

        sum_force_cn=zeros(1,idimension);
        sum_torque_cn=0.0;

        % calculate the resultant force

        if (iflag_immob_col(i_colp) == 0)                              %change 4 if so, set all forces on the immobilized particle to zero
            sum_force_cn=zeros(1,idimension);
            sum_torque_cn=zeros(1,idimension);
        else
            for i=1:num_cfn
                i_cfn=ln_ic_cfn(i,1);
                j_cfn=ln_ic_cfn(i,2);
                for id=1:idimension
                    force_cn(i,id)=f_dens(i_cfn,j_cfn)*(u_cfn(i,id)-par_veloc(i_colp,id));
                    sum_force_cn(id)=sum_force_cn(id)+force_cn(i,id);
                end
                sum_torque_cn=sum_torque_cn+(real(i_cfn)-center_coll(i_colp,2))*force_cn(i,2)...
                              -(real(j_cfn)-center_coll(i_colp,3))*force_cn(i,1);
            end
        end

        % update u_b's at newly covered fluid nodes
        if (iflag_immob_col(i_colp) == 0)                           %change 5 if so, set the velocity at all boundary nodes to zero (immobile particle)
            for i=1:num_cfn
                i_cfn=ln_ic_cfn(i,1);
                j_cfn=ln_ic_cfn(i,2);
                u_b(i_colp,i_cfn,j_cfn,1:idim,1:idimension)=0.0;
            end
        else
            for i=1:num_cfn
                i_cfn=ln_ic_cfn(i,1);
                j_cfn=ln_ic_cfn(i,2);
                for ii=1:idim
                    u_b(i_colp,i_cfn,j_cfn,ii,1)=u_cfn(i,1);
                    u_b(i_colp,i_cfn,j_cfn,ii,2)=u_cfn(i,2);
                end
            end
        end

        % compute the total force and torque exterted on the particle due to all covered fluid nodes

        force_cnc(i_colp,:)=sum_force_cn;
        torques_cn(i_colp)=sum_torque_cn;
    
    end
end

