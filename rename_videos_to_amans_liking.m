clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.avi');
movies = dir(filePattern);
count = length(movies);

loop = 1;
led = 'R';
duration = 0;

for f = 1:count;
    movieName = movies(f,1).name
    
    switch (mod(f,10))
        case 1
            duration = 5;
        case 2
            duration = 5;
        case 3
            duration = 50;
        case 4
            duration = 50;
        case 5
            duration = 100;
        case 6
            duration = 100;
        case 7
            duration = 500;
        case 8
            duration = 500;
        case 9
            duration = 1000;
        case 0
            duration = 1000;
    end
    
    if (loop <= 8)
        if (led == 'P')
            led = 'R';
        else
            led = 'P';
        end
        
        movefile(movieName, [num2str(duration) 'ms_' led num2str(loop) '.avi'])
        
        if (led == 'R' && duration == 1000)
            loop = loop+1;
        end
        
    end

end