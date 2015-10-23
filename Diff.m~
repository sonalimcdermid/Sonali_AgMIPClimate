% Take the difference between two experiments

% Change files to load here and name variables

function acr_agmip_diff300(experiment1,experiment2)

load experiment1
norm1 = normC3MPemu;
load experiment2
norm2 = normC3MPemu;

diffnorm = norm1-norm2;

load /Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/AnalysisPrograms/colormaps/cmapprecip.mat
load /Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/AnalysisPrograms/colormaps/cmapprecip20.mat
load /Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/AnalysisPrograms/colormaps/cmapnegpos.mat
load /Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/AnalysisPrograms/colormaps/cmapnegpos20.mat


TT=-1:0.2:8;
PP=-50:5:50;
CO2 = 330:30:900;
cmaplims = [-100 100];
cint = -100:10:100;


figure(103);colormap(cmapnegpos20)
contourf(PP,CO2,(squeeze(diffnorm(6,:,:)))',cint);
xlabel('% Change in Precipitation');
ylabel('Carbon Dioxide Concentration');
%title('Cross-Section of Yield Rainfed-Irrigated at Zero Temperature Change');
caxis(cmaplims);

figure(203);colormap(cmapnegpos20)
contourf(TT,CO2,(squeeze(diffnorm(:,11,:)))',cint);
xlabel('Change in Temperature');
ylabel('Carbon Dioxide Concentration');
%title('Cross-Section of Yield Rainfed-Irrigated at Zero Precipitation Change');
caxis(cmaplims);


figure(303);colormap(cmapnegpos20)
contourf(TT,PP,(squeeze(diffnorm(:,:,2)))',cint);
xlabel('Change in Temperature');
ylabel('% Change in Precipitation');
%title('Cross-Section of Yield Rainfed-Irrigated at Baseline Carbon Dioxide
%Concentration (360ppm)');
caxis(cmaplims);

print(103,'-depsc',['/Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/Results/AnalysisOutput/Diff_Figures/CrossT_Diff']);
print(203,'-depsc',['/Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/Results/AnalysisOutput/Diff_Figures/CrossP_Diff']);
print(303,'-depsc',['/Users/spshukla/Documents/NPP_Work/AgMIP/C3MP/Results/AnalysisOutput/Diff_Figures/CrossCO2_Diff']);