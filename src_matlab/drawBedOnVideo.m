%% drawBedOnVideo.m
% A file to draw
videoFilename = '/Users/zhanwenchen/Documents/projects/FallDetection/FLIR Pilot Data/001/001_arm.avi';
bed = [0 206 320 210 320 17 0 16];
[V, vidObj] = loadVideo(videoFilename);


v = insertShape(V,'Polygon', bed,'LineWidth', 2);

implay(v);