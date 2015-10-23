%			acr_pcolormapr2_windows
%
%    This script produces a pcolor map of the variable passed over 
%    a particular latitude and longitude range using an eckert
%    projection.
%
%    usage:
%    acr_pcolormapr(vaar,lat,lon,vargin)
%
%    where:
%    vaar      = variable to be mapped
%    lat       = array of latitudes to match each point
%    lon       = array of longitudes to match each point
%    vargin(1) = colorbar limits
%    vargin(2) = title of plot (String)
%    vargin(3) = colorbar label (String)
%
%    example call: 
%    acr_pcolormap(prate(2,:,:),lat,lon,[0 20]);
% 
%	                	author: Alex Ruane
%                                       aruane@ucsd.edu
%				date:	10/23/07
%     updated for coasts: 07/11/2013     alexander.c.ruane@nasa.gov
%
function acr_pcolormapr2_windows(vaar,lat,lon,varargin);

if(exist('varargin'))
  % get variable arguments in
  if(length(varargin) > 0)
    use_caxis = varargin{1};
  end;
  if (length(varargin) > 1)
    ti = varargin{2};
  end;
  if(length(varargin) > 2)
    clab = varargin{3};
  end;
end;

%% begin debug
%ncid = netcdf('/home/aruane/temp/wrfout_d01_2002-07-10_06:00:00','nowrite');
%vaar = var(ncid);
%for i=1:235,  		% number of time steps
%  t2m(i,:,:) = vaar{29}(i,:,:);
%end;
%
%lat(:,:) = vaar{113}(1,:,:);
%lon(:,:) = vaar{114}(1,:,:);
%vaar = t2m(10,:,:);
%use_caxis = [280 310];
%ti = 'Title1';
%clab = 'K';
%% end debug

% permute to get proper dimension
s = size(vaar);
index=0;
while ((s(1) == 1) && (index < 8)),
  permvect = 2:length(s)+1;
  permvect(length(s)) = 1;
  vaar = permute(vaar,permvect);
  s = size(vaar);
  index = index + 1;
end;
if (index >= 8)
  error('Variable Dimensional Error');
end;

% get field information (check longitude and latitude)
lats = size(lat);
lons = size(lon);
yy = s(1);				% # of field latitudes
xx = s(2);				% # of field longitudes
yylat = lats(1);			% latitude yy-size
xxlat = lats(2);			% latitude xx-size
yylon = lons(1);			% longitude yy-size
xxlon = lons(2);			% longitude xx-size
dlat = lat(2)-lat(1);                   % pcolor offset
dlon = lon(1,2)-lon(1,1);               % pcolor offset

% check for consistency
if ((xx ~= xxlat)||(xx ~= xxlon)||(yy ~= yylat)||(yy ~= yylon))
  error('Incorrect domain size');
end;

hold on;

a = axesm('eckert3','maplatlimit',minmax(lat),'maplonlimit', ...	
 	minmax(lon),'grid','on','glinewidth',0.1000);

%plotm(coast,'k','linewidth',1);		% plot coastline

load /Users/sps246/Research/C3MP/AnalysisPrograms/colormaps/cmapposag.mat
colormap(cmapposag)
%load /Users/sps246/Research/C3MP/AnalysisPrograms/colormaps/cmapprecip.mat
%colormap(cmapprecip)

% filled contour (smoothed)
pcolorm(lat-dlat/2,lon-dlon/2,vaar), shading flat;	
axis tight;
if(exist('varargin'))
  if(length(varargin) > 0)
    caxis(use_caxis);
  end;
end;

h = colorbar('horiz');

if(exist('varargin'))
  if(length(varargin) > 1)
    t=title(ti);
    set(t,'fontsize',10);
    set(t,'fontweight','bold');
  end;
  if(length(varargin) > 2)
    set(get(h,'Xlabel'),'String',clab);
    set(h,'fontsize',8);
  end;
end;
  
%mapm = worldlo('POline');
%map2 = displaym(mapm);
%set(map2,'color','k');

