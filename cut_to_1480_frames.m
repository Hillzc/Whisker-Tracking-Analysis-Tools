tic;
clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.avi');
matfiles = dir(filePattern);
count = length(matfiles);

for f = 1:count;

%Script to cut every video to 1480 frames 

movie = char({matfiles(f,1).name})
M = mmreader(movie);
nFrames = M.NumberOfFrames;
vidHeight = M.Height;
vidWidth = M.Width;

% Preallocate movie structure
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'single'),...
           'colormap', []);

% Determine first and last frames
startFrame = 1;
lastFrame = 1480;

newVideo = VideoWriter(strcat(M.Name(1:length(M.Name)-4),'_', num2str(lastFrame)), 'Grayscale AVI');
newVideo.FrameRate = M.FrameRate;
open(newVideo);
for k = startFrame: lastFrame;
    k;
    mov(k).cdata = read(M, k);
    writeVideo(newVideo,mov(k));
    mov(k).cdata = [];
end
clear newVideo
end

toc;
