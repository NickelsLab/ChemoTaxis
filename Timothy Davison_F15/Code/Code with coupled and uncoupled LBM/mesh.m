model = createpde;
geometryFromEdges(model,@squareg);
pdegplot(model,'EdgeLabels','on')
ylim([-1.1,1.1])
axis equal

applyBoundaryCondition(model,'Edge',1:model.Geometry.NumEdges,'u',0);

% generateMesh(model,'Hmax',0.02);
generateMesh(model);


p = model.Mesh.Nodes;
u0 = zeros(size(p,2),1);
ix = find(sqrt(p(1,:).^2 + p(2,:).^2) <= 0.4);
u0(ix) = ones(size(ix));

tlist = linspace(0,1);
l = 2;
c = 1;
a = 0;
b = 5;
f =  char(strcat('5-',num2str(b),'*ux-uy'));
d = 1;

u = parabolic(u0,tlist,model,c,a,f,d);

figure
subplot(2,2,1)
pdeplot(model,'xydata',u(:,1));
axis equal
title('t = 0')
subplot(2,2,2)
pdeplot(model,'xydata',u(:,10))
axis equal
title('t = 0.02')
subplot(2,2,3)
pdeplot(model,'xydata',u(:,15))
axis equal
title('t = 0.05')
subplot(2,2,4)
pdeplot(model,'xydata',u(:,end))
axis equal
title('t = 0.1')