%			acr_nancorr2
%
%       Corr2 with capability to only examine non-nan pairs.
%       Both series must have the same lengths 
%
%				author: Alex Ruane
%                                       alexander.c.ruane@nasa.gov
%				date:	04/03/12
%
%
function nancorr2 = acr_nancorr2(series1,series2);
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  

%% begin debug
%series1 = trmm(:,4);
%series2 = obs(:,5);
%% end debug

if(length(series1)~=length(series2))
  error('Series must be the same length -- acr_nancorr2');
end;

jointgood = find(~isnan(series1)&(~isnan(series2)));
nancorr2 = corr2(series1(jointgood),(series2(jointgood)));
