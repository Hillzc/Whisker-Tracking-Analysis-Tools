%% For Duration data

close all;
clear all;

% foldername = 'Margolis/mnt/margolisnas/Margolis Lab DATA/Summer Projects/Natural Whisking Analysis/DATA/stimulated/mouse 2 two fibers/whisker data';
% cd([foldername]);
cd(uigetdir);

filename = 'Mouse2 Duration Trials';

matfile = dir('*.mat');
angle = cell(length(matfile),2);
%freq =  [1,2,3,5,6,8,10,12,14,16,18,20,22,24,26,28,30,35,40,45,50];
%duration = [5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80];

total_sample_size = 1000;
plot_before_thePeak = 250;
plot_after_thePeak = total_sample_size-plot_before_thePeak;

for i = 1: length(matfile)
   load (matfile(i).name);
   f = sscanf(matfile(i).name, ['%d']);
   angle{i,1} = f; %f-5
   angle{i,2} = MovieInfo.AvgWhiskerPos;
    
end

%save(filename, angle);
 
x = tabulate([angle{:,1}]);   % to categorize the same frequency data
totalFreq = (x(find(x(:,2)),1:2));
%totalFreq = sort(totalFreq,1);
meanIntArr = cell(length(totalFreq),3);
stdArr = zeros(length(meanIntArr),1);
intensityCount = 1;

for k = 1:length(totalFreq)
        meanIntArr{k,1} = totalFreq(k,1);
        meanIntArr{k,2} = totalFreq(k,2);
end

mkdir('mean_data');
cd('mean_data');

figure(1);

for j = 1: length(angle) 
    
       if (j ==1)
           count =1;
       end
       
       fIndex =  find(cell2mat(meanIntArr(:,1))== angle{j,1},1);
         
         % for finding peaks, use the lower one instead
         %[maxval, ind] = findPeakVal(angle{j, 2}, 1.8);
       
       if (count == 1) 
           peakArr = zeros(meanIntArr{fIndex,2},1);
           peakMeanArr = zeros(meanIntArr{fIndex,2},total_sample_size);
           fCount = meanIntArr{fIndex,2};
           realCount = fCount;
       end
       
       if (size(angle{j,2},1)>1)
           array_end = length(angle{j,2});
           [maxval, ind] = max(angle{j,2}(400:700));
           % baseline = mean(angle{j,2}(1:ind(1)));     %for findPeakVal
           % data = angle{j,2}(ind(1):ind(1)+1100-1);
           ind = ind+400;
           baseline = mean(angle{j,2}(1:400));
           
           if (ind+plot_after_thePeak <= array_end)
               data = angle{j,2}(ind-plot_before_thePeak:ind+plot_after_thePeak-1);
               %data = angle{j,2}(ind-100:ind+800-1);
               maxdata = maxval -baseline;
               meandata = data-baseline;
              
           else
               meandata = NaN;
               maxdata = NaN;
           end
           
           peakMeanArr(count,:) = meandata;
           peakArr(count) = maxdata;
            
       else
           realCount = realCount-1;
           peakArr(count) = NaN;
           peakMeanArr(count,:) = NaN;
       end
       
        count = count+1;
        
       if (count == fCount+1)
          
           intensityCount = intensityCount+1;
           
           if(realCount>1)
               meanIntArr{fIndex,3} = nanmean(peakArr);
               meandata = nanmean(peakMeanArr);
               stdDur = nanstd(peakMeanArr);
               stdArr(fIndex) = nanstd(peakArr);
               figure(intensityCount); plotshaded(1:total_sample_size, [meandata+stdDur; meandata-stdDur],'b');
               hold on; plot(meandata,'r--'); xlabel('frames');ylabel('angle(change-baseline(0-400))');
               title(sprintf('Whisker deflection of %dmsec light stimulation \n averaged over %d trials', angle{j,1}, realCount));
               filename = sprintf('mean%dmsec.mat',angle{j,1});
               save(filename, 'peakMeanArr','peakArr','stdDur');
               clear peakMeanArr; hold off;
           else
               figure(intensityCount); plot(meandata, 'r--');
               xlabel('frames'); ylabel('angle(change-baseline(0-400))');
               title(sprintf('Whisker deflection of %dmsec light stimulation \n averaged over %d trials',angle{j,1}, realCount));
               meanIntArr{fIndex,3} = peakArr;
               stdArr(fIndex) = 0;
               filename = sprintf('mean%dmsec.mat',angle{j,1});
               save(filename, 'peakMeanArr','peakArr','stdDur');
               clear peakMeanArr;
           end
          
           figure(1);hold on; 
           errorbar(meanIntArr{fIndex,1}, meanIntArr{fIndex,3},stdArr(fIndex),'x');
%            filename = sprintf('mean%dmescDuration',meanIntArr{intensityCount,1});
%            save(filename, 'meanIntArr{intensityCount,3}','stdArr(intensityCount)');
             count = 1;
       end    
       
            
end

figure(1); xlabel('stimulation duration (msec)'); ylabel ('maximum angle (max-baseline)');

save('all','meanIntArr','stdArr');
 
