load('zumoData_train2.mat');
%above you need to open the image acquistion toolbox, and open that file and export ROIs under that name.
%imDir = fullfile(matlabroot,'toolbox','vision','visiondata','ZPositiveImages');
imDir = fullfile('zumo_updated_positives');
addpath(imDir);
%negativeFolder = fullfile(matlabroot,'toolbox','vision','visiondata','ZNegativeImages');
negativeFolder = fullfile('zumo_updated_negatives');



trainCascadeObjectDetector('zD1.xml',zumoData_train2,negativeFolder,'FalseAlarmRate',0.001,'NumCascadeStages',5)
trainCascadeObjectDetector('zD2.xml',zumoData_train2,negativeFolder,'FalseAlarmRate',0.005,'NumCascadeStages',5)
trainCascadeObjectDetector('zD3.xml',zumoData_train2,negativeFolder,'FalseAlarmRate',0.05,'NumCascadeStages',5)
