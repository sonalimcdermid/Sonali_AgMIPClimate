%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			acr_agmip300
%
%  This script analyzes C3MP output for all submitted simulation sets in a 
%  standardized input file .csv format based upon the reporting template.
%
%   author: Alex Ruane and Sonali McDermid
%       alexander.c.ruane@nasa.gov
%	date:	04/04/2013
%
%   Updated: 09/13/2013 by Sonali McDermid
%     Edited to include a loop through the experiments contributed to C3MP
%       standardized csv filenames and run array of plausibility tests. 
%   Updated: 11/06/2013 by Nicholas Hudson
%     Edited to run on DoubleDay 
%   Updated: 01/21/2014 by Nicholas Hudson
%     Edited to use emulated baseline as reference point.
%   Updated: 01/22/2014 by Nicholas Hudson
%     Edited to change all '0' values to '0.00001' and include values
%       > |100| in IRS
%   Updated: 01/29/2014 by Nicholas Hudson
%     Edited to include zero count plausibility checks
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% acr_agmip300_DD20140129

%%  Set variables and load required datasets 
addpath /Users/sps246/Research/C3MP/AnalysisPrograms/colormaps
addpath /Users/sps246/Research/C3MP/AnalysisPrograms
%addpath /home/aruane/C3MP/Matlab

load cmapprecip.mat
load cmapprecip20.mat
load cmapnegpos.mat
load cmapnegpos20.mat
load colormap_surfaces_new1.mat

%%  Define 'orange' for plotting
orange  = [255 138 0]./255;

%%  Redefine color map to include values > |100| in IRS
cmapprecip22 = [0.2 0.1 0; colormap_surfaces_new1; 0.0035 0.25 0];

%%  Determine number of standardized .csv files
cd /Users/sps246/Research/C3MP/Results/csv/
%cd /home/aruane/C3MP/All/
filelist = dir('*.csv');
numfiles = length(filelist);
[~,NAME,~] = fileparts(filelist(numfiles).name);
%totfiles = str2double(NAME);
totfiles = numfiles;
%%  Pre-Allocate analysis arrays
RMSE            = NaN(totfiles,1);
Rsq             = NaN(totfiles,1);
plause          = NaN(totfiles,5);
slope           = NaN(totfiles,3);
zcount          = NaN(totfiles,3);
coeff           = NaN(totfiles,11);
coeff_CV        = NaN(totfiles,11);
sens_tests      = NaN(totfiles,99,2);
sens_tests_CV   = NaN(totfiles,99,2);

