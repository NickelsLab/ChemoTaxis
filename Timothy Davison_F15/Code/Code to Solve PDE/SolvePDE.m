
pdem = createpde;
rect = zeros(10,2);
rect(:,1) = [3 4 0 1 1 0 0 0 1 1]';
rect(:,2) = [3 4 0 0.1 0.1 0 0.4 0.4 0.6 0.6]';
gd = rect;
% ns = char('rect1', 'rect2');
% ns = ns';
% sf = 'rect1+rect2';
% % % dl = decsg(gd,sf,ns);
[dl,bt,dl1,bt1,msb] = decsg(gd);
% figure;
% pdegplot(dl,'EdgeLabels', 'on', 'SubdomainLabels', 'on')
% xlim([0,1])
%  
%     
 geometryFromEdges(pdem,dl);
% figure;
% subplot(2,1,1)
% pdegplot(pdem,'EdgeLabels', 'on', 'SubdomainLabels', 'on')
% axis equal
Q0 = 0;
G0 = 1;
% applyBoundaryCondition(pdem,'Edge',[1 3],'u',0);
applyBoundaryCondition(pdem,'Edge',8,'u',500);
% applyBoundaryCondition(pdem, 'Edge', [5 6 15 16], 'g',1, 'q', 2)
% applyBoundaryCondition(pdem,'Edge',[2:3 62:81 83:102],'q',Q0,'g',G0);
% generateMesh(pdem, 'Hmax', 0.04)
generateMesh(pdem)
% subplot(2,1,2)
% pdeplot(pdem)
% axis equal
% generateMesh(pdem, 'Hmax', 0.04)
% generateMesh(pdem)
% subplot(2,1,2)
% pdeplot(pdem)
% axis equal

p = pdem.Mesh.Nodes;
u0 = ones(size(p,2),1);
[p e t] = meshToPet(pdem.Mesh);
tlist = linspace(0,2);
p2 = ones(length(p),100);
% c = sprintf('%g*ux.^2 -uy.^2',p2);
c = 1; %diffusion coefficient
%previously used 0.1 and 50 cox
a = 0;
d = 5; %constant terms for u't
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
title('t = 0')
subplot(2,2,2)
pdeplot(pdem,'xydata',u(:,25))
% axis equal
title('t = 0.5')
subplot(2,2,3)
pdeplot(pdem,'xydata',u(:,50))
% axis equal
title('t = 1')
subplot(2,2,4)
pdeplot(pdem,'xydata',u(:,end))
% axis equal
title('t = 2')
