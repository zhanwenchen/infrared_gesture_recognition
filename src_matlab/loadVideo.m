function [V, vidObj] = loadVideo(inputFileName)

    vidObj = VideoReader(inputFileName);
    
    nBands = 3;
    
    nFrames = 0;
    while hasFrame(vidObj)
        readFrame(vidObj);
        nFrames = nFrames + 1;
    end
    vidObj.CurrentTime = 0;

    V = zeros(nFrames,vidObj.Height,vidObj.Width,nBands);
    
    for i = 1:nFrames
        V(i,:,:,:) = double(reshape(readFrame(vidObj),[1,vidObj.Height,vidObj.Width,nBands]));
    end

end