%% Plot all the whisking angles over time on the same figure
% Last edited 6/17/16 by Hill Chang

% This script examines all the .mat files in a single folder, created by
% merge_nmat_files_3
% Note: Thie script assumes that each .mat file contains only one whisking
% bout



clear; 
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);

angles = importdata(matfiles(1,1).name);
angles = angles.MovieInfo.AvgWhiskerAngle;
allAngles = zeros(count,2100);


%% Loop for every .mat file
for i=1:count; 
    i %% Declare which file this is
    angles = importdata(matfiles(i,1).name);
    angles = angles.MovieInfo.AvgWhiskerAngle;

    %% Display raw data
    figure;
    plot(angles)
    axis([400 600 -inf inf])
    
    %% Find whisk start
    disp('Click on whisk starting time');
    [whiskStart,y] = ginput(1);
    % whiskStart = 500
    
    %% Find whisk end
    % disp('Click on whisk ending time');
    % [whiskEnd,y] = ginput(1);
    whiskEnd = length(angles)-500
    
    %% Close raw data
    close;
    
    %% Find whisk duration
    duration = (whiskEnd - whiskStart)*2 % Duration of whisking bout in ms
    
    %% Local Protractions/retractions
    % [peaks,locs]=findpeaks(angles,'MINPEAKDISTANCE',10);
    [protractions,protractionLocs,retractions,retractionLocs] = extrema(angles);
    allData = [horzcat(protractions,retractions); horzcat(protractionLocs,retractionLocs)];
    sortedData = sortrows(allData',2);
    sortedData = sortedData';
    peaks = sortedData(1,:);
    locs = sortedData(2,:);
    oldPeaks = peaks;
    oldLocs = locs;
    
    % Get rid of extra peaks (false positives)
    extraPeaks = [];
    for p=2:(length(peaks)-1);
        if (peaks(p-1) < peaks(p) && peaks(p+1) > peaks(p));
            extraPeaks = [extraPeaks p];
        end
        if (peaks(p-1) > peaks(p) && peaks(p+1) < peaks(p));
            extraPeaks = [extraPeaks p];
        end
    end
    for t=1:length(extraPeaks);
        peaks(p) = 0;
        locs(p) = 0;
    end
    peaks = peaks(peaks~=0);
    locs = locs(locs~=0);
    
    if (numel(peaks) == 1); % If for some reason there is only one peak, ensure that peaks and locs are both arrays
        peaks = [0 1];
        locs = [0 1];
    end
    
    %% Find average whisk period
    avgPeriod = mean(diff(locs))*2
    
    %% Find average whisk protraction
    avgMovement = mean(diff(peaks))
    
    %% Find average whisk retraction
   
    %% Find maximum whisk protraction
    maxProtraction = max(angles)  
    
    %% Find maximum whisk retraction
    maxRetraction = min(angles(whiskStart:whiskEnd))
   
    %% Find fastest whisker movement
    slope = 0;
    for m = 2:length(peaks);
        if (abs((peaks(m)-peaks(m-1)))/abs((locs(m)-locs(m-1))) > slope && abs((peaks(m)-peaks(m-1)))/abs((locs(m)-locs(m-1))) < 7);
            slope = abs((peaks(m)-peaks(m-1)))/abs((locs(m)-locs(m-1)));
            maxMovement = m;
            locs(maxMovement);
        end
    end
    disp(sprintf('The fastest whisker movement is %d degrees in %d ms',...
        peaks(maxMovement)-peaks(maxMovement-1),(locs(maxMovement)-locs(maxMovement-1))*2))
    
    %% Add to summative data
    for k=1:2100
        allAngles(i,k) = angles(k);
    end
    
    %% Plot angle data and mark whisk beginning
    % subplot(count,1,i);
%   figure;
% %     if (whiskStart >= 500)
% %         plot(angles(whiskStart-500:length(angles))); hold on;
% %         plot(locs+500,peaks,'.k'); hold on;
% %         plot(oldLocs+500,oldPeaks,'oy');
% %     else
% %         % plot(((500-whiskStart):(10499-whiskStart)),angles(1:10000));
% %         plot(angles); hold on;
% %         plot(locs,peaks,'.k'); hold on;
% %         plot(oldLocs,oldPeaks,'oy');
% %     end
% %     hold on;
% %     line([500 500],[-300 -150],'LineWidth',1,'LineStyle','-','Color','g'); hold on;
% %     line([(duration/2)+500 (duration/2)+500],[-300 -150],'LineWidth',1,'LineStyle','-','Color','r'); hold on;    
% %     line([locs(maxMovement-1)+500 locs(maxMovement)+500],[peaks(maxMovement-1) peaks(maxMovement)],'LineWidth',2,'Color','m','LineStyle','-.');
% %     axis([0 10000 -300 -150]);
% %     title(i);
%     plot(angles); hold on;
%     plot(locs,peaks,'.k'); hold on;
%     % plot(oldLocs,oldPeaks,'oy'); hold on;
%     line([whiskStart whiskStart],[-300 -150],'LineWidth',1,'LineStyle','-','Color','g'); hold on;
%     line([whiskEnd whiskEnd],[-300 -150],'LineWidth',1,'LineStyle','-','Color','r'); hold on;
%     line([locs(maxMovement-1) locs(maxMovement-1)],[peaks(maxMovement-1) peaks(maxMovement)],'LineWidth',2,'Color','m','LineStyle','-.');
%     axis([whiskStart whiskEnd -240 -210]);
%     title(i);

end

%% Calculate summative data
meanAngles = mean(allAngles);
stdAngles = std(allAngles);

figure;
plot(meanAngles,'r--'); hold on;
plotshaded(1:2100,[meanAngles+stdAngles; meanAngles-stdAngles],'b');

