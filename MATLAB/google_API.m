%% SCRAPING GOOGLE DATA

%% Disclaimer
% This file is part of the matlab package for dynamic traffic assignments
% developed by the KULeuven.
%
% Copyright (C) 2016  Himpe Willem, Leuven, Belgium
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% More information at: http://www.mech.kuleuven.be/en/cib/traffic/downloads
% or contact: willem.himpe {@} kuleuven.be

%% Input parameters

%Text string with the start time (next whole minute)
start_time = datestr(ceil(now*1440)/1440);  %'27-Sep-2017 16:20:00'
%Text string with the end time (10 minutes later)
end_time = datestr(ceil(now*1440+10)/1440); %'29-Sep-2017 10:00:00'
%Interval in seconds
interval = 60*1;

%origin coordinates
origin = '50.844022, 4.732410';
%destination coordinates
destination = '50.869525, 4.476591';

%API key provided by google
key = '';

%temporary file to write data to
filename = ['Google_TT_Data_temp.xml'];

%% Construct the API

%setup the different parts of the API
txt_api='https://maps.googleapis.com/maps/api/distancematrix/xml?';
txt_origins=['origins=',origin];
txt_destinations=['destinations=',destination];
txt_key=['key=',key];

%additional parameters to get the current travel time
txt_model='traffic_model=';
txt_time='departure_time=';

%print the basic URL to the command window
api_TrafDat=[txt_api,txt_origins,'&',txt_destinations,'&',txt_key];
fprintf(['general api is: ',api_TrafDat]);

%% Setup the repeated extraction of data

total_measures=[];
t_start=datenum(start_time);
t_end=datenum(end_time);
warning('off','MATLAB:urlread:ReplacingSpaces')
fprintf(['\n start collecting Google Travel time']);
while true
    t_now = now;
	if t_now-t_start >= 0 && t_now-t_end <= 0
        %set the departure time
        txt_dep_time = [txt_time,num2str(floor(86400 * (now - datenum(1970,1,1,2,0,13))))];
        
        %compile the specific API request (with best guess travel time)
        api_TrafDat=[txt_api,txt_origins,'&',txt_destinations,'&',txt_model,'best_guess','&',txt_dep_time,'&',txt_key];
        %get the result from the API
        try
            urlwrite(api_TrafDat,filename);
            data = parseXML(filename);
            dur_cur = str2num(data.Children(8).Children(2).Children(8).Children(2).Children.Data);
        catch 
            dur_cur = -1;
        end
        %compile the specific API request (with optimistic travel time)
        api_TrafDat=[txt_api,txt_origins,'&',txt_destinations,'&',txt_model,'optimistic','&',txt_dep_time,'&',txt_key];
        %get the result from the API
        try
            urlwrite(api_TrafDat,filename);
            data = parseXML(filename);
            dur_opt = str2num(data.Children(8).Children(2).Children(8).Children(2).Children.Data);
        catch
            dur_opt = -1;
        end
        
        %compile the specific API request (with pessimistic guess travel time)
        api_TrafDat=[txt_api,txt_origins,'&',txt_destinations,'&',txt_model,'pessimistic','&',txt_dep_time,'&',txt_key];
        %get the result from the API
        try
            urlwrite(api_TrafDat,filename);
            data = parseXML(filename);
            dur_pes = str2num(data.Children(8).Children(2).Children(8).Children(2).Children.Data);
        catch
            dur_pes = -1;
        end
        
        %write the data to a matlab structure
        measurements = [t_now,dur_cur,dur_opt,dur_pes];  
        total_measures = [total_measures;measurements];
        
    elseif now-t_end >= 0
        break;
    end
    
    %time out
    if t_now-t_start < 0
        time_pause = 86400*(t_start-now);
        if time_pause>0
            pause(time_pause);
        end
    else
        time_pause = interval-86400*(now-t_now);
        if time_pause>0
            pause(time_pause);
        end
    end
end

%% Visualize the outcome
figure;
hold on;
plot(total_measures(:,1),total_measures(:,4)/60,'.-r');
plot(total_measures(:,1),total_measures(:,2)/60,'.-b');
plot(total_measures(:,1),total_measures(:,3)/60,'.-g');
hold off;
datetick('x');
xlabel('time');
ylabel('travel time [min]');
legend('Pessimistic Estimate','Best Guess','Optimistic Estimate')
title('Google API')