clear; clc;

data_struct = load('tec_filter.mat');
tec_data = data_struct.tec_filted_map;
gdlat = data_struct.gdlat;
glon = data_struct.glon;
shape_tec = size(tec_data);
time = (1:shape_tec(3))/288+14;

lon_st = -120-min(glon)+1; lon_ed = -40-min(glon)+1;
lat_st = -60-min(gdlat)+1; lat_ed = 60-min(gdlat)+1;

[x,y] = meshgrid(glon(lon_st:lon_ed), gdlat(lat_st:lat_ed));
% pcolor(x, y, ...
%     tec_data(lon_st:lon_ed,lat_st:lat_ed,100)');
% shading interp;
% axis equal;
% colorbar();
% caxis([-5,5]);

h = figure;
axis tight manual;
num_fra = 1;
filename = 'test4.gif';
dt=0.1;
frame_per_day = 288;

for tid=288*3.5:288*5
    tid
    pcolor(x, y, ...
        tec_data(lon_st:lon_ed,lat_st:lat_ed,tid)');
    shading interp;
    axis equal;
    colorbar();
    caxis([-6,6]);
    title([num2str(time(tid)), ',', num2str(num_fra)]);
    
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256);
    if num_fra == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf, 'DelayTime',dt); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append', 'DelayTime',dt);
    end
    
    num_fra = num_fra + 1;
end


