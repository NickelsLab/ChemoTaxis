function [ln_mlink_vn,ln_mlink_vn_pair,i_dir_link,i_dir_vec,n_iter] = link(idimension,idim,un_vel_vec,ln_vn,center_coll,rad_coll,num_coll_par)
    ln_mlink_vn=[];
    ln_mlink_vn_pair=[];
    i_dir_link=[];
    i_dir_vec=[];
    n_iter=[];
    for i_colp=1:num_coll_par
        n_iter(i_colp)=0;
        ln_link_vn=[];
        dist_in=[];
        center=center_coll(i_colp,:);
        radius=rad_coll(i_colp);
        n_count=nnz(ln_vn(i_colp,:,:))/idimension;
        for j=1:n_count
            for i=2:idim                                                % -1 removed
                for id=1:idimension
                    ln_link_vn(id)=ln_vn(i_colp,j,id)+un_vel_vec(i,id);
                    dist_in(id)=1.0*(ln_link_vn(id))-center(id+1);
                end

                distance2=sqrt(dist_in(1)*dist_in(1)+dist_in(2)*dist_in(2));

                if(distance2 >= radius)
                    n_iter(i_colp)=n_iter(i_colp)+1;

                    for id=1:idimension
                        % x-component of lattice nodes inside the particle (no-slip
                        % nodes)
                        ln_mlink_vn(i_colp,n_iter(i_colp),id)=ln_vn(i_colp,j,id);

                        % x-component of lattice nodes outside the particle
                        ln_mlink_vn_pair(i_colp,n_iter(i_colp),id)=ln_link_vn(id);

                        % x-component of the direction vector from inside to outside
                        i_dir_link(i_colp,n_iter(i_colp),id)=un_vel_vec(i,id);
                    end

                    i_dir_vec(i_colp,n_iter(i_colp))=i;
                end
            end
        end
    end
end

