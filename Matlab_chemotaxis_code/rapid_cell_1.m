%Takes in the substrate concentration, current methylation state and time-step
%Gives back the methylation state, motor-bias, cheYp concentration and Activity of the cell

function [m,mb,cheYp,A] = rapid_cell_1(S,m,dt)
    %%%all the units (except K_on and K_off) are in millimoles (not micromoles as specified in Table 1) 
    %%%Table 1, p. 4
    K_on = 12e-3; %uM dissociation constant for 'on' receptor
    K_off = 1.7e-3; %uM dissociation constant for 'off' receptor
	Ks_on = 1e6; %uM dissociation constant for tsr 'on' receptor
	Ks_off = 100; %uM dissociation constant for tsr 'off' receptor
    n = 6; %Number of Tar receptors per cluster
	ns = 12; %Number of Tsr receptors per cluster  
    cheR = 0.16; %uM total concentration of cheR
    cheB = 0.28; %uM total concentration of cheB
	mb0 = 0.65;
	H = 10.3;
    a = 0.0625; %a scaling factor for methyl addition
    b = 0.0714; %a scaling factor for demethylation
    cheYt = 9.7; %uM total cheY concentration

    %%%After Eq (7), p.3
    K_y = 100; %uM s-1
    K_z = 30; %uM-1  --> actually, this is K_z*[Che Z]
    G_y = 0.1;
     
    %%%After Eq (8), p.4
    K_s = 0.45; %just a scaling coefficient
    
    %%%Receptor free energy (Table 2, p. 4)
    F = n*(eps_val(m)+log((1+S/K_off)/(1+S/K_on))) + ...
       ns*(eps_val(m)+log((1+S/Ks_off)/(1+S/Ks_on)));

    %F = n*(eps_val(m)+log((1+S/K_off)/(1+S/K_on)))+ns*(eps_val(m)+log((1+0.01*S/Ks_off)/(1+0.01*S/Ks_on)));

    %%%Cluster activity (Table 2, p. 4) 
    A = 1/(1+exp(F)); %A is the activity of the receptors
    
    
%      k_half = [0, 1/3, 1];
%      cheBt = [1, 2, 4];
%      cheB = cheBt(2)*A/(A + k_half(2));
%%% At the current time, cheB is set as a constant 0.28.
    

    %%%Rate of receptor methylation (Table 2, p. 4) 
    m = m+dm(cheR,cheB,a,b,A)*dt;
    
    %%%Steady-state CheY-P concentration (Table 2, p. 4) 
    cheYp = 3*(K_y*K_s*A)/(K_y*K_s*A+K_z+G_y);
    
    %%%CCW motor bias (Table 2, p. 4)  
    mb = ccw_motor_bias(cheYp, mb0,H);
end

function [ret] = eps_val(m)
    %The eps indexed at 0 methyls giving a return value
    %For example, eps(1) is the eps value for 0 methyls
	eps = [1.0 0.5 0.0 -0.3 -0.6 -0.85 -1.1 -2.0 -3.0];

    if m <= 0
        eps_val = eps(1);
    elseif m >= 8
        eps_val = eps(9);
    else %linear interpolation
        upper = ceil(m+1);
        lower = floor(m+1);
        slope = eps(upper) - eps(lower);
        eps_val = eps(lower) + slope*(m + 1 - lower); 
    end
    
    ret = eps_val;

end

function [ret] = dm(cheR,cheB,a,b,A)
    ret = a*(1-A)*cheR-b*A*cheB;
end

function [mb] = ccw_motor_bias(cheYp, mb0,H)
	mb = (1+(1/mb0-1)*(cheYp)^H)^(-1);
end
