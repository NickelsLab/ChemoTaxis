function [iflag dist f_dens] = BoundaryCond(lx,ly,len_un_vel,bot_bndr,top_bndr,left_bndr,right_bndr,dist,f_dens,num_add_bnd_nodes)
    iflag=-1*ones(lx,ly);                                                      %set all lattice nodes to active (non-solid) node
    % set the boundary condition of the flow domain (iflag=1 stands for solid (no-flow nodes)
    if bot_bndr == 1
        iflag(:,1)=1;  
    end
    if top_bndr == 1
        iflag(:,ly)=1; 
    end
    if left_bndr == 1;
        iflag(1,:)=1;  
    end
    if right_bndr ==1;
        iflag(lx,:)=1; 
    end

    % read the coordinates of the lattice nodes covered by obstacles (internal solid nodes)
    if (num_add_bnd_nodes > 0)
        internal_obstacles=importdata('obstacles');                             %read the internal no-flow nodes from an external file
       
        %size(internal_obstacles)
        i_coor=internal_obstacles(:,1)+100;                                        %x-Coordinates of the lattice nodes covered by internal obstacles
        
        j_coor=internal_obstacles(:,2);                                        %y-Coordinates of the lattice nodes covered by internal obstacles
        index=sub2ind(size(iflag),i_coor,j_coor);
        iflag(round(index))=internal_obstacles(:,3);                    %label all the lattice nodes covered by internal obstacles (solid nodes)
    end
    %iflag                                                                      %after internal obstacles 

    

    %%%set all distributions at no-flow nodes to zero
    for j = 1:ly
        for i = 1:lx
            for k = 1:len_un_vel
                if (iflag(i,j)==1)
                    dist(k,i,j) = 0.0;
                end
            end
        end
    end

    % set the fluid density at all solid nodes to zero
    MaskForf_dens = iflag == -1;
    f_dens = MaskForf_dens.*f_dens;
end

