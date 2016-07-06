function PlotBnd(CenterPar,Radi,boundary,CRSurf,SV,SVEX,lSV,SVEndPnt,...
    TriangleCage,TriangleCage_Ex,BoundNodesDefPart,BoundNodesDefPart_Ex,...
    AddBndNodes,AddBndNodes_Ex,IntBndNodePair,ExtBndNodePair)
%     CRSurf,newboundary_INT,newboundary_INT_Comp,...
%     CRS_surface_Comb_Uniq_Interior,,IntraParNodes,,...
%     ,,...
%     ,,...
%     IntBndNodePair,ExtBndNodePair)


% function PlotBnd(CenterPar,Radi,inter,boundary,newboundary,...
%     CRSurf,newboundary_INT,newboundary_INT_Comp,...
%     CRS_surface_Comb_Uniq_Interior,SV,SVEX,lSV,IntraParNodes,SVEndPnt,...
%     TriangleCage,TriangleCage_Ex,BoundNodesDefPart,...
%     BoundNodesDefPart_Ex,AddBndNodes,AddBndNodes_Ex,...
%     IntBndNodePair,ExtBndNodePair)
%---------  print specifications -----------------------------------------
fntsize=14;
set(gca,'FontSize',fntsize);
% enter min and max of x- and y-axis
xmin = 15;
ymin = 5;
xmax = 45;
ymax= 35;
tic_int=1;% grid interval
%--------------------------------------------------------------------------
% plot boundary nodes (calculated by circle)
%scatter(boundary(:,1),boundary(:,2),'filled','g');
grid on;
xlabel(gca,'x '),ylabel(gca,'y')
xlim([xmin xmax]);
ylim([ymin ymax]);
ylim([22 23]);
set(gca, 'xtick', xmin : tic_int : xmax);
set(gca, 'ytick', ymin : tic_int : ymax);
axis equal;
grid on;
%--------------------------------------------------------------------------
% ------Plot Catmull-Rom surface (additional node added by the CRS)--------
% subplot(1,2,1)
% scatter(CRSurf(:,1),CRSurf(:,2),'d','filled','green');
%   hold on;
  axis equal;
  grid on;
%   subplot(1,2,2);
 line(CRSurf(:,1),CRSurf(:,2),'Color','k','LineWidth',1.5);
 hold on;
 
%------------------------------Search vectors------------------------------
%  for i=1:2:lSV-1 % note two nodes 
%     line(SV(i:i+1,1),SV(i:i+1,2),'Color','b','LineWidth',1.5);
%     line(SVEX(i:i+1,1),SVEX(i:i+1,2),'Color','m','LineWidth',1.5);
%  hold on;
%  end
% % dbstop if error -- check if you have any error
% 
% for i=1:2:lSV-1 % note two nodes 
%    line(SV(i:i+1,1),SV(i:i+1,2),'Color','b','LineWidth',1.5);
% hold on;

%---------------- triangular caging --------------------------------------- 

%triangular cage -- INSIDE the deformable surface
%  scatter(TriangleCage(:,1),TriangleCage(:,2),'MarkerEdgeColor','red');
%  for i=1:3:length(TriangleCage)-2
%      line(TriangleCage([i,i+1],1),TriangleCage([i,i+1],2),'Color','b','LineWidth',0.5);
%      hold on;
%      line(TriangleCage([i,i+2],1),TriangleCage([i,i+2],2),'Color','b','LineWidth',0.5);
%      hold on; 
%      line(TriangleCage([i+1,i+2],1),TriangleCage([i+1,i+2],2),'Color','b','LineWidth',0.5);
%      hold on; 
%  end
%  hold on;

%  %triangular cage -- OUTSIDE the deformable surface
%  scatter(TriangleCage_Ex(:,1),TriangleCage_Ex(:,2),'MarkerEdgeColor','k');
%  for i=1:3:length(TriangleCage_Ex)-2
%      line(TriangleCage_Ex([i,i+1],1),TriangleCage_Ex([i,i+1],2),'Color','m','LineWidth',0.5);
%      hold on;
%      line(TriangleCage_Ex([i,i+2],1),TriangleCage_Ex([i,i+2],2),'Color','m','LineWidth',0.5);
%      hold on; 
%      line(TriangleCage_Ex([i+1,i+2],1),TriangleCage_Ex([i+1,i+2],2),'Color','m','LineWidth',0.5);
%      hold on; 
%  end
%  hold on;
%--------------------------------------------------------------------------

% ----Lattice Nodes captured by internal and external triangular cages----- 
% lattice nodes captured in triangular cages INSIDE the defrormable surface
%  scatter(BoundNodesDefPart(:,1),BoundNodesDefPart(:,2),'filled','r');
%  hold on;
% 
% % lattice nodes captured in triangular cages INSIDE the defrormable surface
% scatter(BoundNodesDefPart_Ex(:,1),BoundNodesDefPart_Ex(:,2),'filled','sb');
% hold on;
%--------------------------------------------------------------------------

% additonal INTERNAL boundary nodes
%  scatter(AddBndNodes(:,1),AddBndNodes(:,2),'r');
%  hold on;
% 
% % additonal EXTERNAL boundary nodes added
%  scatter(AddBndNodes_Ex(:,1),AddBndNodes_Ex(:,2),'sb');
% hold on;

%--------------------------------------------------------------------------
% - plot internal and external boundary nodes along with the links
% subplot(1,2,2) 


scatter(IntBndNodePair(:,1),IntBndNodePair(:,2),'filled','red');
  hold on;
  
  scatter(ExtBndNodePair(:,1),ExtBndNodePair(:,2),'filled','black');
  hold on; 
%  
% % scatter(newboundary(:,1),newboundary(:,2),'MarkerEdgeColor','red');
% % hold on;
% % 
 icount=0;
for i=1:length(IntBndNodePair)
    icount=icount+1;
    AllBndNodes(icount,:)=IntBndNodePair(i,:);
    icount=icount+1;
    AllBndNodes(icount,:)=ExtBndNodePair(i,:);
     line(AllBndNodes(icount-1:icount,1),AllBndNodes(icount-1:icount,2),'Color','b','LineWidth',0.8);
     hold on;
end

 scatter(CRSurf(:,1),CRSurf(:,2),'d','filled','green');
  hold on;



%--------------------------------------------------------------------------


%grid on;
xlabel(gca,'x '),ylabel(gca,'y')
xlim([xmin xmax]);
%ylim([ymin ymax]);
ylim([22 23]);

set(gca, 'xtick', xmin : tic_int : xmax);
set(gca, 'ytick', ymin : tic_int : ymax);

axis equal;

grid on;

% dbstop if error -- check if you have any error


end

