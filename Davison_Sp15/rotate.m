function p = rotate(p,ang,centroid)
    angm = [cos(ang) -sin(ang); sin(ang) cos(ang)]; %Create the rotation matrix
    
    p = p-centroid; %Center the cell so no accidental translation occurs
    p = (angm*p')' + centroid; %Apply rotation matrix to each IB point and translate back             
end
