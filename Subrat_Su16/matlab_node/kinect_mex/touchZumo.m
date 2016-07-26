
if ~(exist('kinect_mex')==3),
    fprintf('compiling the mex file...\n');
    % NOTE probably need to change path names...
    mex -I../libfreenect/include ../libfreenect/build/lib/libfreenect.so ../libusb-1.0.0/libusb/.libs/libusb-1.0.so kinect_mex.cc 
end

fprintf('Making first call to initalize the kinect driver and listening thread\n');
kinect_mex(); % call one to initialize the freenect interface
%pause(1)
fprintf('Making second call starts getting data\n');
kinect_mex(); % get first data...

%kinect_mex('R'); % set to RGB Mode...


figure(1);
clf

%fprintf('Press enter to see continuous frame grabbing\n');
%pause;

tic;

last = toc;
draw_cum = 0;
draw_start = toc; draw_time=0;

logicalVideo = false;

%Enables video to continue for 10 seconds.
while logicalVideo == false
    [a,b]=kinect_mex();
    last = toc;
    fprintf('\r frame time = %4.4f  drawing_time = %4.4f',last-draw_start,draw_time);
    draw_start = toc;
    subplot(1,2,1);
    imagesc(permute(reshape(a,[640,480]),[2 1]));
    subplot(1,2,2);
    if (length(b)>307200),
        imagesc(permute(reshape(b,[3,640,480]),[3 2 1]));
    else
        imagesc(repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]));
    end
    drawnow
    draw_cum=draw_cum+toc-draw_start;
    draw_time=toc-draw_start;
    fprintf('\ntime equals; %4.4f', toc);

    if (toc > 100)
        logicalVideo = true;
    end
end

kinect_mex('q');
close all;





