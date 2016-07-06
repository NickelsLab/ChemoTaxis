screen_size = get(0, 'ScreenSize');
fig2=figure('Visible','off');
set(fig2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
set(fig2,'PaperPositionMode','auto')
axes('FontSize',fsize)
axis equal
hold on

for i=1:num_coll_par
    %colorc(i,1:3)
    plot(traj(i:num_coll_par:end,1),traj(i:num_coll_par:end,2),'o','color',colorc(i,1:3));
end
axis equal
saveas(fig2,[dir,'/trajectory'],'png') %Save the figure
