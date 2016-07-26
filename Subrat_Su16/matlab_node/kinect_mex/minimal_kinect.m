
pause(3);
kinect_mex(); % call one to initialize the freenect interface
pause(3);
kinect_mex(); % get first data...





logicalVideo = false;
tic;


while logicalVideo == false
	[a,b]=kinect_mex();
	 if (length(b)>307200),
	        img = permute(reshape(b,[3,640,480]),[3 2 1]);
	 else
	        img = repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]);
	 end


	detector = vision.CascadeObjectDetector('zumoDetector1.xml');
	bbox = step(detector,img);
	
	bboxBool = isempty(bbox);
	fprintf('\nbboxBool = %d', bboxBool);

	detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'Look at my Zumo');
	imshow(detectedImg);



	if (toc > 10000)
        logicalVideo = true;
	end


end






