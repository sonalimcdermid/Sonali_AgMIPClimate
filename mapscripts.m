%%%% This is a set of mini-scripts designed to produce maps of baseline
%%%% yields for specific crops, plausibility checks, and slopes. The
%%%% "acr_c3mpinfo.m" file is to be used in conjunction with this script,
%%%% and can help further explain the values to enter. These include:
%     where:
%     request = requested array (  string, one of:
%       siteref      = C3MP new site reference number
%       sitepis      = C3MP experiment PIs
%       sitelat      = C3MP site latitude
%       sitelon      = C3MP site longitude
%       siteelev     = C3MP site elevation
%       sitecode     = C3MP site code
%       siteloc      = C3MP site location
%       sitecountry  = C3MP site country
%       sitecropnum  = C3MP site crop number
%       cropnumkey   = C3MP site crop number key, such that
%         1 'Bambara groundnut'
%         2 'Barley'
%         3 'Canola'
%         4 'Chickpea'
%         5 'Cotton'
%         6 'Grapevine'
%         7 'Lentil'
%         8 'Maize'
%         9 'Millet' 
%         10 'Pasture'
%         11'Peanut' 
%         12'Potato'
%         13 'Rice' 
%         14 'Rye' 
%         15 'Sorghum'
%         16 'Soybeans'
%         17 'Sugarcane' 
%         18 'Wheat' 
%         19 'Wheat/Maize'
%       siteplantmm  = C3MP site planting month
%       siteharvmm   = C3MP site harvest month
%       sitecropplus = C3MP site additional crop information
%       siteirr      = Is C3MP Site irrigated (1=yes, 0=no, 2=unknown)
%       sitenit      = C3MP site nitrogen application (kg/ha)
%       sitesplat    = C3MP site soil profile latitude
%       sitesplon    = C3MP site soil profile longitude
%       sitewdata    = C3MP site weather data source
%       sitecmodel   = C3MP site crop model and version
%       sitecmodcmp  = C3MP site crop model component
%       sitecult     = C3MP site cultivar
%       stestT       = C3MP sensitivity test temperature change
%       stestP       = C3MP sensitivity test precipitation change
%       stestCO2     = C3MP sensitivity test CO2 concentrations
%       example call: 
%       sitelat = acr_c3mpinfo('sitelat');

%%%% Usage Notes
% To plot, first check that the "cmaplims" are displaying the range you
% want, and make sure the appropriate colorbar is being used. To do this,
% open the acr_pcolormapr2.m routine, and adjust the section stating:
% 'load /Users/sps246/Research/C3MP/AnalysisPrograms/colormaps/cmapprecip.mat
% colormap(cmapprecip)'
% Colormaps are located in the AnalysisPrograms/colomaps directory.
% I used cmapprecip.mat for displaying yield changes, and cmapagpos.mat for
% displaying absolute yields


cd /Users/sps246/Research/C3MP/Results

% Load these options and files
darkgreen = hsv2rgb([0.3,1,0.7]);
aqua = [0 255 200]./255*0.7;
orange = [255 155 0]./255;
purple = hsv2rgb([0.8,0.6,0.8]);
pink = hsv2rgb([0.8,0.3,1]);
gray = [1 1 1]*0.7;
darkyellow = hsv2rgb([0.15,1,0.7]);
darkred = hsv2rgb([1,1,0.5]);

AgMIPfinelat = importdata('/Users/sps246/Research/C3MP/AgMERRA_data/AgMIPfinelat.mat');
AgMIPfinelon = importdata('/Users/sps246/Research/C3MP/AgMERRA_data/AgMIPfinelon.mat');
AgMIPfinelon(find(AgMIPfinelon>180)) = AgMIPfinelon(find(AgMIPfinelon>180))-360;

%% Get C3MP Information
stnlat = acr_c3mpinfo('sitelat');
stnlon = acr_c3mpinfo('sitelon');
siteref = acr_c3mpinfo('siteref');
sitecropnum = acr_c3mpinfo('sitecropnum'); % 8 = maize, 10 = peanut
cropnumkey = acr_c3mpinfo('cropnumkey');
sitecountry = acr_c3mpinfo('sitecountry');
siteirr = acr_c3mpinfo('siteirr');
siteloc = acr_c3mpinfo('siteloc');
sitepis = acr_c3mpinfo('sitepis');


%% Slope for T, P, and CO2 in that order
slope = importdata('/Users/sps246/Research/C3MP/Results/AnalysisOutput/slope.mat');
slope(:,2) = slope(:,2)*100;  %% corrects temporary units problem
cmaplims = [-10 10];


figure(1);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Rainfed Peanut T Slope (% yield change per ^oC increase)');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  %if(~strcmp(sitepis{ii},'Richard Goldberg')),
  if(sitecropnum(ii)==8),
      if(siteirr(ii)==0),
    point=plotm(stnlat(ii),stnlon(ii),'ko');
    cmaploc = round((slope(siteref(ii),1)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
    if(cmaploc<1)
      cmaploc = 1;
    end;
    if(cmaploc>length(cmap))
      cmaploc = length(cmap);
    end;  
   set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
      set(point,'markerfacecolor',cmap(cmaploc,:));
    end;
  end;
end;
figure(2);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Peanut T slopes (% yield change per ^oC increase)');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(~strcmp(sitepis{ii},'Richard Goldberg')),
    if(sitecropnum(ii)==8),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((slope(siteref(ii),1)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
      if (~isnan(cmaploc))
        set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
  end;
end;

figure(11);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'All Sites P Slope (% yield change per 10% precip increase)');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(~strcmp(sitepis{ii},'Richard Goldberg')),
    if(siteirr(ii)==0),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((slope(siteref(ii),2)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
       cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
      if (~isnan(cmaploc))
        set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
   end;
  end;
end;
figure(12);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Peanut P slopes (% yield change per 10% precip increase)');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(sitecropnum(ii)==10),
    if(~strcmp(sitepis{ii},'Richard Goldberg')),
      if(siteirr(ii)==0),
        point=plotm(stnlat(ii),stnlon(ii),'ko');
        cmaploc = round((slope(siteref(ii),2)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
        if(cmaploc<1)
          cmaploc = 1;
        end;
        if(cmaploc>length(cmap))
          cmaploc = length(cmap);
        end;  
        set(point,'markeredgecolor','none');
        if (~isnan(cmaploc))
          set(point,'markerfacecolor',cmap(cmaploc,:));
        end;
      end;
    end;
  end;
end;

figure(31);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'All Sites CO2 Slope (% yield change per 100ppm CO2 increase)');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(~strcmp(sitepis{ii},'Richard Goldberg')),
    point=plotm(stnlat(ii),stnlon(ii),'ko');
    cmaploc = round((slope(siteref(ii),3)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
    if(cmaploc<1)
      cmaploc = 1;
    end;
    if(cmaploc>length(cmap))
      cmaploc = length(cmap);
    end;  
    set(point,'markeredgecolor','none');
    if (~isnan(cmaploc))
      set(point,'markerfacecolor',cmap(cmaploc,:));
    end;
  end;
end;
figure(32);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Peanut CO2 slopes (% yield change per 100ppm CO2 increase)');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(sitecropnum(ii)==10),
    if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((slope(siteref(ii),3)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
  end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plausibility tests
plausible = importdata('/Users/sps246/Research/C3MP/Results/AnalysisOutput/plausible.mat');
%check #1: calculate emulator value (% yield change) for 
%          deltaP=0, CO2=360ppm, and deltaT=+1 
%check #2: calculate emulator value (% yield change) for
%          deltaP=-25%, deltaT=0, CO2=360
%check #3: calcualte emulator value (% yield change) for deltaP
%          deltaP=0%, deltaT=0, CO2=700
%check #4: calculate mean yield from csv file test #43
%          deltaT = 0.5, deltaP = -7%; [CO2] = 537ppm

cmaplims = [-30 30];

figure(101);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'All crops %yield change with +1^oC');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
%  if(sitecropnum(ii)==15),
    if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((100*plausible(siteref(ii),1)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
%  end;
end;
figure(102);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'All crops %yield change with -25% precip');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
%  if(sitecropnum(ii)==15),
    if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((100*plausible(siteref(ii),2)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
%  end;
end;
figure(103);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'All crops %yield change with 700 ppm [CO_2]');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
%  if(sitecropnum(ii)==15),
    if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((100*plausible(siteref(ii),3)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
%  end;
end;

cmaplims = [0 10];
figure(104);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Wheat Yields near baseline conditions');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(sitecropnum(ii)==15),
    if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((plausible(siteref(ii),4)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
  end;
end;



%Australian results and French result seem to be reported in tons/ha
%rather than kg/ha



%% r-squared correlations and rmse (as percentage of baseline)
rsq = importdata('/Users/sps246/Research/C3MP/Results/AnalysisOutput/rsq.mat');
rmse = importdata('/Users/sps246/Research/C3MP/Results/AnalysisOutput/rmse.mat');


cmaplims = [0 1];

figure(1001);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'R^2 correlations between emulator and sensitivity tests');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
%  if(sitecropnum(ii)==15),
    if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((rsq(siteref(ii),1)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
%  end;
end;

cmaplims = [0 20];
figure(1100);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Root-mean-squared Error of emulator compared to sensitivity tests (as %baseline yield)');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
%  if(sitecropnum(ii)==15),
    if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((100*rmse(siteref(ii),1)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
%  end;
end;


thisgcm = 'ACCESS1-0';
thisrcp = 'rcp85';
futdecs = [2010 2039];
outname = 'EQAF';
for thismm=1:12,
  acr_agmip150_CONUS(thismm,thisgcm,thisrcp,futdecs,outname);
end;

thisgcm = 'CSIRO-Mk3-6-0';
thisrcp = 'rcp85';
futdecs = [2010 2039];
outname = 'EQGF';
for thismm=1:12,
  acr_agmip150_CONUS(thismm,thisgcm,thisrcp,futdecs,outname);
end;


%%%%%%%%%%%%%%% Plausible maps for Alex %%%%%%%%%%%


figure(101);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Irrigated Maize %yield change with +1^oC');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(sitecropnum(ii)==8),
      if(siteirr(ii)==1),
    %if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((plausible(siteref(ii),2)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
  end;
%end;
end


figure(101);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Rainfed Maize %yield change with +4^oC');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(sitecropnum(ii)==8),
      if(siteirr(ii)==0),
    %if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((plausible(siteref(ii),1)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
  end;
%end;
end

 
figure(101);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Rainfed Maize %yield change with -25% precip');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(sitecropnum(ii)==8),
      if(siteirr(ii)==0),
    %if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((plausible(siteref(ii),3)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
  end;
%end;
end

 
figure(101);
acr_pcolormapr2(AgMIPfinelat*NaN,AgMIPfinelat,AgMIPfinelon,cmaplims,'Baseline Mean Yield for Rainfed Wheat');
hold on
cmap = colormap;
caxis(cmaplims);
for ii=1:length(siteref),
  if(sitecropnum(ii)==15),
      if(siteirr(ii)==0),
    %if(~strcmp(sitepis{ii},'Richard Goldberg')),
      point=plotm(stnlat(ii),stnlon(ii),'ko');
      cmaploc = round((plausible(siteref(ii),4)-cmaplims(1))/(cmaplims(2)-cmaplims(1))*length(cmap));
      if(cmaploc<1)
        cmaploc = 1;
      end;
      if(cmaploc>length(cmap))
        cmaploc = length(cmap);
      end;  
      set(point,'markeredgecolor','none');
     if (~isnan(cmaploc))
         set(point,'markerfacecolor',cmap(cmaploc,:));
      end;
    end;
  end;
%end;
end