%% The following were created below:
load /Users/sps246/Research/C3MP/AnalysisPrograms/coastlat2.mat
load /Users/sps246/Research/C3MP/AnalysisPrograms/coastlon2.mat
plotm(coastlat2,coastlon2,'k');


%load worldlo POline
%latPO = POline.lat;
%lonPO = POline.long;

%coastlat = ones(0,1);
%coastlon = ones(0,1);
%lastbreak = 0;
%for ii=2:length(lonPO),
%   if(isnan(lonPO(ii)))
%     coastlat = [coastlat (latPO(lastbreak+1:ii))'];
%     coastlon = [coastlon (lonPO(lastbreak+1:ii))']; 
%     lastbreak = ii;
%   elseif((sign(lonPO(ii))~=sign(lonPO(ii-1)))&&(~isnan(lonPO(ii-1))))
%     coastlon = [coastlon (lonPO(lastbreak+1:ii-1))' 0.0001*sign(lonPO(ii-1)) NaN 0.0001*sign(lonPO(ii)) lonPO(ii)]; 
%     coastlat = [coastlat (latPO(lastbreak+1:ii-1))' latPO(ii-1)+abs(lonPO(ii-1))/(abs(lonPO(ii)-lonPO(ii-1)))*(latPO(ii)-latPO(ii-1)) NaN latPO(ii-1)+abs(lonPO(ii-1))/(abs(lonPO(ii)-lonPO(ii-1)))*(latPO(ii)-latPO(ii-1)) latPO(ii)];
%     lastbreak = ii;
%   elseif(ii==length(lonPO))
%     coastlat = [coastlat (latPO(lastbreak+1:ii))'];
%     coastlon = [coastlon (lonPO(lastbreak+1:ii))']; 
%     lastbreak = ii;
%   end;
%end;
%cd 'C:\Users\aruane\Documents\_work\Matlab_Scripts'
%save('coastlat','coastlat');
%save('coastlon','coastlon');

% %% with coastlines
% aa = coast;
% latcoast= aa(:,1);
% loncoast = aa(:,2);
% 
% %% start with political boundaries
% coastlat2 = [coastlat NaN];
% coastlon2 = [coastlon NaN];
% lastbreak = 0;
% for ii=2:length(loncoast),
%   if(isnan(loncoast(ii)))
%     coastlat2 = [coastlat2 (latcoast(lastbreak+1:ii))'];
%     coastlon2 = [coastlon2 (loncoast(lastbreak+1:ii))']; 
%     lastbreak = ii;
%   elseif((sign(loncoast(ii))~=sign(loncoast(ii-1)))&&(~isnan(loncoast(ii-1))))
%     coastlon2 = [coastlon2 (loncoast(lastbreak+1:ii-1))' 0.0001*sign(loncoast(ii-1)) NaN 0.0001*sign(loncoast(ii)) loncoast(ii)]; 
%     coastlat2 = [coastlat2 (latcoast(lastbreak+1:ii-1))' latcoast(ii-1)+abs(loncoast(ii-1))/(abs(loncoast(ii)-loncoast(ii-1)))*(latcoast(ii)-latcoast(ii-1)) NaN latcoast(ii-1)+abs(loncoast(ii-1))/(abs(loncoast(ii)-loncoast(ii-1)))*(latcoast(ii)-latcoast(ii-1)) latcoast(ii)];
%     lastbreak = ii;
%   elseif(ii==length(loncoast))
%     coastlat2 = [coastlon2 (latcoast(lastbreak+1:ii))'];
%     coastlon2 = [coastlon2 (loncoast(lastbreak+1:ii))']; 
%     lastbreak = ii;
%   end;
% end;
% cd 'C:\Users\aruane\Documents\_work\Matlab_Scripts'
% save('coastlat2','coastlat2');
% save('coastlon2','coastlon2');


%xlabel('Degrees Longitude');
%ylabel('Degrees Latitude');
hold off
