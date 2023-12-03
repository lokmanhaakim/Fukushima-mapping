%% Calculate Distance 
dist = questdlg('Do you want to calculate distance at any point?', ...
	'Calcculate distance', ...
	'Yes','No','');
d = 0;
i = 1;

switch dist 
        case 'Yes'
            distm = questdlg('What method?', ...
	                'Method', ...
	                'Ginput','Entered coordinates','');
            switch distm
                case 'Ginput'
                    prompt = {'Latitude : ';'Longitude : '};
                    titlebox = 'Distance between point';
                    cntre = str2double(inputdlg(prompt,"Distance between point"));
                    ploth = geoplot(cntre(1),cntre(2),Marker ="o",MarkerFaceColor=[0 0.4470 0.7410]);
                    geolimits([cntre(1)-5 cntre(1)+5],[cntre(2)-5 cntre(2)+5])

                    button = 1;
                    [xd,yd] = deal([]);
    
                    while button==1
                     
                     % get a new mouse position
                     [xdt,ydt,button] = ginput(1);
                     xd = [xd xdt];
                     yd = [yd ydt];
                     set(ploth,'XData',xd,'YData',yd)
                     

                     if numel(yd)==1
                           d(i) = 0;
                     else
                           i =i+1;
                           d(i) = lldistkm([xd(end),yd(end)] ,[xd(end-1),yd(end-1)]);
                     end

                     end
                    f = msgbox("Distance between selected point ("+1+" until "+(numel(xd))+") is "+sum(d)+"km");

                case  'Entered coordinates'
                   prompt = {'Starting Latitude:','Starting Longitude:','Ending Latitude:','Ending Longitude:'};
                   dlgtitle = "Calculate Distance";
                   coorinpt = inputdlg(prompt,dlgtitle); 
                   coorinpt = str2double(coorinpt);
                   xd= [coorinpt(1),coorinpt(3)];
                   yd= [coorinpt(2),coorinpt(4)];    
                   d = lldistkm([coorinpt(1),coorinpt(2)],[coorinpt(3),coorinpt(4)]);
                   f = msgbox("Distance : "+d+" km");

            end

        case 'No'
            f = msgbox("Operation Completed");
                
 end
%% Bearing 
for i = 1:(numel(xd)-1)
    bearing(i)= azimuth(xd(i),yd(i),xd(i+1),yd(i+1));
end

%% Local function
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