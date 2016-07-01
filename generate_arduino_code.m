%% GENERATE ARDUINO CODE TO REPLICATE NATURAL WHISKING
% Onw spontaneous whisking bout at a time

%% Load Natural Whisking Data
clear;
disp('Load natural whisking data');
uiopen('load');
angles = MovieInfo.AvgWhiskerAngle;

%% Find whisk start/end
figure;
plot(angles)

disp('Click on whisk starting time');
[whiskStart,y] = ginput(1);

disp('Click on whisk ending time');
[whiskEnd,y] = ginput(1);

close;

%% Normalize data so that resting position is at 0
angles = angles - mean(angles(1:whiskStart));

%% Locate Protractions/retractions
[protractions,protractionLocs,retractions,retractionLocs] = extrema(angles);
allData = [horzcat(protractions,retractions); horzcat(protractionLocs,retractionLocs)];
sortedData = sortrows(allData',2);
sortedData = sortedData';
peaks = sortedData(1,:);
locs = sortedData(2,:);

%% Write Arduino code
disp('Select Location to save Arduino code');
cd(uigetdir);
replicateNatural = fopen('replicateNatural.ino','w+');

for i = 1:length(peaks)-1
   movement = peaks(i+1)-peaks(i);
   time = locs(i+1)-locs(i);
   slope = movement/time;
   if (slope >= 0)
       % pLightDuration = protraction(movement, time);
   else
       % rLightDuration = retraction(movement, time);
   end
   fprintf(replicateNatural,'triggerLightOne(%d)\n',i);

end