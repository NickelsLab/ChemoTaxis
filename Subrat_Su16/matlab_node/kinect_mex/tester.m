detector = vision.CascadeObjectDetector('zumoSignDetector1.xml');
img = imread('File_000.jpeg');
bbox = step(detector,img);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'stop sign');
figure(1);
imshow(detectedImg);

detector = vision.CascadeObjectDetector('zumoSignDetector1.xml');
img = imread('File_001.jpeg');
bbox = step(detector,img);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'stop sign');
figure(2);
imshow(detectedImg);


detector = vision.CascadeObjectDetector('zumoSignDetector1.xml');
img = imread('File_002.jpeg');
bbox = step(detector,img);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'stop sign');
figure(3);
imshow(detectedImg);

detector = vision.CascadeObjectDetector('zumoSignDetector1.xml');
img = imread('File_003.jpeg');
bbox = step(detector,img);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'stop sign');
figure(4);
imshow(detectedImg);

detector = vision.CascadeObjectDetector('zumoSignDetector1.xml');
img = imread('File_004.jpeg');
bbox = step(detector,img);
detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'stop sign');
figure(5);
imshow(detectedImg);