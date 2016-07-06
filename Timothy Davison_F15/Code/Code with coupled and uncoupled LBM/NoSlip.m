function dist2 = NoSlip(lx,ly,iflag,len_un_vel,un_vel_vec,direc_vec,dist2)
%     %disp('no-slip')
%     %pause
%     for j=1:ly
%       for i=1:lx
%          if(iflag(i,j) == 1) 
%             for ii=1:len_un_vel-1                                            
%                ii_op_nslip = direc_vec(ii,2);
%                ik_ns = i+un_vel_vec(ii_op_nslip+1,1); 
%                jk_ns = j+un_vel_vec(ii_op_nslip+1,2); 
% 
%                %ii,i,j,ii_op_nslip,ik_ns,jk_ns,lx,ly
%                %pause
% 
%                if((ik_ns >= 1) && (ik_ns <= lx) &&(jk_ns >= 1) && (jk_ns <= ly))
%                   if iflag(ik_ns,jk_ns) == -1
%                      dist2(ii_op_nslip+1,ik_ns,jk_ns)=dist2(ii+1,i,j); 
%                      dist2(ii+1,i,j)=0.0;  
%                      %disp('first if statement')
%                      %ii,i,j,ii_op_nslip,ik_ns,jk_ns,iflag(ik_ns,jk_ns),dist2(ii+1,i,j)
%                      %pause
%                   end
%                else
%                   idir=ik_ns;
%                   jdir=jk_ns;
% 
%                   if(ik_ns < 1)  
%                       idir=lx;
%                   end
%                   if(ik_ns > lx) 
%                       idir=1;
%                   end
%                   if(jk_ns < 1)  
%                       jdir=ly;
%                   end
%                   if(jk_ns > ly) 
%                       jdir=1;
%                   end
% 
%                   if(iflag(idir,jdir) == -1) 
%                      dist2(ii_op_nslip+1,idir,jdir)=dist2(ii+1,i,j);  
%                      dist2(ii+1,i,j)=0.d00;  
%                   end
%                   %disp('second if statement')
%                   %ii,i,j,ii_op_nslip,ik_ns,jk_ns,idir,jdir,iflag(idir,jdir),dist2(ii_op_nslip+1,idir,jdir),dist2(ii+1,i,j)
%                   %pause   
%                end
%             end
%          end
%       end
%     end

    % Vectorized
    ii_op_nslip=direc_vec(:,2)+1;
    i=permute(reshape(repmat(meshgrid(1:lx,1:ly)',1,len_un_vel-1),lx,ly,len_un_vel-1),[3,1,2]);
    j=permute(reshape(repmat(meshgrid(1:ly,1:lx),1,len_un_vel-1),lx,ly,len_un_vel-1),[3,1,2]);
    ik_ns=i+reshape(repmat(un_vel_vec(ii_op_nslip,1),lx,ly),len_un_vel-1,lx,ly);
    jk_ns=j+reshape(repmat(un_vel_vec(ii_op_nslip,2),lx,ly),len_un_vel-1,lx,ly);
    ik_ns(ik_ns<1)=lx;
    ik_ns(ik_ns>lx)=1;
    jk_ns(jk_ns<1)=ly;
    jk_ns(jk_ns>ly)=1;
    mask=permute(reshape(repmat((iflag==1),1,len_un_vel),lx,ly,len_un_vel),[3,1,2]);
    for k=2:len_un_vel
        dist2(ii_op_nslip(k-1),squeeze(ik_ns(k-1,:,1))',squeeze(jk_ns(k-1,1,:)))=mask(k,:,:).*...
            (1-mask(k,squeeze(ik_ns(k-1,:,1))',squeeze(jk_ns(k-1,1,:)))).*dist2(k,1:lx,1:ly)+...
            (1-mask(k,:,:).*(1-mask(k,squeeze(ik_ns(k-1,:,1))',squeeze(jk_ns(k-1,1,:))))).*...
            dist2(ii_op_nslip(k-1),squeeze(ik_ns(k-1,:,1))',squeeze(jk_ns(k-1,1,:)));
    end
end