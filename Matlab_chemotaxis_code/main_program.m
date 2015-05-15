%Main function 
function main_program()

tic
    %delete *.png
    close all;
    % clear all; 
    clc
    fsize = 24;
    dir = 'simulation_robot';
    mkdir(dir)
    
    %parameters for Green's function (concentration)
    Max = 4;
    Xs = 0;
    Ys = 0;
    size_grad = 20; 
    mag = 5.6;
    diff_rate = 0.16; %diffusion coefficient for Green's function (concentration)      
    fixed_time = 2000;
            
    Dr = 0.062; %diffusion rate for rotational diffusion 
         
    N_cell = 1; %number of cells/particles (non-deformable particle)
    N_IB = 2;   %boundary points/particle

    %p contains boundary points on particles (size: N_IB*N_cell by 2)
    p=[-18.4089    7.0912;
      -17.9069    9.0272]*4;
   
    total_time_steps = 40000;
    N_frame =  20; %number of frames to be printed out
    N_step = round(total_time_steps/N_frame) %number of steps between each frame
    delta_t = 0.01; %time-step
    
    vel_mag = 20; %in Micron/s (average running velocity)
    
    %find steady-state methylation for each cell, 5 is the initial guess
    m = repmat([5],N_cell,1); 
    for i =1:N_cell
      b = N_IB*(i-1);
      %assume that p(4+b,:) is the location of receptor cluster on each cell
      current_asp = Green_gradient(Max,Xs,Ys,diff_rate,p(2+b,:),fixed_time); 
      for ii = 1:400 %Stay in this one spot for 400 steps to equilibrate
        [m(i),~,~,~] = rapid_cell_1(current_asp,m(i),delta_t);
      end
    end
    
    traj = [p]; %keep track of the trajectory of each IB point (save all cell positions through time)
    
    colorc = [0.502 0.502 0.502; %gray
          0 1 1; %turquoise
          1 0 1; %magenta
          0.9412 0.4706 0; %orange          
          0.251 0 0.502; %purple
          1 0.8 0.2; %gold
          0.502 0.251 0; %brown
          0.502 0.502 0.502; %gray
          0 0.502 0.502; %green
          0 0 0.4]; %black          
            
    %time loop
    centroida = []; %keep track of centroid positions at each time step
    for i = 1:total_time_steps
        
        %When it's time, save a frame with current cell positions.
        if(mod(i-1,N_step) == 0) 
            screen_size = get(0, 'ScreenSize');
            %fig2=figure('Visible','off');
            fig2=figure('Visible','on');
            set(fig2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
            axes('FontSize',fsize)
            set(fig2,'PaperPositionMode','auto')

            draw_Green_gradient(Max,Xs,Ys,diff_rate,size_grad,fixed_time,mag) %Draw attractant gradient
            hold on

            %plot each cell
            for ii = 1:N_cell
                b = N_IB*(ii-1);
                if (i>1)
                    plot(centroida(ii:N_cell:N_cell*(i-1),1),...
                    centroida(ii:N_cell:N_cell*(i-1),2),'-b',...
                    'Linewidth',1);
                end
              
                plot(p(1+b:N_IB+b,1),p(1+b:N_IB+b,2),'-or',...
                    'Linewidth',2,'MarkerSize',10,...
                     'MarkerEdgeColor','r',...
                     'MarkerFaceColor',[0.5,0.5,0.5])
                 
                plot(p(2+b,1),p(2+b,2),'-or',...
                    'Linewidth',2,'MarkerSize',10,...
                     'MarkerEdgeColor','r',...
                     'MarkerFaceColor',[1.0 0.0 0.0])
               

            end
            
            axis equal
            axis([-mag*size_grad mag*size_grad -mag*size_grad mag*size_grad])
            axis off
            saveas(fig2,[dir,'/frame_',int2str(i-1)],'png') %Save the figure
        end
                 
        
        temp = [];%%%STORE VELOCITIES AT BOUNDARY POINTS (WILL BE PASSED TO LBM FOR COUPLING) 
        for ii=1:N_cell
            
            b = N_IB*(ii-1);
            centroid = mean(p(1+b:N_IB+b,:));
            centroida = [centroida;centroid];
            
            %Find the current concentrations
            current_asp = Green_gradient(Max,Xs,Ys,diff_rate,p(2+b,:),fixed_time); 
            
            %Find the methylation state of each cell
            [m(ii),mb,cheYp,A] = rapid_cell_1(current_asp,m(ii),delta_t);
            
            
            %Compute a probability to run
            if(rand < mb)
                %disp('run')
                state = 1;
                               
                %Compute running velocity
                vec = centroid - p(1+b,:); 
                vec = vec/norm(vec);
                run_vel = repmat(vel_mag*vec,N_IB,1);
                temp = [temp;run_vel];

            else
                %disp('tumble')
                state = 0;
                
                %Rotate cell by some random angle
                angr = 2*pi*(rand-0.5);
                p = rotate_cell(p,angr,centroid,N_IB,b); 
                temp = [temp;zeros(N_IB,2)];
            end     
        end
        

        %update particle positions 
        p = p + temp*delta_t; %without "coupling" with the fluid
        traj = [traj;p];
        
    end %End of main time loop
        
    
toc
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = Green_gradient(Max,Xs,Ys,D,point,t)
    r2=(point(:,1)-Xs).^2+(point(:,2)-Ys).^2;
    G=Max*exp(-r2/(4*D*t))/(4*pi*D*t); 

end

function draw_Green_gradient(Max,Xs,Ys,D,size_grad,t,mag)
    [x,y] = meshgrid(-mag*size_grad:0.5:mag*size_grad,-mag*size_grad:0.5:mag*size_grad);
    r2=(x-Xs).^2+(y-Ys).^2;
    G=Max*exp(-r2/(4*D*t))/(4*pi*D*t); 
    [Cc,hc] = contour(x,y,G,5);  
    colorbar('location','southoutside','FontSize',25)
    set (hc,'LineWidth', 3); 
end
    

