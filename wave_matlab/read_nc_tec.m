clear; clc;

file_list = dir(fullfile('./','*.nc'));
tec_data = zeros([360,180,288*length(file_list)]);

for i=1:length(file_list)
    full_path = [file_list(i).folder,...
        '/',file_list(i).name];
    info = ncinfo(full_path);
    gdlat = ncread(full_path, 'gdlat');
    glon = ncread(full_path, 'glon');
    tec_data(:,:,(i-1)*288+1:i*288) = ncread(full_path, 'tec');
end

save('tec_data.mat', 'tec_data', 'gdlat', 'glon');

[x,y] = meshgrid(glon, gdlat);
pcolor(x, y, tec_data(:,:,100)');
shading interp;
