close all
clear all
fsize = 24; 
%%%%parameters
test = 1;
num_coll_par = 1;
rad_coll=3.5*ones(1,num_coll_par);

colorc = rand(num_coll_par,3);                            %Setting up colors to display cells

dir = ['num_cells_',num2str(num_coll_par),'_test_', num2str(test)];

stname = [dir,'/iflag_', num2str(num_coll_par),'_particles.txt'];
iflag=load(stname);

stcent = [dir,'/centroids_', num2str(num_coll_par),'_particles.txt'];
A = load(stcent);
traj = A(:,1:2); cent_o = traj(1:num_coll_par,:); 
cent = traj(end-2*num_coll_par+1:end-num_coll_par,:) 
rc_traj = A(:,3:4); rc_o = rc_traj(1:num_coll_par,:);
rc = rc_traj(end-2*num_coll_par+1:end-num_coll_par,:)

%%%Concentration parameters
%Berg gradient parameters
Max = 5000;                                         %Maximum aspartate concentration in uM
Xs = 200.5;                                             %X center of the gradient
Ys = 100.5;                                            %Y center of the gradient                                     %Center of the gradient
diff_rate = 890;              

init_grad_time = 0.2;                      %Gradient start time is 2 minutes
time_factor = 20;
fixed_time = init_grad_time/time_factor;

lx = 2*floor(Xs);                                                                  %channel length (in LB) 
ly = 2*floor(Ys);                                                                   %channel width (in LB)

%Fluid grid
[XX,YY]=meshgrid(1:lx,1:ly);
XXT=reshape(XX,size(XX,1)*size(XX,2),1); %Make X's into a column
YYT=reshape(YY,size(YY,1)*size(YY,2),1); %Make Y's into a column
Xg=[XXT,YYT]; %Evaluation points in (x,y) format
size_XX = size(XX);

screen_size = get(0, 'ScreenSize');
fig2=figure('Visible','off');
set(fig2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
set(fig2,'PaperPositionMode','auto')
axes('FontSize',fsize)
axis equal
hold on

[ca,~] = real_Berg_gradient(Max,Xs,Ys,diff_rate,Xg,fixed_time);
ca=reshape(ca,size_XX);
cmin = floor(min(ca(:)));
cmax = ceil(max(ca(:)));
cinc = (cmax - cmin) / 40;
clevs = cmin:cinc:cmax;

[~,hc] = contour(XX,YY,ca,clevs);  %replaced Cc with ~ to stop warning
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
    plot(traj(i:num_coll_par:end-num_coll_par,1),...
         traj(i:num_coll_par:end-num_coll_par,2),'--',...
         'Linewidth',2,'color',colorc(i,1:3));
     
    plot(rc_o(i,1),rc_o(i,2),'ok','Markersize',10,'LineWidth',2.0,'MarkerFaceColor',[0 0 1])
    plot(cent_o(i,1),cent_o(i,2),'ob','Markersize',10,'MarkerFaceColor',[0 0 1])
    plot([rc_o(i,1) cent_o(i,1)],[rc_o(i,2) cent_o(i,2)],'k-');
    rectangle('Position',[cent_o(i,1)-rad_coll(i),cent_o(i,2)-rad_coll(i),2*rad_coll(i),2*rad_coll(i)],...
        'Curvature',[1,1],'LineWidth',2.0);

    plot(rc(i,1),rc(i,2),'ok','Markersize',10,'LineWidth',2.0,'MarkerFaceColor',[1 0 0])
    plot(cent(i,1),cent(i,2),'or','Markersize',10,'MarkerFaceColor',[1 0 0])
    plot([rc(i,1) cent(i,1)],[rc(i,2) cent(i,2)],'k-');
    rectangle('Position',[cent(i,1)-rad_coll(i),cent(i,2)-rad_coll(i),2*rad_coll(i),2*rad_coll(i)],...
        'Curvature',[1,1],'LineWidth',2.0);
    
end
axis([0 lx 0 ly])
saveas(fig2,[dir,'/trajectory'],'png') %Save the figure
