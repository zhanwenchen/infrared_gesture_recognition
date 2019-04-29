% GetAllFrames.m
%
% Matlab script to extract the frames from a set of FLIR videos
%
% This function depends on a specific folder hierarchary:
%
%   'FallDetection\FLIR Pilot Data\nnn\Frames'
%
% where nnn is a 3-digit decimal number.
% The function file itself should be in folder 'FallDetection'.
% It should be run from folder 'FallDetection'.
%
% frameDirname = 'Frame';
diffFrameDirname = 'FrameDiffs_lines';
% projectDir = '/Users/zhanwenchen/Documents/projects/FallDetection';
% cd '/Users/zhanwenchen/Documents/projects/FallDetection'
% root = projectDir;
% dirs = GetSubDirs(['FLIR Pilot Data' ''])

% load('classifier.mat')
% f = medSVM;
% cclip = 48;

d = dir('FLIR Pilot Data');
isub = [d(:).isdir]; %# returns logical vector
dirs = {d(isub).name}
dirs(ismember(dirs,{'.','..'})) = [];
N = size(dirs,2);

% pwd
cd 'FLIR Pilot Data'
% create FrameDiffs folders if they don't already exist
i = 2;
while i <= N
    cd(dirs{i});
    filelist = dir('.');
%     filelist = dir(dirs{i});
    M = size(filelist,1);
    DiffDirIdx = 1;
    foundDir = ~isempty(strfind(filelist(DiffDirIdx,1).name,'Frame'));
    while (DiffDirIdx <= M) && ~foundDir
        foundDir = ~isempty(strfind(filelist(DiffDirIdx,1).name, diffFrameDirname));
        DiffDirIdx = DiffDirIdx + 1;
    end
    if ~foundDir
        mkdir(diffFrameDirname);
        i = i + 1;
    else
        i = i + 2;
    end
    cd ..
end

% load videos, get frames, and compute diffs
% dirs = GetSubDirs([root 'FLIR Pilot Data'])';
% N = size(dirs,1);
nVids = zeros(N,1);
for i = 2:N
    isDiffDir = ~isempty(strfind(dirs{1,i},'Frame'));
    if ~isDiffDir
        cd(dirs{i});
        disp(['now in dir: ' dirs{i}])
        filelist = dir('.');
        M = size(filelist,1);
        for j = 1:M
            if (length(filelist(j,1).name) > 4) && ...
                    ~isempty(strfind(filelist(j,1).name,'.avi'))
                nVids(i,1) = nVids(i,1)+1;
                % load the video frames
                video_fname = filelist(j,1).name
                [V, vidObj] = loadVideo(video_fname);
                % Get the file name
                [~,name,ext] = fileparts(filelist(j,1).name);
                disp(['now processing: ' name])
                [frames,rows,cols,bands] = size(V);
                disp([num2str(frames) ' frames']);
                D = diff(V);
                for k = 1:frames
                    fImg = squeeze(V(k,:,:,:));
                    fpath = ['.\Frames\' name '_frame_' int2strz(k,2) '.bmp'];
                    img_uint8 = uint8(fImg);
                    linesImage = getLinesImageFromImage(img_uint8);
                    % imwrite(img_uint8,fpath,'bmp');
                    if k < frames
                        dImg = squeeze(D(k,:,:,:));
                        dpath = ['.\diffFrameWithLines\' name '_diff_' int2strz(k,2) '.bmp'];
                        diffFrameInt = norm_to_uint8(dImg);
%                         diffFrameWithLines = imadd(diffFrameInt,linesImage);
                        diffFrameWithLines = imfuse(diffFrameInt,linesImage);
                        imwrite(diffFrameWithLines,dpath,'bmp');
                    end
                end
                save([name '_frames'],'V','D');
            end
        end
    end
end

cd ..
