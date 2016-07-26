%Take Picture



kinect_mex(); % call one to initialize the freenect interface
pause(6);
kinect_mex(); % get first data...
kinect_mex()
;

logicalVideo = false;
tic;
counter = 1;


while logicalVideo == false
	filename = strcat(strcat('imgg',int2str(counter)),'.jpg');
	[a,b]=kinect_mex();
	if (length(b)>307200),
		        img = permute(reshape(b,[3,640,480]),[3 2 1]);
		 else
		        img = repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]);
	end
	imagesc(img);
	title('img');
	imwrite(img,filename);


	fprintf('Press Enter to Take a Picture!\n');
	pause
	counter = counter + 1;
end