function [ u, p ] = SolveConc(init_conc,t_init, velx, vely)
pdem = createpde;
rect = [3 4 0 1 1 0 0 0 1 1]';
gd = rect;
% ns = char('rect1', 'rect2');
% ns = ns';
% sf = 'rect1+rect2';
% % % dl = decsg(gd,sf,ns);
[dl,bt,dl1,bt1,msb] = decsg(gd);
%  figure;
%  pdegplot(dl,'EdgeLabels', 'on', 'SubdomainLabels', 'on')
%  xlim([0,1])
save('velx.mat')
save('vely.mat')
    
geometryFromEdges(pdem,dl);
% subplot(2,1,1)
% pdegplot(pdem,'EdgeLabels', 'on', 'SubdomainLabels', 'on')
% axis equal
Q0 = 0;
G0 = 1;
% applyBoundaryCondition(pdem,'Edge',[1 3],'u',0);
applyBoundaryCondition(pdem,'Edge',4,'u',1000);
% applyBoundaryCondition(pdem, 'Edge', [5 6 15 16], 'g',1, 'q', 2)
% applyBoundaryCondition(pdem,'Edge',[2:3 62:81 83:102],'q',Q0,'g',G0);
% generateMesh(pdem, 'Hmax', 0.04)
generateMesh(pdem)
% subplot(2,1,2)
% pdeplot(pdem)
% axis equal

p = pdem.Mesh.Nodes;
u0 = init_conc;
[p e t] = meshToPet(pdem.Mesh);
t_fin = t_init+1;
tlist = t_init:0.1:t_fin;
p2 = ones(length(p),100);
% c = sprintf('%g*ux.^2 -uy.^2',p2);
c = 1;
a = 0;
d = 5;
p2 = 1;
f = @ffuncint;
% f= [];
% for i = 1:length(p)
%     f(i) = sprintf('%g*ux.^2 -uy.^2',p2(i));
% end
% f = @ffuncfullsrc;
% f = coeffunction(p,t,u,time);
% u = parabolic(u0,tlist,pdem,c,a,f,d);
u = parabolic(u0,tlist,pdem,c,a,f,d);


figure
subplot(2,2,1)
pdeplot(pdem,'xydata',u(:,1));
% axis equal
title(['t = ' num2str(t_init)])
subplot(2,2,2)
pdeplot(pdem,'xydata',u(:,3))
% axis equal
title(['t = ' num2str(t_init+0.3)])
subplot(2,2,3)
pdeplot(pdem,'xydata',u(:,5))
% axis equal
title(['t = ' num2str(t_init+0.5)])
subplot(2,2,4)
pdeplot(pdem,'xydata',u(:,end))
% axis equal
title(['t = ' num2str(t_fin)])


end

