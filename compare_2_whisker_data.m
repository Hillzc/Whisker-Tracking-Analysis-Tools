%% Compare 2 sets of whisker data and plot them on top of each other
% Assuming 16 trials

%% Load natural whisking data
clear;
disp('Load natural whisking data');
uiopen('load');
naturalAngles = MovieInfo.AvgWhiskerAngle;
figure;
plot(naturalAngles)
disp('Click on whisk starting time');
% [nWhiskStart, y] = ginput(1);
nWhiskStart = 2292;
disp('Click on whisk ending time');
[nWhiskEnd, y] = ginput(1);
close;

% Normalize natural whisking data
naturalAngles = naturalAngles - mean(naturalAngles(1:nWhiskStart));
naturalAngles = naturalAngles(nWhiskStart:nWhiskEnd);

%% Load stimulated whisking data
disp('Select stimulated whisking data folder');
folder = uigetdir();
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);

figure;
for i=1:count; 
    i %% Declare which file this is
    stimulatedAngles = importdata(matfiles(i,1).name);
    stimulatedAngles = stimulatedAngles.MovieInfo.AvgWhiskerAngle;

    figure;
    plot(stimulatedAngles);
    disp('Click on whisk starting time');
    axis([400 600 -inf inf]);
    [sWhiskStart, y] = ginput(1);
    sWhiskEnd = sWhiskStart + (nWhiskEnd - nWhiskStart);
    close;

    stimulatedAngles = stimulatedAngles - mean(stimulatedAngles(1:sWhiskStart));
    stimulatedAngles = stimulatedAngles(sWhiskStart:sWhiskEnd);

%     Uncomment these next three lines if you want to also graph each set of whisker data alongside the initial
%     figure;
%     plot(naturalAngles); hold on;
%     plot(stimulatedAngles,'-r');
    
 
    [r,lags] = xcorr(naturalAngles,stimulatedAngles,'coeff');
    subplot(4,4,i);    
    plot(lags,r); hold on;
    [maxCorr,maxCorrI] = max(abs(r))
    lag = lags(maxCorrI)
    plot(lag,r(maxCorrI),'o');
    title(i);
end

