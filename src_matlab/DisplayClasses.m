% function [] = DisplayClasses(ImgDir,bag,trainedModel)
%
% This function depends on a specific folder hierarchary:
%
%   'FallDetection\FLIR Pilot Data\nnn\Frames'
%
% where nnn is a 3-digit decimal number. 
% The function file itself should be in folder 'FallDetection'.
% It should be run from folder 'FallDetection'.
%
% Example call: 
%
%   DisplayClasses(['FLIR Pilot Data\009\Frames'],bag,trainedModel)
%
% The function pauses after each image is displayed until a key is pressed.
% If the key is 'q' the function terminates.

function [] = DisplayClasses(ImgDir,bag,trainedModel)

cd(['.\' ImgDir])
filelist = dir('.');
f = figure(1000);
nImages = size(filelist,1);
trainedModelCell = struct2cell(trainedModel);
for i = 3:nImages
    I = imread([ImgDir '\' filelist(i).name]);
    imshow(I);
    imagefeatures = double(encode(bag, I));
    [bestGuess, score] = predict(trainedModelCell{3,1},imagefeatures);
    bestScore = max(abs(score));
    h=title([filelist(i).name '  Best Guess: ' char(bestGuess) '  Score: ' num2str(bestScore)],'color','r','fontsize',10,'Interpreter','none');
    set(h,'interpreter','none') % Make underscore not a subscript prefix
    drawnow
    w = waitforbuttonpress;
    if w == 1
        c = f.CurrentCharacter;
        if c == 'q'
            break
        end
    end
end

cd ../../..

end
