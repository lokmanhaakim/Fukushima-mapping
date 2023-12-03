function [lat2,lon2] = getCoordinates(lat1,lon1,d,bearing)
R=6371;

lat1 = deg2rad(lat1);
lon1 = deg2rad(lon1);
a = deg2rad(bearing);

lat2 = asin(sin(lat1)*cos(d/R)+(cos(lat1))*(sin(d/R)*cos(a)));
lon2 = lon1+atan2(sin(a) * sin(d/R) * cos(lat1),cos(d/R) - sin(lat1) * sin(lat2));

lat2 = rad2deg(lat2);
lon2 = rad2deg(lon2);

end