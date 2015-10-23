%			acr_agmip300
%
%  This script analyzes C3MP output for any location given a 
%  standardized input file based upon the reporting template.
%
%				author: Alex Ruane and Sonali McDermid
%                                       alexander.c.@nasa.gov
%				date:	04/04/13
%               Edited: Sonali McDermid
%               date: 09/13/2013
%
%
% Orignally: function acr_agmip300(contactname,experiment)
%
% This version now includes a loop through the experiments contributed to C3MP and standardized csv filenames. 

%function acr_agmip300(contactname)
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath /Users/sonalimcdermid/Documents/NPPWork/C3MP/AnalysisPrograms
darkgreen = hsv2rgb([0.3,1,0.5]);
brown = hsv2rgb([0.3,1,0.5]);
orange = [255 138 0]./255;
purple = hsv2rgb([0.8,0.6,0.8]);
pink = hsv2rgb([0.8,0.3,1]);
gray = [1 1 1]*0.7;
darkyellow = hsv2rgb([0.15,1,0.7]);
darkred = hsv2rgb([1,1,0.5]);
load /Users/sonalimcdermid/Documents/NPPWork/C3MP/AnalysisPrograms/colormaps/cmapprecip.mat
load /Users/sonalimcdermid/Documents/NPPWork/C3MP/AnalysisPrograms/colormaps/cmapprecip20.mat
load /Users/sonalimcdermid/Documents/NPPWork/C3MP/AnalysisPrograms/colormaps/cmapnegpos.mat
load /Users/sonalimcdermid/Documents/NPPWork/C3MP/AnalysisPrograms/colormaps/cmapnegpos20.mat

%% Begin Debug
%contactname = 'LeeByunWoo';
%experiment = '004';
%% End Debug


cd /Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/csv/

% List all the experiment .csv files contributed by the same author name
% filelist = dir([contactname '*']);

% For Nick's standardized csv filenames
filelist = dir(['*.csv']);
numfiles = length(filelist);

% Pre-Allocate analysis arrays, rows here specified as # of contributed
% experiments
RMSE = zeros(numfiles,1);
rsq = zeros(numfiles,1);
plause = zeros(numfiles,5);
slpe = zeros(numfiles,3);

for d = 1:numfiles
    filename = filelist(d).name;
    % Extract just the filename for labeling of figures (no extension)
    [PATHSTR,NAME,EXT] = fileparts(filename);
    % Import the data
    yield = importdata([filename]);
yield = yield';
yield(yield == 0) = 0.0000001;

f=figure('units','inches','pos',[.3,.3,7.9,12],'paperpos', ...
    [.3,.3,7.9,12],'paperor','portrait');

subplot(3,1,1);
plot(1980:2009,yield(58,1:30));
title('Sensitivity Test #58; deltaT = -0.2 degrees, deltaP = 11%, [CO_2]=475ppm');

subplot(3,1,2);
plot(1980:2009,yield(:,1:30));
title('All Sensitivity Tests');

%subplot(3,1,3);
%boxplot(yield(:,1:30));
%title('All Sensitivity Tests');

