% Plot all the whisking angles over time on the same figure
% Last edited 6/17/16 by Hill Chang

% This script examines all the .mat files in a single folder, created by
% merge_nmat_files_3
% Note: Thie script assumes that each .mat file contains only one whisking
% bout

% Detect when whisking starts or stops based on angle (standard deviation
% maybe?)
% Calculate:
    % Average duration
    % Average frequency
    % Average deflection

clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);



for i=1:count; % Loop for every .mat file
    i % Declare which file this is
    angles = importdata(matfiles(i).name);

    
    % Find whisk start
    whiskStart = 0;
    for j=1:length(angles);
        if (abs(angles(j)-mean(angles))>1.5*std(angles) && ...
                abs(std(angles(j:j+150))/std(angles))>.5); % Whisk starts when angle deflection is more than 2 std from mean
            whiskStart = j;
            break;
        end
    end
    
    % Find whisk end
    whiskEnd = 0;
    for k=whiskStart:length(angles)-150;
        if (abs(std(angles(k:k+150))/std(angles))<.30); % Whisk ends when standard deviation of next 150 frames is less than 1.25*total std
            whiskEnd = k;
            break;
        end
        if (k == length(angles)-150);
            whiskEnd = k;
            break;
        end
    end
    
    % Find whisk duration
    duration = (whiskEnd - whiskStart)*2 % Duration of whisking bout in ms
    
    % Find average whisk frequency
    
    % Find maximum whisk frequency
   
    
    % Find average whisk protraction
    avg_amp=mean(angles)
    
    % Find averagae whisk retraction
   
    % Find maximum whisk protraction
    maxProtraction = max(angles)
    
    % Find maximum whisk retraction
    maxRetraction = min(angles(whiskStart:whiskEnd))
    
    % Plot angle data and mark whisk beginning/end
    subplot(count,1,i);
    plot(angles); hold on;
    line([whiskStart whiskStart],[-250 -150],'LineWidth',1,'LineStyle','-','Color','g'); hold on;
    line([whiskEnd whiskEnd],[-250 -150],'LineWidth',1,'LineStyle','-','Color','r');    
    axis([0 10000 -250 -150]);
    
    
end