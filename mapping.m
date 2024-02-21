clc;clear;clf;
%% read geotable  
districtmap = readgeotable("gadm36_MYS_2.shp");
districtmap = removevars(districtmap,["GID_0" "NAME_0" "GID_1" "NL_NAME_1" "GID_2" "VARNAME_2" "NL_NAME_2" "TYPE_2" "CC_2"]);
districtmap.Properties.VariableNames = ["Shape" "State" "District" "District Type" "Code"];
%% read population
population = readtable("population_district.csv");
population = population(population.Status == "District",:);
population.Properties.VariableNames(3:end)= ["2000" "2010" "2020"];
population.Properties.VariableNames(1) = "District";
population.District = regexprep(population.District,'\(.*',')');
population.("2020") = str2double(population.("2020"));
%% Combine geotable and create map
for i = 1:numel(districtmap.District)
    [value,idx2] = min(editDistance(population.District,districtmap.District(i)));
    districtmap.Population(i) = population.("2020")(idx2);
end

clf;
figure(1)
geoplot(districtmap,"ColorVariable","Population")
cmap = flipud(autumn(height(districtmap)));
colormap(cmap)

colorbar
title("Population in Malaysia (2020)")
% test
%% Create poligon 
xrange = [-6.7,16.0];
yrange = [96.5 122.0];

hold on
ploth = geoplot(mean(xrange),mean(yrange),Marker ="o",MarkerFaceColor=[0 0.4470 0.7410]);
geolimits([-5 10],[98 120])

button = 1;
[x,y] = deal([]);

while button==1
    % get a new mouse position
    [xt,yt,button] = ginput(1);
    x = [x xt];
    y = [y yt];
    % update a plot handle
    set(ploth,'XData',x,'YData',y)
    
end

x = [x x(1)];
y = [y y(1)];
set(ploth,'XData',x,'YData',y)

%% Calculate distance 
ques = "";

while ques ~= "No"
    slctvr = questdlg('Select distance to predict', ...
	    'Calculate Distance', ...
	    'Total Distance','Specific Distance','');

    switch slctvr
        case 'Total Distance'
            for i = 2:numel(x)
                d(i) = lldistkm([x(i-1),y(i-1)],[x(i),y(i)]);
            end
            f = msgbox("Distance between point "+1+" until "+(numel(x))+" is "+sum(d)+"km");
        case 'Specific Distance'
            prompt = {'Select index for starting point (not reach index that have been chosen)';'Select index for starting point (not reach index that have been chosen)'};
            titlebox = "Distance between point";
            fieldsize = [numel(y); numel(y)];
            try
                output = str2double(inputdlg(prompt,titlebox));
                d = lldistkm([x(output(1)),y(output(1))],[x(output(2)),y(output(2))]);
                f = msgbox("Distance between point "+(output(1))+" and "+(output(2))+" is "+round(d,2)+"km");    
            catch
                pause(0.8);
                f = msgbox("The choose index exceed the maximum choosen coordinates");
        
            end       
    end
    pause(1.8);
    slctvr2 = questdlg('Do you want to calculate the distance again ?', ...
	    'Calculate distance', ...
	    'Yes','No','');

        switch slctvr2
            case 'Yes'
                ques = "";
            case 'No'
            ques = "No";
        end
end

f = msgbox("Operation Completed");

%% local function 

function [d1km d2km]=lldistkm(latlon1,latlon2)

radius=6371;
lat1=latlon1(1)*pi/180;
lat2=latlon2(1)*pi/180;
lon1=latlon1(2)*pi/180;
lon2=latlon2(2)*pi/180;
deltaLat=lat2-lat1;
deltaLon=lon2-lon1;
a=sin((deltaLat)/2)^2 + cos(lat1)*cos(lat2) * sin(deltaLon/2)^2;
c=2*atan2(sqrt(a),sqrt(1-a));
d1km=radius*c;    %Haversine distance
x=deltaLon*cos((lat1+lat2)/2);
y=deltaLat;
d2km=radius*sqrt(x*x + y*y); %Pythagoran distance
end