%%  Analysis 'for' loop
for dd = 1:numfiles
    
    %%%  Extract the filename
    filename = filelist(dd).name;
    [~,NAME,~] = fileparts(filename);
    jj = str2double(NAME);
    disp(num2str(jj))
    
    %%%  Import the data
    yield = importdata(filename);
    yield = yield';
    
    %%%  Count number of zeroes (1), -99s (2) and NaNs (3) in simulated set
    zcount(jj,1) = length(find(yield == 0));
    zcount(jj,2) = length(find(yield == -99));
    zcount(jj,3) = length(find(isnan(yield) == 1));
    
    %%%  Flag simulation sets that contain '-99' values
    if yield(yield==-99)
        disp('     -99 values found at');
        disp(['        ', num2str(find(yield==-99)')]);
        disp('     Converted to NaNs for assessment.');
        yield(yield==-99) = NaN;
    end
    
    %%%  Convert '0' values to '0.00001' to avoid CV issues
    yield(yield == 0) = 0.00001;
    
    hyper = importdata('/Users/sps246/Research/C3MP/AnalysisPrograms/C3MPhyper99.mat');

    
    acr_nancorr2(mean(yield(:,:),2),hyper(:,1));
    acr_nancorr2(mean(yield(:,:),2),hyper(:,3));
    acr_nancorr2(mean(yield(:,:),2),hyper(:,4));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%   Fit emulator to mean yields   %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    tseries = mean(yield,2);
    
    %%%  Set series for emulator
    tt1 = hyper(:,1);       %% Temperature (T)
    tt2 = hyper(:,3);       %% Precipitation factor (P)
    tt3 = hyper(:,4);       %% Atmospheric [CO2] (CO2)
    tt4 = tt1.*tt2;         %% TxP
    tt5 = tt1.*tt3;         %% TxCO2
    tt6 = tt2.*tt3;         %% PxCO2
    tt7 = tt1.*tt2.*tt3;    %% TxPxCO2
    model1 = [1 2];         %% quadratic for T
    model2 = [1 2];         %% quadratic for P
    model3 = [1 2];         %% quadratic for CO2
    model4 = 1;             %% linear for all cross terms
    model5 = 1;
    model6 = 1;
    model7 = 1;
    nmod1 = length(model1);
    nmod2 = length(model2);
    nmod3 = length(model3);
    nmod4 = length(model4);
    nmod5 = length(model5);
    nmod6 = length(model6);
    nmod7 = length(model7);
    
    %%%  Determine emulator parameters using 'acr_poly7.m'
    [construct,const,amp] = acr_poly7((tseries(:))',tt1,tt2,tt3,tt4, ...
        tt5,tt6,tt7,model1,model2,model3,model4,model5,model6,model7);
    
    coeff(jj,:) = [const amp];       %  Emulator parameters
    sens_tests(jj,:,1) = tseries';   %  Submitted results to 99 tests
    sens_tests(jj,:,2) = construct;  %  Emulated results to 99 tests
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%   Build emulator for mean yield   %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%  Set uncertainty space
    TT  = -1:0.2:8;
    PP  = 0.5:0.05:1.5;
    CO2 = 330:30:900;
    
    C3MPemu = ones(length(TT),length(PP),length(CO2))*NaN;
    
    %%%  Hypercube construction 'for' loop
    for thisT=1:length(TT)
        for thisP=1:length(PP)
            for thisCO2=1:length(CO2)
                
                tt1 = TT(thisT);
                tt2 = PP(thisP);
                tt3 = CO2(thisCO2);
                tt4 = tt1*tt2;
                tt5 = tt1*tt3;
                tt6 = tt2*tt3;
                tt7 = tt1*tt2*tt3;
                C3MPemu(thisT,thisP,thisCO2) = const;
                
                for ii=1:nmod1
                    C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + ...
                        squeeze(amp(ii)*(tt1.^real(model1(ii))));
                end
                
                for ii=1:nmod2
                    C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + ...
                        squeeze(amp(ii+nmod1)*(tt2.^real(model2(ii))));
                end
                
                for ii=1:nmod3
                    C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + ...
                        squeeze(amp(ii+nmod1+nmod2)*(tt3.^real(model3(ii))));
                end
                
                for ii=1:nmod4
                    C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + ...
                        squeeze(amp(ii+nmod1+nmod2+nmod3)*(tt4.^real(model4(ii))));
                end
                
                for ii=1:nmod5
                    C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + ...
                        squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4)*(tt5.^real(model5(ii))));
                end
                
                for ii=1:nmod6
                    C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + ...
                        squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4+nmod5)*(tt6.^real(model6(ii))));
                end
                
                for ii=1:nmod7
                    C3MPemu(thisT,thisP,thisCO2) = C3MPemu(thisT,thisP,thisCO2) + ...
                        squeeze(amp(ii+nmod1+nmod2+nmod3+nmod4+nmod5+nmod6)*(tt7.^real(model7(ii))));
                end
            end
        end
    end
    
    %%%  Spot Checks
