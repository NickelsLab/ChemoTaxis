% clear all;
% close all;
% clc;
% num_cells = 1;    
% for test = 1:1:1
% 
% 
%     %profile on
%     tic
% 
%     %%%%parameters
%     %test = 1;
%     fac_tumble=5;
%     fac_mb = 0.85;
%     max_it= 100;                                                                %maximum number of time step (in LB)
% 
% 
%     %%%Concentration parameters
%     %Berg gradient parameters
%     Max = 5000;                                         %Maximum aspartate concentration in uM
%     Xs = 200;                                             %X center of the gradient
%     Ys = 100;                                            %Y center of the gradient                                     %Center of the gradient
%     size_grad = 20;                                    %Higher numbers lead to lower density flow field and faster computations
%     mag = 500;                                            
%     diff_rate = 89000;              
%     init_grad_time = 0.2;                      %Gradient start time is 2 minutes
%     time_factor = 20;
%     fm = 0.1;  %force magnitude for running  %%%Hoa
% 
%     dir = ['num_cells_',num2str(num_cells),'_test_', num2str(test)];
%     if(~exist(dir,'dir'))
%         mkdir(dir)
%     else
%         rmdir(dir,'s')
%         mkdir(dir)
%     end
%     fsize = 24; 
% 
% 
%     %--------------------------------------------------------------------------
%     % Model parameters
%     %--------------------------------------------------------------------------
%     % ---- flow domain parameters ---------------------------------------------
%     %--------------------------------------------------------------------------
%     lx = 2*floor(Xs);                                                                  %channel length (in LB) 
%     ly = 2*floor(Ys);                                                                   %channel width (in LB)
%     fluid_dens = 1.0;                                                          %fluid density (in LB)
%     delX = 1.0;                                                                %nodal spacing (in LB)
%     delT = 1.0;                                                                %temporal increment (in LB)
%     visc_kin = 0.1;                                                            %kinematic viscosity of the fluid (in LB) 
%     gravity(1)= 0.001;                                                       %external force in x
%     gravity(2)=0.001;                                                             %external force in y
%     num_add_bnd_nodes = 1;                                                     %0: no obstacle; 1: with obstacles
%     sampleint = 200;
% 
%     % flags for boundary conditions
%     left_bndr = 0;         %periodic
%     right_bndr = 0;        %periodic
%     top_bndr = 1;          %no-slip
%     bot_bndr = 1;          %no_slip
%     shear_boundary_flag = 0;
%     u_xCF = 0.0;  %0.05;
%     u_yCF = 0.0;
% 
%     dimension =2;          %simulation dimension   !NEW
% 
%     %Fluid grid
%     [XX,YY]=meshgrid(1:lx,1:ly);
%     XXT=reshape(XX,size(XX,1)*size(XX,2),1); %Make X's into a column
%     YYT=reshape(YY,size(YY,1)*size(YY,2),1); %Make Y's into a column
%     Xg=[XXT,YYT]; %Evaluation points in (x,y) format
%     size_XX = size(XX);
% 
%     %NEW----------------------------------------------------------------------- 
%     % ----- parameters associated with particles
%     %--------------------------------------------------------------------------
%     num_coll_par = num_cells;                                                          % number of particles in simulations                                                         
%     colorc = rand(num_coll_par,3);                            %Setting up colors to display cells
% 
%     it_coll=1000; %how long LBM stays constant
% 
%     cent=zeros(num_coll_par,2);
%     center_coll=ones(num_coll_par,3);
%     rc=zeros(num_coll_par,2);
%     rad_coll=3.5*ones(1,num_coll_par);
% 
%     init_var = lx/8;
%     init_dist = lx/5;
% 
%     % center_coll(1,:) = [1 10.0 10.0];                                                     %particle number; x- and y- coordinates of particle center
%     % cent(1,:) = center_coll(1,2:3);
%     % rad_coll(1)=3.5;  %particle radius (in LB units)
%     % rc(1,:) = [cent(1,1)+rad_coll(1) cent(1,2)];   %receptor cluster
%     % ang = 2*pi*rand;
%     % rc(1,:) = rotate(rc(1,:),ang,cent(1,:)); %receptor cluster rotated by some random angle
%     % 
%     % center_coll(2,:) = [2 30.0 30.0];                                                     %particle number; x- and y- coordinates of particle center
%     % cent(2,:) = center_coll(2,2:3);
%     % rad_coll(2)=3.5;  %particle radius (in LB units) 
%     % rc(2,:) = [cent(2,1)+rad_coll(2) cent(2,1)];   %receptor cluster
%     % ang = 2*pi*rand;
%     % rc(2,:) = rotate(rc(2,:),ang,cent(2,:)); %receptor cluster rotated by some random angle
% 
%     dens_par = ones(size(rad_coll));
%     cons_pardens = ones(size(rad_coll));
% 
%     %NEW----------------------------------------------------------------------- 
%     % ----- parameters associated with interaction forces
%     %--------------------------------------------------------------------------
% 
%     % Specify particle-wall and particle-particle interaction potentials
%     index_att_rep_cw = 2;
%     index_att_rep_cc = 2;
% 
%     % Distance parameters
%     search_distance=4.5;
%     threshold_mindist=1.0;
% 
%     spring_cons=0.0;
% 
%     % Lennard-Jones parameters
%     rep_strength_cw=1250000.0;
%     att_strength_cw=0.0;
%     rep_strength_cc=1250000.0;
%     att_strength_cc=0.0;
% 
%     stiff_param_cw=0.0;
%     electrostat_exp_cw=0.0;
%     stiff_param_cc=0.0;
%     electrostat_exp_cc=0.0;
% 
%     %----- define the unit velocity vector (D2Q9)------------------------------
%     unvel=[0,1,0,-1,0,1,-1,-1,1,0,0,1,0,-1,1,1,-1,-1];                         %unit velocity vectors (1 to 9)  
%     un_vel_vec = reshape(unvel,[],2);
%     len_un_vel = length(un_vel_vec); % number of velocity vectors 
% 
%     % set-up directional vectors to be used in no-slip boundary condition
%     dirvec=[1,2,3,4,5,6,7,8,3,4,1,2,7,8,5,6];
%     direc_vec = reshape(dirvec,[],2);
% 
%     %direc_vec
%     %pause
% 
%     % define the weights for unit velocity vectors
%      weight=[4./9.  1./9.  1./9.  1./9.  1./9.  1./36.  1./36.  1./36.  1./36.];
% 
%     % define parameter c and (pdeudo) speed of sound
%     param_c=delX/delT;
%     c_s=sqrt((param_c*param_c)/3.0);
%     c_s_sq=c_s*c_s;
%     c_s_dsq=c_s_sq*c_s_sq;
% 
%     %calculate the relaxation parameter as a function of kinematic viscosity
%     alambda=0.5+3.0*delT/(delX*delX)*visc_kin;                             %relaxation time ('tau')
%     rel_param=-1.0/alambda;
% 
%     %calculate colloid mass and moment of inertia
%     mass_par=dens_par.*(4.d00/3.d00).*(22.d00/7.d00).*rad_coll.*rad_coll.*rad_coll.*...
%                      cons_pardens.*cons_pardens.*cons_pardens;
%     val_inertia=(2.d00/5.d00).*mass_par.*rad_coll.*rad_coll.*cons_pardens.*cons_pardens;
% 
%     %--------------------------------------------------------------------------
%     % INITIALIZATION STEP 
%     %--------------------------------------------------------------------------
%     switch num_coll_par
%     case 1
% %     cent = [lx-10  ly-10];
%     cent = [300  100];
% 
%     case 2
%     cent = [300  100;
%             100  100];
%     end
% 
% 
%     %
%     cent_o = cent;
% 
%     rc = [rad_coll'+cent(:,1) cent(:,2)];
%     %rc = [-rad_coll'+cent(:,1) cent(:,2)];
%     rc_o = rc;
% 
%     rotation_at_rc = zeros(num_coll_par,1); %rotation of particle and receptor cluster, AJC 2/6/2015
%     %rotation_at_rc = pi*ones(num_coll_par,1); %rotation should be an initial angle of receptor cluster
% 
% 
%     [f_dens dist] = Initialize(fluid_dens,lx,ly,len_un_vel,weight);
% 
%     % create_obstacle(Xs,Ys,cent,rc);  %customized obstacle creation
%     % disp('create obstacle file')
%     % pause
% 
% 
%     [iflag dist f_dens] = BoundaryCond(lx,ly,len_un_vel,bot_bndr,top_bndr,left_bndr,right_bndr,dist,f_dens,num_add_bnd_nodes);
clear all;
close all;
clc;
num_cells = 1;    
for test = 1:1:1


    %profile on
    tic

    %%%%parameters
    %test = 1;
    fac_tumble=5;
    fac_mb = 0.85;
    max_it= 50;                                                                %maximum number of time step (in LB)


    %%%Concentration parameters
    %Berg gradient parameters
    Max = 5000;                                         %Maximum aspartate concentration in uM
    Xs = 200;                                             %X center of the gradient
    Ys = 100;                                            %Y center of the gradient                                     %Center of the gradient
    size_grad = 20;                                    %Higher numbers lead to lower density flow field and faster computations
    mag = 500;                                            
    diff_rate = 89000;              
    init_grad_time = 0.2;                      %Gradient start time is 2 minutes
    time_factor = 1;
    fm = 0.1;  %force magnitude for running  %%%Hoa

    dir = ['num_cells_',num2str(num_cells),'_test_', num2str(test)];
    if(~exist(dir,'dir'))
        mkdir(dir)
    else
        rmdir(dir,'s')
        mkdir(dir)
    end
    fsize = 24; 


    %--------------------------------------------------------------------------
    % Model parameters
    %--------------------------------------------------------------------------
    % ---- flow domain parameters ---------------------------------------------
    %--------------------------------------------------------------------------
    lx = 2*floor(Xs);                                                                  %channel length (in LB) 
    ly = 2*floor(Ys);                                                                   %channel width (in LB)
    fluid_dens = 1.0;                                                          %fluid density (in LB)
    delX = 1.0;                                                                %nodal spacing (in LB)
    delT = 1.0;                                                                %temporal increment (in LB)
    visc_kin = 0.1;                                                            %kinematic viscosity of the fluid (in LB) 
    gravity(1)= 0.001;                                                       %external force in x
    gravity(2)=0.001;                                                             %external force in y
    num_add_bnd_nodes = 0;                                                     %0: no obstacle; 1: with obstacles
    sampleint = 200;

    % flags for boundary conditions
    left_bndr = 0;         %periodic
    right_bndr = 0;        %periodic
    top_bndr = 1;          %no-slip
    bot_bndr = 1;          %no_slip
    shear_boundary_flag = 0;
    u_xCF = 0.0;  %0.05;
    u_yCF = 0.0;

    dimension =2;          %simulation dimension   !NEW

    %Fluid grid
    [XX,YY]=meshgrid(1:lx,1:ly);
    XXT=reshape(XX,size(XX,1)*size(XX,2),1); %Make X's into a column
    YYT=reshape(YY,size(YY,1)*size(YY,2),1); %Make Y's into a column
    Xg=[XXT,YYT]; %Evaluation points in (x,y) format
    size_XX = size(XX);

    %xxx yyy for plotting
    xxx = 0:1:400;
    yyy = 0:0.5:200;
    [xxxg,yyyg] = meshgrid(xxx,yyy);
    %NEW----------------------------------------------------------------------- 
    % ----- parameters associated with particles
    %--------------------------------------------------------------------------
    num_coll_par = num_cells;                                                          % number of particles in simulations                                                         
    colorc = rand(num_coll_par,3);                            %Setting up colors to display cells

    it_coll=1;

    cent=zeros(num_coll_par,2);
    center_coll=ones(num_coll_par,3);
    rc=zeros(num_coll_par,2);
    rad_coll=3.5*ones(1,num_coll_par);

    init_var = lx/8;
    init_dist = lx/5;

    % center_coll(1,:) = [1 10.0 10.0];                                                     %particle number; x- and y- coordinates of particle center
    % cent(1,:) = center_coll(1,2:3);
    % rad_coll(1)=3.5;  %particle radius (in LB units)
    % rc(1,:) = [cent(1,1)+rad_coll(1) cent(1,2)];   %receptor cluster
    % ang = 2*pi*rand;
    % rc(1,:) = rotate(rc(1,:),ang,cent(1,:)); %receptor cluster rotated by some random angle
    % 
    % center_coll(2,:) = [2 30.0 30.0];                                                     %particle number; x- and y- coordinates of particle center
    % cent(2,:) = center_coll(2,2:3);
    % rad_coll(2)=3.5;  %particle radius (in LB units) 
    % rc(2,:) = [cent(2,1)+rad_coll(2) cent(2,1)];   %receptor cluster
    % ang = 2*pi*rand;
    % rc(2,:) = rotate(rc(2,:),ang,cent(2,:)); %receptor cluster rotated by some random angle

    dens_par = ones(size(rad_coll));
    cons_pardens = ones(size(rad_coll));

    %NEW----------------------------------------------------------------------- 
    % ----- parameters associated with interaction forces
    %--------------------------------------------------------------------------

    % Specify particle-wall and particle-particle interaction potentials
    index_att_rep_cw = 2;
    index_att_rep_cc = 2;

    % Distance parameters
    search_distance=4.5;
    threshold_mindist=1.0;

    spring_cons=0.0;

    % Lennard-Jones parameters
    rep_strength_cw=1250000.0;
    att_strength_cw=0.0;
    rep_strength_cc=1250000.0;
    att_strength_cc=0.0;

    stiff_param_cw=0.0;
    electrostat_exp_cw=0.0;
    stiff_param_cc=0.0;
    electrostat_exp_cc=0.0;

    %----- define the unit velocity vector (D2Q9)------------------------------
    unvel=[0,1,0,-1,0,1,-1,-1,1,0,0,1,0,-1,1,1,-1,-1];                         %unit velocity vectors (1 to 9)  
    un_vel_vec = reshape(unvel,[],2);
    len_un_vel = length(un_vel_vec); % number of velocity vectors 

    % set-up directional vectors to be used in no-slip boundary condition
    dirvec=[1,2,3,4,5,6,7,8,3,4,1,2,7,8,5,6];
    direc_vec = reshape(dirvec,[],2);

    %direc_vec
    %pause

    % define the weights for unit velocity vectors
     weight=[4./9.  1./9.  1./9.  1./9.  1./9.  1./36.  1./36.  1./36.  1./36.];

    % define parameter c and (pdeudo) speed of sound
    param_c=delX/delT;
    c_s=sqrt((param_c*param_c)/3.0);
    c_s_sq=c_s*c_s;
    c_s_dsq=c_s_sq*c_s_sq;

    %calculate the relaxation parameter as a function of kinematic viscosity
    alambda=0.5+3.0*delT/(delX*delX)*visc_kin;                             %relaxation time ('tau')
    rel_param=-1.0/alambda;

    %calculate colloid mass and moment of inertia
    mass_par=dens_par.*(4.d00/3.d00).*(22.d00/7.d00).*rad_coll.*rad_coll.*rad_coll.*...
                     cons_pardens.*cons_pardens.*cons_pardens;
    val_inertia=(2.d00/5.d00).*mass_par.*rad_coll.*rad_coll.*cons_pardens.*cons_pardens;

    %--------------------------------------------------------------------------
    % INITIALIZATION STEP 
    %--------------------------------------------------------------------------
    switch num_coll_par
    case 1
%     cent = [lx-10  ly-10];
    cent = [100  100];

    case 2
    cent = [300  100;
            100  100];
    end


    %
    cent_o = cent;

    rc = [rad_coll'+cent(:,1) cent(:,2)];
    %rc = [-rad_coll'+cent(:,1) cent(:,2)];
    rc_o = rc;

    rotation_at_rc = zeros(num_coll_par,1); %rotation of particle and receptor cluster, AJC 2/6/2015
    %rotation_at_rc = pi*ones(num_coll_par,1); %rotation should be an initial angle of receptor cluster


    [f_dens dist] = Initialize(fluid_dens,lx,ly,len_un_vel,weight);

    create_obstacle(50,50,[30 30],rc);  %customized obstacle creation
    % disp('create obstacle file')
    % pause


    [iflag dist f_dens] = BoundaryCond(lx,ly,len_un_vel,bot_bndr,top_bndr,left_bndr,right_bndr,dist,f_dens,num_add_bnd_nodes);
    stname = [dir,'/iflag_', num2str(num_coll_par),'_particles.txt'];
    save(stname,'iflag','-ascii')

    %size(iflag)



    %[cent,rc] = create_initial_particles(num_coll_par,rad_coll,mag,size_grad,dir,fsize,init_dist,init_var,lx,ly,iflag);

    center_coll(:,2:3) = cent;

    %f_dens

    dist_trans=0.;  

    % %--------------------------------------------------------------------------
    % % Analytic Solution for Steady Flow
    % %--------------------------------------------------------------------------%
    % 
    % %%%Hoa_b
    % iflag_vel_ss = 1;
    % vel_steady_old = zeros(ly-1,1);
    % vel_steady = zeros(ly-1,1);
    % 
    % vel_steady_old_temp = vel_steady_old;
    % vel_steady_temp = vel_steady;
    % 
    % if (iflag_vel_ss == 1)
    %     for j = 1:ly -1
    %         vel_steady_old(j) = -gravity(1)/(2*visc_kin)*(j^2 - ((ly - 1)+1)*j + (ly -1));
    %     end
    %     for j = 2: ly -1
    %         vel_steady(j) = (vel_steady_old(j) + vel_steady_old(j-1))/2;
    %     end
    %     
    %     j = 1:ly -1;
    %     vel_steady_old_temp(j) = -gravity(1)/(2*visc_kin)*(j.^2 - ((ly - 1)+1)*j + (ly -1));
    %     j = 2: ly -1;
    %     vel_steady_temp(j) = (vel_steady_old_temp(j) + vel_steady_old_temp(j-1))/2;
    %     isequal(vel_steady_old,vel_steady_old_temp)
    %     isequal(vel_steady,vel_steady_temp)
    %     
    % end
    % vel_max = (-gravity(1)/(8*visc_kin))*(-ly*ly+4*ly+2);
    % %%%Hoa_e

    %--------------------------------------------------------------------------
    % SIMULATION and TIME-STEPPING STARTS HERE
    %--------------------------------------------------------------------------%
    dist2 = zeros(len_un_vel,lx,ly);
    prev_sum_force = zeros(num_coll_par,dimension);
    prev_par_torque = zeros(num_coll_par);
    par_veloc = zeros(num_coll_par,dimension);
    par_ang_vel = zeros(num_coll_par);
    iflag_immob_col = ones(num_coll_par);

    ln_ic_old=[];
    k_iter_old=zeros(num_coll_par);
    u_b(1:num_coll_par,1:lx,1:ly,1:len_un_vel,1:dimension)=0.;                                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% u_b calculations have not been included yet
    force_unc=zeros(num_coll_par,dimension);
    torques_un=zeros(num_coll_par);
    force_cnc=zeros(num_coll_par,dimension);
    torques_cn=zeros(num_coll_par);
    force_cw=zeros(num_coll_par,dimension);
    force_cc=zeros(num_coll_par,dimension);
    pw_torque=zeros(num_coll_par);

    % for i_colp=1:num_coll_par
    %     name=strcat('Col',num2str(i_colp+337));
    %     fileID(i_colp)=fopen(name,'w');
    % end


    fixed_time = init_grad_time/time_factor;
    m = 2*ones(num_coll_par,1);
%     for i=1:num_coll_par
%         init_conc = real_Berg_gradient(Max,Xs,Ys,diff_rate,rc(i,:),fixed_time);
%         %current_asp=10;
% 
%         for ii = 1:4000 %Stay in this one spot for many steps to equilibrate
%             [m(i),~,~,~] = rapid_cell_1(current_asp,m(i),delT);
%         end
%     end
% 
% 
%     [ca,~] = real_Berg_gradient(Max,Xs,Ys,diff_rate,Xg,fixed_time);
%     ca=reshape(ca,size_XX);
    % figure
    % [~,hc] = contour(XX,YY,ca,6);  %replaced Cc with ~ to stop warning
    % colorbar('location','eastoutside','FontSize',fsize)
    % set (hc,'LineWidth', 2);
    % 
    % % hold on
    % % plot(Xs,Ys,'xk','Markersize',10)
    % axis equal
    % 
    % %pause

    run_tumbles=zeros(max_it,num_coll_par);
    traj = zeros(num_coll_par*(max_it+1),2);
    traj(1:num_coll_par,:) = cent;
    ang_vel = zeros(num_coll_par,1); %angular veloctiy of each particle due to tumbling motion

    stcent = [dir,'/centroids_', num2str(num_coll_par),'_particles.txt'];
    tmp = [cent,rc,par_veloc,par_ang_vel];
    save(stcent,'tmp','-ascii')


    stRC = [dir,'/RapidCell_params_', num2str(num_coll_par),'_particles.txt'];
velx = gravity(1)*10*ones(400,200);
vely = gravity(2)*10*ones(400,200);
init_conc = ones(193,11);
    for iter=1:max_it  

        f_run = zeros(num_coll_par,2);
        angr = zeros(num_coll_par,1);
        if(iter >= it_coll)
            current_asp = zeros(num_coll_par,1);
            mb = zeros(num_coll_par,1);
            cheYp = zeros(num_coll_par,1);
            %%%%%%%%%%%%%%%
            for i=1:num_coll_par
                fixed_time = (init_grad_time+iter*delT)/time_factor;
                [conc, p] = SolveConc2(init_conc(:,end), fixed_time, velx, vely);
                init_conc = conc;
                xgrid = 400*p(1,:);
                ygrid = 200*p(2,:);
                concinterp = griddata(xgrid,ygrid,conc(:,end), rc(i,1), rc(i,2));
                %current_asp = 10;
                [m(1),mb(1),cheYp(1),~] = rapid_cell_1(concinterp,m(1),delT);
                RB = mb(1);
                %RB = 1;
                %RB = 0;

                vec = rc(i,:) - cent(i,:);
                %Compute a probability to run or tumble
                if(rand < fac_mb*RB) %Force to run if not yet reached min_run, or flip coin
                    %disp('run')
                    run_tumbles(iter,i) = 1;
                    f_run(i,:) = fm*vec/norm(vec);
                    angr(i) = 0.0;
                else
                    %disp('tumble')
                    run_tumbles(iter,i) = 0;
                    f_run(i,:) = [0.0 0.0]; %Hoa
                    angr(i) = 2*pi*(rand-0.5);
                    %angr = 0.0;
                end 
            end
            temp = [iter*delT*ones(size(mb)) current_asp m cheYp mb run_tumbles(iter,:)'];
            save(stRC,'temp','-ascii','-append')
        end
        %%%%%%%%%%%%%%%    




        dist2=dist;

    % fprintf('%s %i\n','VirtualNoSlipNodes',iter);
    % tic
        [ln_ic k_iter ln_vn force_unc torques_un force_cnc torques_cn u_b iflag_immob_col] = VirtualNoSlipNodes(iter,max_it,it_coll,num_coll_par,center_coll,rad_coll,dimension,len_un_vel,un_vel_vec,u_b,iflag_immob_col,ln_ic_old,k_iter_old,dist2,f_dens,par_veloc);
    % toc
        %--------------------------------------------------------------------------
        % STEP 1 --- STREAMING
        % move the populations to the next neigbboring nodes
        %--------------------------------------------------------------------------
    % fprintf('%s %i\n','Streaming',iter);
    % tic
        dist2 = Streaming(lx,ly,iflag,len_un_vel,un_vel_vec,dist,dist2);
    % toc
    %fprintf(fileID,'%s\n','Streaming');
    %for j = 1:ly
        %fprintf(fileID,'%i %i %f %f %f %f %f %f %f %f %f\n',iter,ly,dist2(1,50,j),dist2(2,50,j),dist2(3,50,j),dist2(4,50,j),dist2(5,50,j),dist2(6,50,j),dist2(7,50,j),dist2(8,50,j),dist2(9,50,j));
    %end
        %--------------------------------------------------------------------------
        % STEP 2 --- NO SLIP
        % implement the no-slip condition on solid nodes
        %--------------------------------------------------------------------------    
    % fprintf('%s %i\n','NoSlip',iter);
    % tic
        dist2 = NoSlip(lx,ly,iflag,len_un_vel,un_vel_vec,direc_vec,dist2);
    % toc
    % fprintf('%s %i\n','DistMomExch',iter);
    % tic
        [dist2 ln_mlink_vn ln_mlink_vn_pair i_dir_vec n_iter] = DistMomExch(iter,max_it,it_coll,dimension,len_un_vel,un_vel_vec,ln_vn,center_coll,rad_coll,f_dens,direc_vec,dist2,weight,c_s_sq,u_b,num_coll_par);
    % toc
        %--------------------------------------------------------------------------
        % STEP 3 --- COLLISION
        %--------------------------------------------------------------------------
    % fprintf('%s %i\n','Collision',iter);
    % tic
        dist = Collision(lx,ly,iflag,len_un_vel,un_vel_vec,dist,dist2,alambda,gravity,weight,c_s_sq,c_s_dsq,shear_boundary_flag,u_xCF,u_yCF);
    % toc
    % fprintf('%s %i\n','FluidDensVel',iter);
    % tic
        [f_dens vel velx vely] = FluidDensVel(lx,ly,iflag,len_un_vel,un_vel_vec,dist);
    % toc

        %--------------------------------------------------------------------------
        % STEP 4 --- COLLOIDAL TRANSPORT
        % calculate hydrodynamic forces between particles and fluid
        %--------------------------------------------------------------------------
    %     if (iter == it_coll) || ((iter>it_coll) && (mod(iter,10*it_coll) == 0))
    %         hold off
    %         screen_size = get(0, 'ScreenSize');
    %         fig2=figure('Visible','off');
    %         set(fig2, 'Position', [0 0 screen_size(3) screen_size(4)]);
    %         set(fig2,'PaperPositionMode','auto')
    %         axes('FontSize',fsize)
    %         axis equal
    %         hold on
    %         [ca,~] = real_Berg_gradient(Max,Xs,Ys,diff_rate,Xg,fixed_time);
    %         ca=reshape(ca,size_XX);
    %         cmin = floor(min(ca(:)));
    %         cmax = ceil(max(ca(:)));
    %         cinc = (cmax - cmin) / 40;
    %         clevs = cmin:cinc:cmax;
    %        
    %         %ca = 10*ones(size_XX);
    % 
    %         [~,hc] = contour(XX,YY,ca,clevs);  %replaced Cc with ~ to stop warning
    %         colorbar('location','eastoutside','FontSize',fsize)
    %         set (hc,'LineWidth', 3);
    %         axis equal
    %         hold on
    %         
    %         for i=1:lx
    %             for j=1:ly
    %                 if (iflag(i,j) == 1)
    %                     rectangle('Position',[i,j,1,1],'Curvature',[0,0],'FaceColor',[0 0 0]);
    %                 end
    %             end
    %         end
    %         
    %         for i=1:num_coll_par
    %             plot(rc(i,1),rc(i,2),'xr','Markersize',10)
    %             plot(cent(i,1),cent(i,2),'ob','Markersize',10)
    %             plot([rc(i,1) cent(i,1)],[rc(i,2) cent(i,2)],'k-');
    %             rectangle('Position',[cent(i,1)-rad_coll(i),cent(i,2)-rad_coll(i),2*rad_coll(i),2*rad_coll(i)],...
    %                 'Curvature',[1,1],'LineWidth',2.0);
    %             plot(traj(i:num_coll_par:num_coll_par*(iter),1),...
    %                  traj(i:num_coll_par:num_coll_par*(iter),2),'--',...
    %                  'Linewidth',2,'color',colorc(i,1:3));
    %         end
    %         axis([0 lx 0 ly])
    %         saveas(fig2,[dir,'/frame_',int2str(iter)],'png') %Save the figure
    %         %pause
    %     end

    % fprintf('%s %i\n','ColFluidHyd',iter);
    % tic   
        [ln_ic_old k_iter_old prev_sum_force prev_par_torque center_coll...
        par_veloc par_ang_vel u_b rc cent rotation_at_rc ang_vel] = ...
        ColFluidHyd(iter,it_coll,n_iter,...
        dimension,ln_ic,k_iter,ln_mlink_vn,ln_mlink_vn_pair,i_dir_vec,...
        direc_vec,f_dens,dist,weight,c_s_sq,u_b,un_vel_vec,center_coll,...
        dens_par,mass_par,val_inertia,prev_sum_force,prev_par_torque,...
        par_veloc,par_ang_vel,iflag_immob_col,delX,delT,gravity,force_unc,...
        torques_un,force_cnc,torques_cn,sampleint,num_coll_par,...
        force_cw,force_cc,pw_torque,f_run,angr,rc,cent,rotation_at_rc,ang_vel,fac_tumble);

        %--------------------------------------------------------------------------
        % STEP 5 --- INTERACTION FORCES
        % calculate particle-obstacle and particle-particle interaction forces
        %--------------------------------------------------------------------------

        [force_cw pw_torque] = PartWallInteract(lx,ly,dimension,iflag,num_coll_par,center_coll,rad_coll,search_distance,index_att_rep_cw,spring_cons,rep_strength_cw,att_strength_cw,stiff_param_cw,electrostat_exp_cw);
        [force_cc pp_torque] = PartPartInteract(iter,it_coll,lx,ly,dimension,num_coll_par,center_coll,rad_coll,search_distance,index_att_rep_cc,index_att_rep_cw,threshold_mindist,rep_strength_cc,att_strength_cc,stiff_param_cc,electrostat_exp_cc);

        traj(iter*num_coll_par+1:iter*num_coll_par+num_coll_par,:) = cent;
        tmp = [cent,rc,par_veloc,par_ang_vel];
        save(stcent,'tmp','-ascii','-append')

    % toc
        %iter
 screen_size = get(0, 'ScreenSize');
    fig2=figure('Visible','off');
    set(fig2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    set(fig2,'PaperPositionMode','auto')
    axes('FontSize',fsize)
    axis equal
    hold on
    vmin = floor(min(vel(:)));
    vmax = ceil(max(vel(:)));
    vinc = (vmax - vmin) / 100;
    levs = vmin:vinc:vmax;

    [~,hc] = contour(XX,YY,vel',levs);  %replaced Cc with ~ to stop warning
    colorbar('location','eastoutside','FontSize',fsize)
    set (hc,'LineWidth', 3);
   
    axis equal
    saveas(fig2,[dir,'/velocity', num2str(iter)],'png') %Save the figure
    end

    % for i_colp=1:num_coll_par
    %     fclose(fileID(i_colp));
    % end


    eltime = toc
    stE = [dir,'/Elapsed_time_', num2str(num_coll_par),'_particles.txt'];
    save(stE,'eltime','-ascii')


    screen_size = get(0, 'ScreenSize');
    fig2=figure('Visible','off');
    set(fig2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    set(fig2,'PaperPositionMode','auto')
    axes('FontSize',fsize)
    axis equal
    hold on

     fig2=figure('Visible','off');
    set(fig2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    set(fig2,'PaperPositionMode','auto')
    axes('FontSize',fsize)
    axis equal
    hold on

%     [ca,~] = real_Berg_gradient(Max,Xs,Ys,diff_rate,Xg,fixed_time);
%     ca=reshape(ca,size_XX);
%     ca(ca>800)=0;
%     cmin = floor(min(ca(:)));
%     cmax = ceil(max(ca(:)));
%     cinc = (cmax - cmin) / 50;
%     clevs = cmin:cinc:cmax;
    z = griddata(xgrid,ygrid,conc(:,end), xxxg,yyyg);

    [~,hc] = contour(xxxg,yyyg,z,0:10:1000);  %replaced Cc with ~ to stop warning
    colorbar('location','eastoutside','FontSize',fsize)
    set (hc,'LineWidth', 3);
    axis equal


    for i=1:lx
        for j=1:ly
            if (iflag(i,j) == 1)
                rectangle('Position',[i,j,1,1],'Curvature',[0,0],'FaceColor',[0 0 0]);
            end
        end
    end

    for i=1:num_coll_par
        plot(rc_o(i,1),rc_o(i,2),'ok','Markersize',10,'LineWidth',2.0);
        plot(cent_o(i,1),cent_o(i,2),'ob','Markersize',10,'MarkerFaceColor',[0 0 1])
        plot([rc_o(i,1) cent_o(i,1)],[rc_o(i,2) cent_o(i,2)],'k-');
        rectangle('Position',[cent_o(i,1)-rad_coll(i),cent_o(i,2)-rad_coll(i),2*rad_coll(i),2*rad_coll(i)],...
            'Curvature',[1,1],'LineWidth',2.0);

        plot(traj(i:num_coll_par:num_coll_par*(iter),1),...
             traj(i:num_coll_par:num_coll_par*(iter),2),'--',...
             'Linewidth',2,'color',colorc(i,1:3));

        plot(rc(i,1),rc(i,2),'ok','Markersize',10,'LineWidth',2.0);
        plot(cent(i,1),cent(i,2),'om','Markersize',10,'MarkerFaceColor',[1 0 1])
        plot([rc(i,1) cent(i,1)],[rc(i,2) cent(i,2)],'k-');
        rectangle('Position',[cent(i,1)-rad_coll(i),cent(i,2)-rad_coll(i),2*rad_coll(i),2*rad_coll(i)],...
            'Curvature',[1,1],'LineWidth',2.0);

    end
    axis([0 lx 0 ly])
    saveas(fig2,[dir,'/trajectory'],'png') %Save the figure


    % profile viewer
    % p = profile('info');
    % profsave(p,'profile_results')


%     screen_size = get(0, 'ScreenSize');
%     fig2=figure('Visible','off');
%     set(fig2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
%     set(fig2,'PaperPositionMode','auto')
%     axes('FontSize',fsize)
%     axis equal
%     hold on
%     vmin = floor(min(vel(:)));
%     vmax = ceil(max(vel(:)));
%     vinc = (vmax - vmin) / 100;
%     levs = vmin:vinc:vmax;
% 
%     [~,hc] = contour(XX,YY,vel',levs);  %replaced Cc with ~ to stop warning
%     colorbar('location','eastoutside','FontSize',fsize)
%     set (hc,'LineWidth', 3);
%     ex = num2str(iter)
%     axis equal
%         saveas(fig2,[dir,'/' iter],'png') %Save the figure
    
    for i_colp = 1:num_coll_par
        rectangle('Position',[center_coll(i_colp,3),center_coll(i_colp,2),rad_coll(i_colp),rad_coll(i_colp)],...
            'Curvature',[1,1],'FaceColor','w');
    end
    saveas(fig2,[dir,'/velocity'],'png') %Save the figure

    % %--------------------------------------------------------------------------
    % %Compare Solutions
    % %--------------------------------------------------------------------------%
    % errors = zeros(ly-1,1);
    % xdist=[];
    % for j = 1:ly-1
    %     error(j) = abs(vel(round(lx/2),j) - vel_steady(j));
    %     xdist(j)=j;
    % end
    % 
    % %NEW
    % subplot(3,3,2)
    %  set(gca,'FontSize',16);
    %  xlim([1 61]);
    % plot(xdist,vel_steady,'o','Color',[0,0.5,0.]);
    % hold on;
    % 
    % % plot(xdist,vel,'--','Color',[1,0.5,0.],'LineWidth',2.5);
    % % hold on;
    % %NEW
    % 
    % [max_error,ind] = max(error)
    % mean_error = mean(error)
end