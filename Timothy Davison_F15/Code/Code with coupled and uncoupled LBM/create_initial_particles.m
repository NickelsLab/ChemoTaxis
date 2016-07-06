function [cent,rc] = create_initial_particles(num_coll_par,r,mag,size_grad,dir,fsize,init_dist,init_var,lx,ly,iflag)

%     for i1=1:num_coll_par
%         angr = 2*pi*rand;
%         cent(i1,:) = [init_var*rand+init_dist init_var*rand+init_dist];
%         angr = 2*pi*rand;
%         rc(i1,:) = r(i1)*[cos(angr) sin(angr)] + ones(size(angr))*cent(i1,:);
%     end

    %[x,y] = meshgrid(10:2*r:init_var,10:2*r:init_var);
    %cix = randperm(num_coll_par);
    %ciy = randperm(num_coll_par);
    not_done = true;
    while not_done
        not_done = false;
        [x,y] = meshgrid(init_var:2*r:2*init_var,init_var:2*r:2*init_var);
        cix = randperm(size(init_var:2*r:2*init_var,2));
        ciy = randperm(size(init_var:2*r:2*init_var,2));
        for i1 = 1:num_coll_par
            cent(i1,:) = [x(cix(i1),ciy(i1)) y(cix(i1),ciy(i1))];
            for i = 1:lx
                for j = 1:ly
                    if ((iflag(i,j) == 1) && (sqrt((cent(i1,1)-i)^2+(cent(i1,2)-j)^2) < r(i1)+1));
                        not_done = true;
                    end
                end
            end
        end
    end
    %%%assume size(ci)<size(x)
%     cent = [39.5642  10.5050;
%             66.2638  10.2324];
    for i1=1:num_coll_par
        cent(i1,:) = [x(cix(i1),ciy(i1)) y(cix(i1),ciy(i1))];
        angr = 2*pi*rand;
        rc(i1,:) = r(i1)*[cos(angr) sin(angr)] + ones(size(angr))*cent(i1,:);
    end
    
    
    screen_size = get(0, 'ScreenSize');
    fig2=figure('Visible','off');
    set(fig2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    set(fig2,'PaperPositionMode','auto')
    axes('FontSize',fsize)
    axis equal
    hold on

    cent
    rc
    
    for i=1:num_coll_par
        plot(rc(i,1),rc(i,2),'xr','Markersize',10)
        plot(cent(i,1),cent(i,2),'ob','Markersize',10)
        plot([rc(i,1) cent(i,1)],[rc(i,2) cent(i,2)],'k-');
    end
    axis([25 75 25 75])
    saveas(fig2,[dir,'/initial_pos'],'png') %Save the figure
    %pause
                
end
