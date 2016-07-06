function [dist2] = post_coll_pop(ln_mlink_vn,ln_mlink_vn_pair,i_dir_vec,direc_vec,f_dens,dist2,weight,un_vel_vec,c_s_sq,u_b,n_iter,num_coll_par)
 
% this function is used to calculate changes in fluid populations due to
% momentum exchganges between mobile particle and the fluid in the immedite
% vicinity of the particle

    for i_colp=1:num_coll_par
         dist_trans=[];
         for im=1:n_iter(i_colp)
            %outside the particle
            ix_o=ln_mlink_vn_pair(i_colp,im,1);
            iy_o=ln_mlink_vn_pair(i_colp,im,2);

            %inside the particle
            ix_i=ln_mlink_vn(i_colp,im,1);
            iy_i=ln_mlink_vn(i_colp,im,2);

            %directional vector
            i_vec=i_dir_vec(i_colp,im);

            %opposite direction of the directional vector
            i_vec_op=direc_vec(i_vec-1,2)+1;

            fluid_dens=f_dens(ix_o,iy_o);

            dist_trans(i_vec,ix_o,iy_o)=dist2(i_vec_op,ix_i,iy_i)+2.0*fluid_dens ...
                                        *weight(i_vec)*(1.d00/c_s_sq)...
                                        *(u_b(i_colp,ix_i,iy_i,i_vec,1)...
                                        *un_vel_vec(i_vec,1)...
                                        +u_b(i_colp,ix_i,iy_i,i_vec,2)...
                                        *un_vel_vec(i_vec,2));

            dist_trans(i_vec_op,ix_i,iy_i)=dist2(i_vec,ix_o,iy_o)-2.0*fluid_dens...
                                           *weight(i_vec)*(1.d00/c_s_sq)...
                                           *(u_b(i_colp,ix_i,iy_i,i_vec,1)...
                                           *un_vel_vec(i_vec,1)...
                                           +u_b(i_colp,ix_i,iy_i,i_vec,2)...
                                           *un_vel_vec(i_vec,2));

            % virtual fluid inside the particle will not contribute to the momentum
            % transfer
            dist2(i_vec,ix_o,iy_o)=dist_trans(i_vec,ix_o,iy_o);
            dist2(i_vec_op,ix_i,iy_i)=dist_trans(i_vec_op,ix_i,iy_i);        
         end
    end

end

