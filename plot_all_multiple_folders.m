%% Plot all the whisking angles over time on the same figure
% Last edited 6/17/16 by Hill Chang

% This script examines all the .mat files in a single folder, created by
% merge_nmat_files_3
% Note: Thie script assumes that each .mat file contains only one whisking
% bout



clear; 

numFolders = input('How many folders do you want to analyze?');
allAngles = zeros(1,1001);

for n = 1:numFolders
    if (n==1) % For some reason the line folder = uigetdir doesn't run the first time if n>1
        folder = uigetdir;
    else
        folder = uigetdir; % Yeah this line it doesn't seem to get run and I don't know why
        folder = uigetdir; % This one does though for some reason
    end
    
    cd(folder);
    filePattern = fullfile(folder, '*.mat');
    matfiles = dir(filePattern);
    count = length(matfiles);

    angles = importdata(matfiles(1,1).name);
    angles = angles.MovieInfo.AvgWhiskerAngle;
    % allAngles = zeros(count,1001);


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
        
        %% Normalize data so that resting position is at 0
        angles = angles - mean(angles(1:whiskStart));

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



        %% Plot angle data and mark whisk beginning
        % subplot(count,1,i);
    %   figure;
    % %     if (whiskStart >= 500)
    % %         plot(angles(whiskStart-500:length(angles))); hold on;
    % %         plot(locs+500,peaks,'.k'); hold on;
    % %         plot(oldLocs+500,oldPeaks,'oy');
    % %     else
    % %         % locs(p) = 0;
    % %         plot(((500-whiskStart):(10499-whiskStart)),angles(1:10000));
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

    %% Add to summative data
        angles=angles(whiskStart:whiskStart+1000);
        if (allAngles(1,:) == zeros(1,1001))
            allAngles = angles;
        else
            allAngles = [allAngles;angles];
        end

    end    
end



%% Calculate summative data
meanAngles = mean(allAngles);
stdAngles = std(allAngles);

figure;
plot(meanAngles,'r--'); hold on;
plotshaded(1:1001,[meanAngles+stdAngles; meanAngles-stdAngles],'b');