%subplot(3,1,3);
%boxplot((yield(:,1:30))');
%title('All Sensitivity Tests');

hyper = importdata('/Users/sonalimcdermid/Documents/NPPWork/C3MP/AnalysisPrograms/C3MPhyper99.mat');



acr_nancorr2(mean(yield(:,:),2),hyper(:,1));
acr_nancorr2(mean(yield(:,:),2),hyper(:,3));
acr_nancorr2(mean(yield(:,:),2),hyper(:,4));

%%%%%% Set missing values appropriately
yield(yield==-99) = NaN;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Fit emulator to mean yields
tseries = mean(yield,2);

%% Set series for emulator
tt1 = [hyper(:,1)];     %% temperature
tt2 = [hyper(:,3)];     %% precip factor
tt3 = [hyper(:,4)];     %% CO2
tt4 = tt1.*tt2;         %% TxP
tt5 = tt1.*tt3;         %% TxCO2
tt6 = tt2.*tt3;         %% PxCO2
tt7 = tt1.*tt2.*tt3;    %% TxPxCO2
model1 = [1 2];         %% quadratic for temperature
model2 = [1 2];         %% quadratic for P
model3 = [1 2];         %% quadratic for CO2
model4 = [1];           %% linear for all cross terms
model5 = [1];
model6 = [1];
model7 = [1];
nmod1 = length(model1);
nmod2 = length(model2);
nmod3 = length(model3);
nmod4 = length(model4);
nmod5 = length(model5);
nmod6 = length(model6);
nmod7 = length(model6);


[construct,const,amp] = acr_poly7((tseries(:))',tt1,tt2,tt3,tt4,tt5,tt6,tt7,model1,model2,model3,model4,model5,model6,model7);

%% Spot Checks
subplot(3,1,3);
plot(tseries(:));
hold on
plot(construct(:),'Color',orange);
xlabel('C3MP Sensitivity test');
ylabel('1980-2009 Mean Yield');
title('Emulator fit check');

% ------------------------------------------------------------------------
% Analysis of emulator RMSE. Alex had asked for values wrt to baseline, which we're
% taking as test #43 from our discussion

 base43 = mean(yield(43,1:30));
 tseriesb = ((tseries(:)-base43)./base43)*100;
 constructb = ((construct(:)-base43)./base43)*100;
 
 % NOTE: Alex had reconsidered and wanted instead to use C3MPemu(6,11,2), which is no
 % change in any variables, instead of base43. For now (10/22/2013) we will
 % use base43, and change this after global workshop when we've decided
 % formally
 
RMSE(d) = sqrt(mean((tseriesb(:) - constructb(:)).^2));

rmsename = ['rmse.mat']; % Save RMSE above
save(rmsename, 'RMSE');
movefile(rmsename, '/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/');

% ------------------------------------------------------------------------
% Analysis of emulator correlation. 

rsq(d) = (corr2(tseries(:),construct(:)))^2;

rsqname = ['rsq.mat']; % Save rsq above
save(rsqname, 'rsq');
movefile(rsqname, '/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/');

%% Set uncertainty space
TT=-1:0.2:8;
PP=0.5:0.05:1.5;
CO2 = 330:30:900;

C3MPemu = ones(length(TT),length(PP),length(CO2))*NaN;
%%%%%% Build emulator for yield
for thisT=1:length(TT),
  for thisP=1:length(PP),
    for thisCO2=1:length(CO2),
      tt1 = TT(thisT);
      tt2 = PP(thisP);
      tt3 = CO2(thisCO2);
      tt4 = tt1*tt2;
      tt5 = tt1*tt3;
      tt6 = tt2*tt3;
      tt7 = tt1*tt2*tt3;
      C3MPemu(thisT,thisP,thisCO2) = const;
      for ii=1:nmod1,
        C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + squeeze(amp(ii)*(tt1.^real(model1(ii))));
      end;
      for ii=1:nmod2,
        C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + squeeze(amp(ii+nmod1)*(tt2.^real(model2(ii))));
      end;
      for ii=1:nmod3,
        C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + squeeze(amp(ii+nmod1+nmod2)*(tt3.^real(model3(ii))));
      end;
      for ii=1:nmod4,
        C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + squeeze(amp(ii+nmod1+nmod2+nmod3)*(tt4.^real(model4(ii))));
      end;
      for ii=1:nmod5,
        C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4)*(tt5.^real(model5(ii))));
      end;
      for ii=1:nmod6,
        C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4+nmod5)*(tt6.^real(model6(ii))));
      end;
      for ii=1:nmod7,
        C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4+nmod5+nmod6)*(tt7.^real(model7(ii))));
      end;
    end;
  end;
end;


