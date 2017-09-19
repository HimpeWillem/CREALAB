function Load_Location_Data
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

%
fprintf('collecting data');
miv_config = parseXML('http://miv.opendata.belfla.be/miv/configuratie/xml');
fprintf(' done \n');

unique_id = zeros((size(miv_config.Children,2)-3)/2,1);
beschrijvende_id = cell((size(miv_config.Children,2)-3)/2,1);
volledige_naam = cell((size(miv_config.Children,2)-3)/2,1);
Ident_8 =  cell((size(miv_config.Children,2)-3)/2,1);
lve_nr = zeros((size(miv_config.Children,2)-3)/2,1);
Kmp_Rsys = zeros((size(miv_config.Children,2)-3)/2,1);
Rijstrook = cell((size(miv_config.Children,2)-3)/2,1); 
X_EPSG_31370 = zeros((size(miv_config.Children,2)-3)/2,1); 
Y_EPSG_31370 = zeros((size(miv_config.Children,2)-3)/2,1);
Lon_EPSG_4326 = zeros((size(miv_config.Children,2)-3)/2,1);
Lat_EPSG_4326 = zeros((size(miv_config.Children,2)-3)/2,1);


it=0;
fprintf('processing data');
for i=4:2:size(miv_config.Children,2)
    it=it+1;
    unique_id(it) = str2num(miv_config.Children(i).Attributes.Value);
    beschrijvende_id(it) = {miv_config.Children(i).Children(2).Children.Data};
    if isempty(miv_config.Children(i).Children(4).Children)
        volledige_naam(it) = {''};
    else        
        volledige_naam(it) = {miv_config.Children(i).Children(4).Children.Data};
    end
    Ident_8(it) = {miv_config.Children(i).Children(6).Children.Data};
    lve_nr(it) = str2num(miv_config.Children(i).Children(8).Children.Data);
    if isempty(miv_config.Children(i).Children(10).Children)
        Kmp_Rsys(it) = 0;
    else
        Kmp_Rsys_temp = str2num(miv_config.Children(i).Children(10).Children.Data);
        if length(Kmp_Rsys_temp)==1
            Kmp_Rsys(it) = Kmp_Rsys_temp;
        else
            Kmp_Rsys(it) = Kmp_Rsys_temp(1)+Kmp_Rsys_temp(2)/(10^ceil(log10(Kmp_Rsys_temp(2))));
        end
    end
    Rijstrook(it) = {miv_config.Children(i).Children(12).Children.Data};
    X_EPSG_31370_temp = str2num(miv_config.Children(i).Children(14).Children.Data);
    X_EPSG_31370(it) = X_EPSG_31370_temp(1)+X_EPSG_31370_temp(2)/(10^ceil(log10(X_EPSG_31370_temp(2))));
    Y_EPSG_31370_temp = str2num(miv_config.Children(i).Children(16).Children.Data);
    Y_EPSG_31370(it) = Y_EPSG_31370_temp(1)+Y_EPSG_31370_temp(2)/(10^ceil(log10(Y_EPSG_31370_temp(2))));
    Lon_EPSG_4326_temp = str2num(miv_config.Children(i).Children(18).Children.Data);
    Lon_EPSG_4326(it) = Lon_EPSG_4326_temp(1)+Lon_EPSG_4326_temp(2)/(10^ceil(log10(Lon_EPSG_4326_temp(2))));
    Lat_EPSG_4326_temp = str2num(miv_config.Children(i).Children(20).Children.Data);
    Lat_EPSG_4326(it) = Lat_EPSG_4326_temp(1)+Lat_EPSG_4326_temp(2)/(10^ceil(log10(Lat_EPSG_4326_temp(2))));
    
    fprintf('.');
    if rem(it,3)==0
        for j=1:3
            fprintf('\b');
        end
    end
end
fprintf(' done \n');

total_config=table(unique_id,beschrijvende_id,volledige_naam,Ident_8,lve_nr,Kmp_Rsys,Rijstrook,X_EPSG_31370,Y_EPSG_31370,Lon_EPSG_4326,Lat_EPSG_4326);

doc_name = ['Configuration_',datestr(clock,'ddmmyyyy_HHMMSS'),'.csv'];
fprintf(['writing table to ',doc_name]);
writetable(total_config,doc_name);
fprintf(' done \n');
