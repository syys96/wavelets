clear; clc;

data_struct = load('tec_data.mat');
tec_data = data_struct.tec_data;
gdlat = data_struct.gdlat;
glon = data_struct.glon;

% [x,y] = meshgrid(glon, gdlat);
% pcolor(x, y, tec_data(:,:,100)');
% shading interp;

lon_st = -70; lon_ed = -60;
lon_st_id = lon_st - min(glon) + 1;
lon_ed_id = lon_ed - min(glon) + 1;

subplot(2,1,1);
tec_ava_lon = squeeze(nanmean(tec_data(lon_st_id:lon_ed_id,:,:)));
time = 1:1440;
[x,y] = meshgrid(time, gdlat);
pcolor(x,y,tec_ava_lon);
shading interp;

lat_point = -30;
lat_point_id = lat_point - min(gdlat) + 1;
tec_point = tec_ava_lon(lat_point_id,:);
mask = ~isnan(tec_point);
nseq = tec_point;
nseq(~mask) = interp1(time(mask), tec_point(mask), time(~mask));

subplot(2,1,2);
plot(time, tec_point,'-', time, nseq, '--');
% plot(time, nseq);
axis tight;

save(['tec_',num2str(lon_st),'-',num2str(lon_ed),'_',num2str(lat_point),...
    '.mat'], 'tec_point', 'nseq');




