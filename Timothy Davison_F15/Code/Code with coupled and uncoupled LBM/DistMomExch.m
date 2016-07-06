function [dist2 ln_mlink_vn ln_mlink_vn_pair i_dir_vec n_iter] = DistMomExch(iter,max_it,it_coll,dimension,len_un_vel,un_vel_vec,ln_vn,center_coll,rad_coll,f_dens,direc_vec,dist2,weight,c_s_sq,u_b,num_coll_par)
    %----------------------------------------------------------------------
    % construct hydrodynamic links between intra and extra particle lattce
    % nodes
    if (iter >= it_coll)
    
        [ln_mlink_vn,ln_mlink_vn_pair,~,i_dir_vec,n_iter]=link(dimension,len_un_vel,un_vel_vec,ln_vn,center_coll,rad_coll,num_coll_par);
        
%         for i_colp=1:num_coll_par
%             %------------------------------------------------------------------------ 
%             if (iter == max_it)
%                 subplot(3,3,5) 
%                 scatter(ln_mlink_vn(i_colp,1:n_iter(i_colp),1),ln_mlink_vn(i_colp,1:n_iter(i_colp),2),'filled','red'); 
%                 hold on;
%                 scatter(ln_mlink_vn_pair(i_colp,1:n_iter(i_colp),1),ln_mlink_vn_pair(i_colp,1:n_iter(i_colp),2),'filled','blue');
%                 hold on;
%                 grid on;
%                 xlabel(gca,'x'),ylabel(gca,'y');
%                 %ylim([0 20]); xlom=([0 20]);
%                 axis equal;
%                 grid on;
% 
%                 icount=0;
%                 AllBndNodes=zeros(length(ln_mlink_vn_pair(i_colp,:,:)),dimension);
%                 for i=1:length(ln_mlink_vn_pair(i_colp,:,:))
%                     icount=icount+1;
%                     AllBndNodes(icount,:)=ln_mlink_vn(i_colp,i,:);
%                     icount=icount+1;
%                     AllBndNodes(icount,:)=ln_mlink_vn_pair(i_colp,i,:);
%                     line(AllBndNodes(icount-1:icount,1),AllBndNodes(icount-1:icount,2),'Color','black','LineWidth',1.5);
%                     hold on;
%                 end
%                 hold off;
%             end
%             %------------------------------------------------------------------------
%         end

   % calculate new fluid populations in the immediate vicinity of a
   % particle due to particle fluid momentum exchanges
   
        dist2 = post_coll_pop(ln_mlink_vn,ln_mlink_vn_pair,i_dir_vec,direc_vec,f_dens,dist2,weight,un_vel_vec,c_s_sq,u_b,n_iter,num_coll_par);
   
    else
        
        ln_mlink_vn=[];
        ln_mlink_vn_pair=[];
        i_dir_vec=[];
        n_iter=zeros(num_coll_par);
        
    end
end