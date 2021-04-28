clear; clc;

data_struct = load('tec_data.mat');
tec_data = data_struct.tec_data;
gdlat = data_struct.gdlat;
glon = data_struct.glon;
shape_tec = size(tec_data);
time = (1:shape_tec(3))/288+14;

filter_degree = 4;
[b,a] = butter(filter_degree, [(1/5)/(12/2), (1/1)/(12/2)], 'bandpass');
tec_filted_map = zeros(shape_tec);
for ind_lon=1:360
    ind_lon
    for ind_lat=1:180
        tec_point_m = squeeze(tec_data(ind_lon, ind_lat, :));
        mask_m = ~isnan(tec_point_m);
        if sum(mask_m) >= shape_tec(3)/2
            nseq_m = tec_point_m;
            if any(~mask_m)
                nseq_m(~mask_m) = interp1(time(mask_m), ...
                tec_point_m(mask_m), time(~mask_m));
            end
            tec_filted_map(ind_lon, ind_lat, :) ...
                = filter(b,a,nseq_m);
        else
            tec_filted_map(ind_lon, ind_lat, :) ...
                = NaN(1,shape_tec(3));
        end
    end
end

save('tec_filter.mat', 'tec_filted_map', 'gdlat', 'glon');