%     figure(10000);
%     plot(tseries(:))
%     hold on
%     for ii=1:length(hyper)
%         emutest(ii) = C3MPemu(dsearchn(TT',hyper(ii,1)),dsearchn(PP',hyper(ii,3)),dsearchn(CO2',hyper(ii,4)));
%     end;
%     plot(emutest,'m');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Plot Mean Yield cross-sectional Impact Response Surfaces  (IRS)   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%  Revise dimensional bounds for plotting
    PP = -50:5:50;
    cint    = [-9999,-100:10:100,9999];
    
    %%%  T cross-sectional plot
    figure(101);    colormap(cmapprecip22); %colormap(cmapprecip22);
    contourf(PP,CO2,((squeeze(C3MPemu(6,:,:))/C3MPemu(6,11,2))'-1)*100,cint);
    hold on
    contour(PP,CO2,((squeeze(C3MPemu(6,:,:))/C3MPemu(6,11,2))'-1)*100, ...
        [0 0],'k','Linewidth',2);
    p=plot(PP(11),CO2(2),'ks');
    set(p,'markerfacecolor','k');
    xlabel('% Change in Precipitation');
    ylabel('Carbon Dioxide Concentration');
    title('Cross-Section at Zero Temperature Change');
    caxis([-110 110]);
    colorbar
    
    %%%  P cross-sectional plot
    figure(201); colormap(cmapprecip22);
    contourf(TT,CO2,((squeeze(C3MPemu(:,11,:))/C3MPemu(6,11,2))'-1)*100,cint);
    hold on
    contour(TT,CO2,((squeeze(C3MPemu(:,11,:))/C3MPemu(6,11,2))'-1)*100, ...
        [0 0],'k','Linewidth',2);
    p=plot(TT(6),CO2(2),'ks');
    set(p,'markerfacecolor','k');
    xlabel('Change in Temperature');
    ylabel('Carbon Dioxide Concentration');
    title('Cross-Section at Zero Precipitation Change');
    caxis([-110 110]);
    colorbar
    
    %%%  CO2 cross-sectional plot
    figure(301); colormap(cmapprecip22);
    contourf(TT,PP,((squeeze(C3MPemu(:,:,2))/C3MPemu(6,11,2))'-1)*100,cint);
    hold on
    contour(TT,PP,((squeeze(C3MPemu(:,:,2))/C3MPemu(6,11,2))'-1)*100, ...
        [0 0],'k','Linewidth',2);
    p=plot(TT(6),PP(11),'ks');
    set(p,'markerfacecolor','k');
    xlabel('Change in Temperature');
    ylabel('% Change in Precipitation');
    title('Cross-Section at Baseline Carbon Dioxide Concentration (360ppm)');
    caxis([-110 110]);
    colorbar
    
    %%%  Save cross-sectional plots
     print(101,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossT']);
     print(201,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossP']);
     print(301,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossCO2']);

    
     print(101,'-djpeg',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossT']);
     print(201,'-djpeg',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossP']);
     print(301,'-djpeg',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossCO2']);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%   Analysis   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%  January 17, 2014 - Changed reference comparison from sensitivity
    %%%     test 43 to emulated baseline.
    
%     normC3MPemu(:,:,:,thisclim,thisirr,thisloc) = ((C3MPemu(:,:,:,thisclim,thisirr,thisloc))/C3MPemu(6,11,2,thisclim,thisirr,thisloc)-1)*100;
%     normC3MPemu(:,:,:) = ((C3MPemu(:,:,:))/C3MPemu(6,11,2)-1)*100;
%     
%     vecname = [ NAME '.mat' ];
%     save(vecname, normC3MPemu);
%     
%     movefile(vecname,'/home/aruane/C3MP/All/AnalysisOutput/Response_diff/');
    
    %%%  Find emulated baseline yield 
    emu_base = C3MPemu(6,11,2);
    
    %%%-----------------------------------------------------------------%%%
    %%%%%%%%%%%%%%%%   Analysis of emulator plausibility   %%%%%%%%%%%%%%%%
    %%%-----------------------------------------------------------------%%%
    
    %%%  Check 1: delT = 4, delP = 0,   CO2 = 360
    %%%   Corresponds to indices (26,11,2)
    plaus1 = ((C3MPemu(26,11, 2)-emu_base)/emu_base)*100;
    
    %%%  Check 2: delT = 1, delP = 0,   CO2 = 360
    %%%   Corresponds to indices (11,11,2)
    plaus2 = ((C3MPemu(11,11, 2)-emu_base)/emu_base)*100;
    
    %%%  Check 3: delT = 0, delP = -25, CO2 = 360
    %%%  Corresponds to indices (6,6,2)
    plaus3 = ((C3MPemu( 6, 6, 2)-emu_base)/emu_base)*100;
    
    %%%  Check 4: delT = 0, delP = 0,   CO2 = 720
    %%%   Corresponds to indices (6,11,14)
    plaus4 = ((C3MPemu( 6,11,14)-emu_base)/emu_base)*100;
    
    %%%  Save variable with plausibility checks and emulated baseline yield
    plause(jj,:) = [plaus1 plaus2 plaus3 plaus4 emu_base];
    
    %%%-----------------------------------------------------------------%%%
    %%%%%%%%%%%%%   Analysis of RMSE using emulated baseline   %%%%%%%%%%%%
    %%%-----------------------------------------------------------------%%%
    
    %%%  Calculate RMSE
    tseriesb    = ((tseries(:)-emu_base)./emu_base)*100;
    constructb  = ((construct(:)-emu_base)./emu_base)*100;
    RMSE(jj) = sqrt(mean((tseriesb(:) - constructb(:)).^2));
        
    %%%-----------------------------------------------------------------%%%
    %%%%%%%%%%%%%%%%   Analysis of emulator correlation   %%%%%%%%%%%%%%%%%
    %%%-----------------------------------------------------------------%%%
    
    %%%  Calculate R squared (Rsq)
    Rsq(jj) = (corr2(tseries(:),construct(:)))^2;
        
    %%%-----------------------------------------------------------------%%%
    %%%%%%%%%%%%%%%%%%%%%%%   Analysis of slopes   %%%%%%%%%%%%%%%%%%%%%%%%
    %%%-----------------------------------------------------------------%%%
    
    %%%  Calculate slopes across baseline climate, where 
    %%%   delT = 0  (index =  6)
    %%%   delP = 0  (index = 11)
    %%%   CO2 = 360 (index =  2)
    
    %%%  Slope in temperature dimension to express relative yield change
    dydt = (C3MPemu(7,11,2)-C3MPemu(5,11,2))/(TT(7)-TT(5));
    dydt = dydt/emu_base*100;
    
    %%%  Slope in precipitation dimension to express relative yield change
    dydp = (C3MPemu(6,12,2)-C3MPemu(6,10,2))/(PP(12)-PP(10));
    dydp = dydp/emu_base*100/10;
    
    %%%  Slope in [C02] dimension to express relative yield change
    dydco2 = (C3MPemu(6,11,3)-C3MPemu(6,11,1))/(CO2(3)-CO2(1));
    dydco2 = dydco2/emu_base*100*100;
    
    %%%  Save variable with slope values
    slope(jj,:) = [dydt dydp dydco2];
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%   Fit emulator to yield CVs   %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    tseriescv = (std(permute(yield,[2 1])))'./abs(mean(yield,2));
    
    %%%  Set series for emulator
    tt1 = hyper(:,1);
    tt2 = hyper(:,3);
    tt3 = hyper(:,4);
    tt4 = tt1.*tt2;
    tt5 = tt1.*tt3;
    tt6 = tt2.*tt3;
    tt7 = tt1.*tt2.*tt3;
    model1 = [1 2];
    model2 = [1 2];
    model3 = [1 2];
    model4 = 1;
    model5 = 1;
    model6 = 1;
    model7 = 1;
    nmod1 = length(model1);
    nmod2 = length(model2);
    nmod3 = length(model3);
    nmod4 = length(model4);
    nmod5 = length(model5);
    nmod6 = length(model6);
    nmod7 = length(model7);
    
    %%%  Determine emulator parameters using 'acr_poly7.m'
    [constructcv,constcv,ampcv] = acr_poly7((tseriescv(:))',tt1,tt2,tt3, ...
        tt4,tt5,tt6,tt7,model1,model2,model3,model4,model5,model6,model7);
    
    coeff_CV(jj,:) = [constcv ampcv];
    sens_tests_CV(jj,:,1) = tseriescv';
    sens_tests_CV(jj,:,2) = constructcv;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%   Sensitivity Test Summary Plots   %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    figure(1)
    set(gcf, 'units','inches','pos',[.3,.3,7.9,12],'paperpos', ...
        [.3,.3,7.9,12],'paperor','portrait');
    
%     subplot(3,1,1);
%     plot(1980:2009,yield(58,1:30));
%     title('Sensitivity Test #58; deltaT = -0.2 degrees, deltaP = 11%, [CO_2]=475ppm');
    
    subplot(3,1,1);
    plot(1980:2009,yield(:,1:30));
    title('All Sensitivity Tests');
    
%     subplot(3,1,2);
%     boxplot(yield(:,1:30));
%     title('All Sensitivity Tests');
    
%     subplot(3,1,2);
%     boxplot((yield(:,1:30))');
%     title('All Sensitivity Tests');
    
    subplot(3,1,2);
    plot(tseries(:));
    hold on
    plot(construct(:),'Color',orange);
    xlabel('C3MP Sensitivity test');
    ylabel('1980-2009 Mean Yields');
    title('Mean Yield Emulator fit check');
    
    subplot(3,1,3);
    plot(tseriescv(:));
    hold on
    plot(constructcv(:),'Color',orange);
    xlabel('C3MP Sensitivity test');
    ylabel('1980-2009 Yield CVs');
    title('Yield CV Emulator fit check');
    
     print(1,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_Summary']);
    
     print(1,'-djpeg',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_Summary']);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%   Build emulator for yield CV   %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%  Set uncertainty space
    TT  = -1:0.2:8;
    PP  = 0.5:0.05:1.5;
    CO2 = 330:30:900;
    
    C3MPemucv = ones(length(TT),length(PP),length(CO2))*NaN;
    
    %%%  Hypercube construction 'for' loop
    for thisT=1:length(TT)
        for thisP=1:length(PP)
            for thisCO2=1:length(CO2)
                tt1 = TT(thisT);
                tt2 = PP(thisP);
                tt3 = CO2(thisCO2);
                tt4 = tt1*tt2;
                tt5 = tt1*tt3;
                tt6 = tt2*tt3;
                tt7 = tt1*tt2*tt3;
                C3MPemucv(thisT,thisP,thisCO2) = constcv;
                
                for ii=1:nmod1
                    C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + ...
                        squeeze(ampcv(ii)*(tt1.^real(model1(ii))));
                end
                
                for ii=1:nmod2
                    C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + ...
                        squeeze(ampcv(ii+nmod1)*(tt2.^real(model2(ii))));
                end
                
                for ii=1:nmod3
                    C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + ...
                        squeeze(ampcv(ii+nmod1+nmod2)*(tt3.^real(model3(ii))));
                end
                
                for ii=1:nmod4
                    C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + ...
                        squeeze(ampcv(ii+nmod1+nmod2+nmod3)*(tt4.^real(model4(ii))));
                end
                
                for ii=1:nmod5
                    C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + ...
                        squeeze(ampcv(ii+nmod1+nmod2+nmod3+nmod4)*(tt5.^real(model5(ii))));
                end
                
                for ii=1:nmod6
                    C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + ...
                        squeeze(ampcv(ii+nmod1+nmod2+nmod3+nmod4+nmod5)*(tt6.^real(model6(ii))));
                end
                
                for ii=1:nmod7
                    C3MPemucv(thisT,thisP,thisCO2) = C3MPemucv(thisT,thisP,thisCO2) + ...
                        squeeze(ampcv(ii+nmod1+nmod2+nmod3+nmod4+nmod5+nmod6)*(tt7.^real(model7(ii))));
                end
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%   Plot Yield CV cross-sectional Impact Response Surfaces (IRS)   %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%  Revise dimensional bounds for plotting
    PP      =-50:5:50;
    cint    = [-9999,-100:10:100,9999];
    
    %%%  T cross-sectional plot
    figure(151); colormap(flipud(cmapprecip22));
    contourf(PP,CO2,((squeeze(C3MPemucv(6,:,:)/C3MPemucv(6,11,2)-1)*100))',cint);
    hold on
    contour(PP,CO2,((squeeze(C3MPemucv(6,:,:))/C3MPemucv(6,11,2))'-1)*100,[0 0],'k','Linewidth',2);
    p=plot(PP(11),CO2(2),'ks');
    set(p,'markerfacecolor','k');
    xlabel('% Change in Precipitation');
    ylabel('Carbon Dioxide Concentration');
    title('CV Cross-Section at Zero Temperature Change');
    caxis([-110 110]);
    colorbar
    
    %%%  P cross-sectional plot
    figure(251); colormap(flipud(cmapprecip22));
    contourf(TT,CO2,((squeeze(C3MPemucv(:,11,:)/C3MPemucv(6,11,2)-1)*100))',cint);
    hold on
    contour(TT,CO2,((squeeze(C3MPemucv(:,11,:))/C3MPemucv(6,11,2))'-1)*100,[0 0],'k','Linewidth',2);
    p=plot(TT(6),CO2(2),'ks');
    set(p,'markerfacecolor','k');
    xlabel('Change in Temperature');
    ylabel('Carbon Dioxide Concentration');
    title('CV Cross-Section at Zero Precipitation Change');
    caxis([-110 110]);
    colorbar
    
    %%%  CO2 cross-sectional plot
    figure(351); colormap(flipud(cmapprecip22));
    contourf(TT,PP,((squeeze(C3MPemucv(:,:,2)/C3MPemucv(6,11,2)-1)*100))',cint);
    hold on
    contour(TT,PP,((squeeze(C3MPemucv(:,:,2))/C3MPemucv(6,11,2))'-1)*100,[0 0],'k','Linewidth',2);
    p=plot(TT(6),PP(11),'ks');
    set(p,'markerfacecolor','k');
    xlabel('Change in Temperature');
    ylabel('% Change in Precipitation');
    title('CV Cross-Section at Baseline Carbon Dioxide Concentration (360ppm)');
    caxis([-110 110]);
    colorbar
    
    %%  Save cross-sectional plots
    print(151,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossTcv']);
    print(251,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossPcv']);
    print(351,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossCO2cv']);
    
    print(151,'-djpeg',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossTcv']);
    print(251,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossPcv']);
    print(351,'-depsc',['/Users/sps246/Research/C3MP/Results/AnalysisOutput/' NAME '_CrossCO2cv']);
    
    close all
end

%%   Save analysis variables

 cd /Users/sps246/Research/C3MP/Results/AnalysisOutput/

%%%  Save emulator coefficients and results to 99 sensitvity tests
coeffname = 'coeff.mat';
save(coeffname, 'coeff', 'sens_tests');

%%%  Save plausibility checks and emulated baseline yield
plausename = 'plausible.mat';
save(plausename, 'plause');

%%% Save RMSE
rmsename = 'RMSE.mat';
save(rmsename, 'RMSE');

%%%  Save Rsq
Rsqname = 'Rsq.mat';
save(Rsqname, 'Rsq');

%%%  Save zcount
zerocount = 'zerocount.mat';
save(zerocount, 'zcount')

%%%  Save slopes
slopename = 'slope.mat';
save(slopename, 'slope');

%%%  Save emulator coefficients and results to 99 sensitvity tests
coeffcvname = 'coeffcv.mat';
save(coeffcvname, 'coeff_CV', 'sens_tests_CV');

%%%  Save all analysis variables
all = 'all.mat';
save(all, 'RMSE', 'Rsq', 'plause', 'zcount', 'slope', 'coeff', ...
    'coeff_CV','sens_tests', 'sens_tests_CV');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   End of script   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







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






