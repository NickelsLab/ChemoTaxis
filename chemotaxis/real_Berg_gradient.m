function [asp,r] = real_Berg_gradient(max,Xs,Ys,D,pos,t)
    cent = [Xs, Ys];
%     a = 1; %tunable alpha parameter


    rc_cm = 0.01; %cm
    rc = rc_cm*1e4; %um
    r0 = 0;%a*rc;
    r = ((cent(1)-pos(:,1)).^2+(cent(2)-pos(:,2)).^2).^0.5; %um
    r1 = r-r0;
    t1_num = max*rc*rc; %um*um
    t1_den = 2*r1*(pi*D*t)^0.5; %um*um
    t_exp = exp(-(r1.*r1)/(4*D*t)); %unitless
    den = 1+(3*rc*r1/(4*D*t)); %unitless
    asp = (t1_num./t1_den).*t_exp./den; %the units work 
    
    ind = find(isinf(asp)>0);
    asp(ind) = realmax;
    
    %asp = 10; %Uncomment to make a constant gradient

end