%%% Spot Checks
%figure(10000);
%plot(tseries(:))
%hold on
%for ii=1:length(hyper),
%  emutest(ii) = C3MPemu(dsearchn(TT',hyper(ii,1)),dsearchn(PP',hyper(ii,3)),dsearchn(CO2',hyper(ii,4)));
%end;
%plot(emutest,'m');
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Revise for plotting
PP=-50:5:50;
cmaplims = [0 7000];
cint = 0:500:7000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Cross sections
%% Revise for plotting
PP=-50:5:50;
cmaplims = [-100 100];
cint = -100:10:100;
thisirr = 1;
thisloc = 2;
thisclim = 1;

figure(101); colormap(cmapprecip20);
contourf(PP,CO2,((squeeze(C3MPemu(6,:,:))/C3MPemu(6,11,2))'-1)*100,cint);
xlabel('% Change in Precipitation');
ylabel('Carbon Dioxide Concentration');
title('Cross-Section at Zero Temperature Change');
caxis(cmaplims);

figure(201); colormap(cmapprecip20);
contourf(TT,CO2,((squeeze(C3MPemu(:,11,:))/C3MPemu(6,11,2))'-1)*100,cint);
xlabel('Change in Temperature');
ylabel('Carbon Dioxide Concentration');
title('Cross-Section at Zero Precipitation Change');
caxis(cmaplims);

figure(301); colormap(cmapprecip20);
contourf(TT,PP,((squeeze(C3MPemu(:,:,2))/C3MPemu(6,11,2))'-1)*100,cint);
xlabel('Change in Temperature');
ylabel('% Change in Precipitation');
title('Cross-Section at Baseline Carbon Dioxide Concentration (360ppm)');
caxis(cmaplims);

% print(101,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/CrossT_' NAME]);
% print(201,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/CrossP_' NAME]);
% print(301,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/CrossCO2_' NAME]);

%mkdir(['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/' NAME]);
print(101,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/' NAME 'CrossT_']);
print(201,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/' NAME 'CrossP_']);
print(301,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/' NAME 'CrossCO2_']);

%normC3MPemu(:,:,:,thisclim,thisirr,thisloc) = ((C3MPemu(:,:,:,thisclim,thisirr,thisloc))/C3MPemu(6,11,2,thisclim,thisirr,thisloc)-1)*100;

normC3MPemu(:,:,:) = ((C3MPemu(:,:,:))/C3MPemu(6,11,2)-1)*100;
vecname = [ NAME '.mat' ];
save(vecname,'normC3MPemu');
movefile(vecname,'/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/Response_diff/');

% ------------------------------------------------------------------------
% Analysis of emulator plausibility. Can query C3MPemu array to find
% emulated yield results for three checks. 
%%Check 1: delT = 4, delP = 0, CO2 = 360. Corresponds to indices (26,11,2)
%%Check 2: delT = 1, delP = 0, CO2 = 360. Corresponds to indices (11,11,2)
%%Check 3: delT = 0, delP = -25, CO2 = 360. Corresponds to indices (6,6,2)
%%Check 4: delT = 0, delP = 0, CO2 = 720. Corresponds to indices (6,11,14)
%%Check 5: Yield results from test #43 from csv file


plaus1 = ((C3MPemu(26,11,2)-C3MPemu(6,11,2))/C3MPemu(6,11,2))*100;
plaus2 = ((C3MPemu(11,11,2)-C3MPemu(6,11,2))/C3MPemu(6,11,2))*100;
plaus3 = ((C3MPemu(6,6,2)-C3MPemu(6,11,2))/C3MPemu(6,11,2))*100;
plaus4 = ((C3MPemu(6,11,14)-C3MPemu(6,11,2))/C3MPemu(6,11,2))*100;
plaus5 = C3MPemu(6,11,2);
plause(d,:) = [plaus1 plaus2 plaus3 plaus4 plaus5];

plausname = ['plausible.mat']; % Save plause
save(plausname, 'plause');
movefile(plausname, '/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/');

% ------------------------------------------------------------------------
% Analysis of slopes. Calculate slopes across "current" climate, so
% delT = 0 (index = 6), delP = 0 (index = 11), and CO2 = 360 (index = 2)

dydt = (C3MPemu(7,11,2)-C3MPemu(5,11,2))/(TT(7)-TT(5));
dydt = dydt/C3MPemu(6,11,2)*100; % To express relative yield change
dydp = (C3MPemu(6,12,2)-C3MPemu(6,10,2))/(PP(12)-PP(10));
dydp = dydp/C3MPemu(6,11,2)*100/10; % To express relative yield change
dydco2 = (C3MPemu(6,11,3)-C3MPemu(6,11,1))/(CO2(3)-CO2(1));
dydco2 = dydco2/C3MPemu(6,11,2)*100*100; % To express relative yield change
slpe(d,:) = [dydt dydp dydco2]; 

slpname = ['slope.mat']; % Save slpe above
save(slpname, 'slpe');
movefile(slpname, '/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Fit emulator to coefficient of variation of yields

tseriescv = (std(permute(yield,[2 1])))'./mean(yield,2);

tt1 = [hyper(:,1)];
tt2 = [hyper(:,3)];
tt3 = [hyper(:,4)];
tt4 = tt1.*tt2;
tt5 = tt1.*tt3;
tt6 = tt2.*tt3;
tt7 = tt1.*tt2.*tt3;
model1 = [1 2];
model2 = [1 2];
model3 = [1 2];
model4 = [1];
model5 = [1];
model6 = [1];
model7 = [1];
nmod1 = length(model1);
nmod2 = length(model2);
nmod3 = length(model3);
nmod4 = length(model4);
nmod5 = length(model5);
nmod6 = length(model6);
nmod7 = length(model6);

[constructcv,constcv,ampcv] = acr_poly7((tseriescv(:))',tt1,tt2,tt3,tt4,tt5,tt6,tt7,model1,model2,model3,model4,model5,model6,model7);

%% Spot Checks
figure(3);
plot(tseriescv)
hold on
plot(constructcv,'m');


%% Set uncertainty space
TT=-1:0.2:8;
PP=0.5:0.05:1.5;
CO2 = 330:30:900;

C3MPemucv = ones(length(TT),length(PP),length(CO2))*NaN;
%%%%%% Build emulator for yield
for thisT=1:length(TT),
  for thisP=1:length(PP),
    for thisCO2=1:length(CO2),
      tt1 = TT(thisT);
      tt2 = PP(thisP);
      tt3 = CO2(thisCO2);
      tt4 = tt1*tt2;
      tt5 = tt1*tt3;
      tt6 = tt2*tt3;
      tt7 = tt1*tt2*tt3;
      C3MPemucv(thisT,thisP,thisCO2) = constcv;
      for ii=1:nmod1,
        C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + squeeze(ampcv(ii)*(tt1.^real(model1(ii))));
      end;
      for ii=1:nmod2,
        C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + squeeze(ampcv(ii+nmod1)*(tt2.^real(model2(ii))));
      end;
      for ii=1:nmod3,
        C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + squeeze(ampcv(ii+nmod1+nmod2)*(tt3.^real(model3(ii))));
      end;
      for ii=1:nmod4,
        C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + squeeze(ampcv(ii+nmod1+nmod2+nmod3)*(tt4.^real(model4(ii))));
      end;
      for ii=1:nmod5,
        C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + squeeze(ampcv(ii+nmod1+nmod2+nmod3+nmod4)*(tt5.^real(model5(ii))));
      end;
      for ii=1:nmod6,
        C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + squeeze(ampcv(ii+nmod1+nmod2+nmod3+nmod4+nmod5)*(tt6.^real(model6(ii))));
      end;
      for ii=1:nmod7,
        C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + squeeze(ampcv(ii+nmod1+nmod2+nmod3+nmod4+nmod5+nmod6)*(tt7.^real(model7(ii))));
      end;
    end;
  end;
end;

%%%%%%%%%%%%%%%%%%%%
%% Revise for plotting
% PP=-50:5:50;
% cmaplims = [-50 50];
% cint=-50:5:50;
%%%%%%%%%%%%%%%%%%%%

%% Revise for plotting
% PP=-100:10:100;
% cmaplims = [-100 100];
% cint=-100:10:100;
 PP=-50:5:50;
 cmaplims = [-100 100];
cint=-100:10:100;
 %cmaplims = [-50 50];
 %cint=-50:5:50;
%%%%%%%%%%%%%%%%%%%%

figure(151); colormap(flipud(cmapprecip20));
contourf(PP,CO2,((squeeze(C3MPemucv(6,:,:)/C3MPemucv(6,11,2)-1)*100))',cint);
xlabel('% Change in Precipitation');
ylabel('Carbon Dioxide Concentration');
title('CV Cross-Section at Zero Temperature Change');
caxis(cmaplims);

figure(251); colormap(flipud(cmapprecip20));
contourf(TT,CO2,((squeeze(C3MPemucv(:,11,:)/C3MPemucv(6,11,2)-1)*100))',cint);
xlabel('Change in Temperature');
ylabel('Carbon Dioxide Concentration');
title('CV Cross-Section at Zero Precipitation Change');
caxis(cmaplims);

figure(351); colormap(flipud(cmapprecip20));
contourf(TT,PP,((squeeze(C3MPemucv(:,:,2)/C3MPemucv(6,11,2)-1)*100))',cint);
xlabel('Change in Temperature');
ylabel('% Change in Precipitation');
title('CV Cross-Section at Baseline Carbon Dioxide Concentration (360ppm)');
caxis(cmaplims);

print(151,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/' NAME 'CrossTcv_']);
print(251,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/' NAME 'CrossPcv_']);
print(351,'-depsc',['/Users/sonalimcdermid/Documents/NPPWork/C3MP/Results/AnalysisOutput/' NAME 'CrossCO2cv_']);

close all
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Generate uncertainties in C3MP space:
% % for thisloc=1:2,
% %   for thisirr=1:2,
% %     for thisclim=1:length(climlist),
%       normC3MPemu(:,:,:,thisclim,thisirr,thisloc) = ((C3MPemu(:,:,:,thisclim,thisirr,thisloc))/C3MPemu(6,11,2,thisclim,thisirr,thisloc)-1)*100;
%       normC3MPemucv(:,:,:,thisclim,thisirr,thisloc) = ((C3MPemucv(:,:,:,thisclim,thisirr,thisloc))/C3MPemucv(6,11,2,thisclim,thisirr,thisloc)-1)*100;
% %     end;
% %   end;
% % end;
% 
% save /Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/Results/AnalysisOutput/normC3MPemu normC3MPemu
% save /Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/Results/AnalysisOutput/normC3MPemucv normC3MPemucv
% 
% %stdC3MPemuClim = squeeze(std(permute(normC3MPemu,[4 1 2 3 5 6])));
% %stdC3MPemucvClim = squeeze(std(permute(normC3MPemu(:,:,:,1:10,:,:),[4 1 2 3 5 6])));
% diffC3MPemuClim = normC3MPemu(:,:,:,2,:,:)-normC3MPemu(:,:,:,1,:,:);
% diffC3MPemuIrr = normC3MPemu(:,:,:,:,1,:)-normC3MPemu(:,:,:,:,2,:);
% diffC3MPemuLoc = normC3MPemu(:,:,:,:,:,2)-normC3MPemu(:,:,:,:,:,1);
% 
% %% Difference from s-MERRA and Obs 
% 
% cmaplims = [-100 100];
% cint = -100:10:100;
% %cmaplims = [-25 25];
% %cint = -25:2.5:25;
% 
% figure(109);colormap(cmapnegpos20)
% contourf(PP,CO2,(squeeze(diffC3MPemuClim(6,:,:,1,1,thisloc)))',cint);
% xlabel('% Change in Precipitation');
% ylabel('Carbon Dioxide Concentration');
% title('Cross-Section of Yield [s-MERRA - Obs at Zero Temperature Change]');
% caxis(cmaplims);
% 
% figure(209);colormap(cmapnegpos20)
% contourf(TT,CO2,(squeeze(diffC3MPemuClim(:,11,:,1,1,thisloc)))',cint);
% xlabel('Change in Temperature');
% ylabel('Carbon Dioxide Concentration');
% title('Cross-Section of Yield [s-MERRA - Obs at Zero Precipitation Change]');
% caxis(cmaplims);
% 
% figure(309);colormap(cmapnegpos20)
% contourf(TT,PP,(squeeze(diffC3MPemuClim(:,:,2,1,1,thisloc)))',cint);
% xlabel('Change in Temperature');
% ylabel('% Change in Precipitation');
% title('Cross-Section of Yield [s-MERRA - Obs at Baseline Carbon Dioxide Concentration (360ppm)]');
% caxis(cmaplims);
% 
% 
% print(109,'-depsc',['/home/aruane/temp/GulfCoast/C3MPfigures/CrossTclim_' loclist{thisloc}]);
% print(209,'-depsc',['/home/aruane/temp/GulfCoast/C3MPfigures/CrossPclim_' loclist{thisloc}]);
% print(309,'-depsc',['/home/aruane/temp/GulfCoast/C3MPfigures/CrossCO2clim_' loclist{thisloc}]);
% colorbar('h');
% print(309,'-depsc','/home/aruane/temp/GulfCoast/C3MPfigures/Colorbardiff_horiz');






