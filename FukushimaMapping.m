clc;clearvars;clf;
%% Read Dataset 
Data = readtable("AirDoseRate.csv","Range","A1:E2644");
date_of_accident = datetime('11-03-2011 02:46:00 PM',"InputFormat","dd-MM-yyyy hh:mm:ss a");
Data.DayAfterAccident = days(Data.CorrectionBaseDate - date_of_accident);
%% Data visualisation
j=1;
tempdate = unique(datenum(Data.CorrectionBaseDate));
tarikh = datetime(tempdate, 'ConvertFrom', 'datenum', 'Format', 'dd-MM-yy'); 

fg1 = figure(1);
fg1.Name = "Fuksuhima air dose rate";
geobasemap satellite;

%FDNPP COORDINATE : (37.4211° N, 141.0328° E)
% wmmarker(37.4211,141.0328,'Description',"FDNPP",'Icon',"nuclearsymbol.png");

for i=1:numel(tarikh)
    geoscatter(Data(Data.CorrectionBaseDate== tarikh(i),:),"Latitude","Longitude","MarkerEdgeColor","b",Marker="o",MarkerFaceColor=[0 0.4470 0.7410]);
    hold on 
    pause(0.01)
end

title("Plotting radiation")
%input to enter in the map

lctvr = questdlg('Do you want to select specific coordinates', ...
	'Variable', ...
	'Yes','No','');

    switch lctvr
        case 'Yes'
            button = 1;
            [x,y] = deal([]);

             while button==1
    
                % get a new mouse position
                [xt,yt,button] = ginput(1);
                x = [x xt];
                y = [y yt];
    
             end
            f = msgbox("Operation Completed");
    case 'No'
        f = msgbox("Operation Completed");
    end

%% Interpolation Data by machine learning
rangeLat = x;
rangeLon = y;

numObservation = height(Data);
datatrain = Data(1:2114,["Latitude" "Longitude" "Value_microSv_hr_"]);
datatest = Data(2115:2643,["Latitude" "Longitude" "Value_microSv_hr_"]);
MdlTreeBagger = TreeBagger(180,datatrain,"Value_microSv_hr_", Method="regression" ,...
    OOBPrediction="on");
%% Model Evaluation 
datapred = predict(MdlTreeBagger,datatest);
RMSE = rmse(datapred,table2array(datatest(:,"Value_microSv_hr_")));
MAPE = mape(datapred,table2array(datatest(:,"Value_microSv_hr_")));
ccl = corrcoef(datapred,table2array(datatest(:,"Value_microSv_hr_")));
Rsquare = (ccl(1,2))^2;

datatointep = [rangeLat(1:numel(rangeLon)).',rangeLon.']; 
datapred2 = predict(MdlTreeBagger,datatointep);
newdata = [datatointep,datapred2];
newdata = array2table(newdata);
newdata.Properties.VariableNames = ["Latitude" "Longitude" "Value_microSv_hr"];

%% Display output manual prediction
fg1
geoscatter(newdata,"Latitude","Longitude","MarkerEdgeColor","r",Marker="*",MarkerFaceColor="r");
geobasemap satellite;

for i =1:numel(x)
    strt(i)= ("Point "+(i)+" ("+(x(i))+"°N , "+(y(i))+"°E ): "+(table2array(newdata(i,end)))+" microCurie/hr");
end

for i =2:numel(x)
    str(i-1) = compose(strt(i-1)+"\n\n"+strt(i));

    if i>2
      str(i-1) = compose(str(i-2)+"\n\n"+strt(i)); 
    end
end

f = msgbox(str(end),"Monitoring Radiation");

%% Ask for contour interpolation 
contq = questdlg('Do you want to interpolate by contour method', ...
	'Contour plot', ...
	'Yes','No','');

    switch contq 
        case 'Yes'
            datatointep = meshcon(Data);
            datapred2 = predict(MdlTreeBagger,datatointep);
            newdata = [datatointep,datapred2];
            newdata = array2table(newdata);
            newdata.Properties.VariableNames = ["Latitude" "Longitude" "Value_microSv_hr"];
            plotcon(newdata);

        case 'No'
            f = msgbox("Operation Completed");

    end

%% Local function
function datatointep = meshcon(Data)
    rangeLat = meshgrid(linspace(min(Data.Latitude),max(Data.Latitude),100));
    rangeLon = meshgrid(linspace(min(Data.Longitude),max(Data.Longitude),100));
    datatointep = [reshape(rangeLat,[],1),reshape(rangeLon.',[],1)]; 
end

function plotcon(newdata)
    figure(Name="Contour interpolation")
    %FDNPP COORDINATE : (37.4211° N, 141.0328° E)
    geoscatter(37.4211,141.0328,"MarkerEdgeColor","r",Marker="x",MarkerFaceColor="m")
    for i=1:height(newdata)
        if newdata.Value_microSv_hr(i)>3.5
            geoscatter(newdata(i,:),"Latitude","Longitude","MarkerEdgeColor","r",Marker="o",MarkerFaceColor="r");
            hold on
        elseif newdata.Value_microSv_hr(i)>0.75
            geoscatter(newdata(i,:),"Latitude","Longitude","MarkerEdgeColor","y",Marker="o",MarkerFaceColor="y");
            hold on
        elseif newdata.Value_microSv_hr(i)>0.4
            geoscatter(newdata(i,:),"Latitude","Longitude","MarkerEdgeColor","g",Marker="o",MarkerFaceColor="g");
            hold on
        else
            geoscatter(newdata(i,:),"Latitude","Longitude","MarkerEdgeColor","none",Marker="o",MarkerFaceColor="none");
            hold on
        end
    end

geobasemap satellite;

end