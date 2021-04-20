clear; clc;

data_struct = load('tec_data.mat');
tec_data = data_struct.tec_data;
gdlat = data_struct.gdlat;
glon = data_struct.glon;
shape_tec = size(tec_data);

% [x,y] = meshgrid(glon, gdlat);
% pcolor(x, y, tec_data(:,:,100)');
% shading interp;

plot_num = 5;

lon_st = -70; lon_ed = -60;
lon_st_id = lon_st - min(glon) + 1;
lon_ed_id = lon_ed - min(glon) + 1;

subplot(plot_num,1,1);
tec_ava_lon = squeeze(nanmean(tec_data(lon_st_id:lon_ed_id,:,:)));
time = (1:shape_tec(3))/288+14;
[x,y] = meshgrid(time, gdlat);
pcolor(x,y,tec_ava_lon);
shading interp;

filter_degree = 4;
[b,a] = butter(filter_degree, [(1/5)/(12/2), (1/1)/(12/2)], 'bandpass');
tec_ava_lon_fil = zeros([180,shape_tec(3)]);
for i=1:180
    tec_point_m = tec_ava_lon(i,:);
    mask_m = ~isnan(tec_point_m);
    nseq_m = tec_point_m;
    if any(mask_m) && sum(mask_m) >= 2 ...
            && any(~mask_m)
        nseq_m(~mask_m) = interp1(time(mask_m), ...
        tec_point_m(mask_m), time(~mask_m));
    end
    tec_ava_lon_fil(i,:) = filter(b,a,nseq_m);
end
subplot(plot_num,1,2);
pcolor(x,y,tec_ava_lon_fil);
caxis([-12,12]);
shading interp;


lat_point = -30;
lat_point_id = lat_point - min(gdlat) + 1;
tec_point = tec_ava_lon(lat_point_id,:);
mask = ~isnan(tec_point);
nseq = tec_point;
nseq(~mask) = interp1(time(mask), tec_point(mask), time(~mask));

subplot(plot_num,1,3);
plot(time, tec_point,'-', time, nseq, '--');
% plot(time, nseq);
axis tight;

subplot(plot_num,1,4);
% [b,a] = butter(filter_degree, [(1/3)/(12/2), (1/1)/(12/2)], 'bandpass');
sig_fil = filter(b,a,nseq);
plot(time, sig_fil);
axis tight;

dst = load('dst_2015.mat').data;
date_st = 31 + 28 + 14;
date_ed = 31 + 28 + shape_tec(3)/288+14-1;
dst = dst((date_st-1)*24+1:(date_ed)*24);
subplot(plot_num,1,5);
plot((1:shape_tec(3)/12)/24+14,dst);

save(['tec_',num2str(lon_st),'-',num2str(lon_ed),'_',num2str(lat_point),...
    '.mat'], 'tec_point', 'nseq', 'sig_fil');





