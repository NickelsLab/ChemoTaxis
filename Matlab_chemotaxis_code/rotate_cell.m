%Rotate a single cell (#b) by angle (ang) without displacing it
function p = rotate_cell(p,ang,centroid,N_IB,b)
    angm = [cos(ang) -sin(ang); sin(ang) cos(ang)]; %Create the rotation matrix
    for jj = 1:N_IB %Rotate all IB points in the cell
        p(jj+b,:) = p(jj+b,:)-centroid; %Center the cell so no accidental translation occurs
        p(jj+b,:) = (angm*p(jj+b,:)')' + centroid; %Apply rotation matrix to each IB point and translate back
    end             
end
