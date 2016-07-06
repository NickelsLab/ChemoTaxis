%--------------------------------------------------------------------------
% Model parameters
%--------------------------------------------------------------------------
% ---- flow domain parameters ---------------------------------------------
%--------------------------------------------------------------------------
lx = 21;                                                                  %channel length (in LB) 
ly = 31;                                                                  %channel width (in LB)
fluid_dens = 1.0;                                                          %fluid density (in LB)
delX =1.0;                                                                 %nodal spacing (in LB)
delT = 1.0;                                                                %temporal increment (in LB)
max_it=100;                                                                %maximum number of time step (in LB)
visc_kin = 0.1;                                                            %kinematic viscosity of the fluid (in LB) 
gravity(1)=0.00001 ;                                                          %external force in x
gravity(2)=0.;                                                              %external force in y
num_add_bnd_nodes = 0;                                                     %number of nodes covered by obstacles              
% flags for boundary conditions
left_bndr = 0;         %periodic
right_bndr = 0;        %periodic
top_bndr = 1;          %no-slip
bot_bndr = 1;          %no_slip

dimension =2;          %simulation dimension   !NEW
%NEW----------------------------------------------------------------------- 
% ----- parameters associated with particles
%--------------------------------------------------------------------------
num_coll_par = 1;                                                         % number of particles in simulations                                                         
it_coll=max_it-1;

center_coll = [1 9.5 9.5];                                                     %particle number; x- and y- coordinates of particle center
rad_coll(1)=7.5;                                                           %particle radius (in LB units)
dens_par=1.0;
cons_pardens=1.0;