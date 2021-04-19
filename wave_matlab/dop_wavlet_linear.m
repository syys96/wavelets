clear all; clc;

cp_data = load('cp_data.mat').data;
sst = cp_data;

%------------------------------------------------------ Computation

% normalize by standard deviation (not necessary, but makes it easier
% to compare with plot on Interactive Wavelet page, at
% "http://paos.colorado.edu/research/wavelets/plot/"
variance = std(sst)^2;
sst = (sst - mean(sst))/sqrt(variance) ;

n = length(sst);
dt = 5.0/60.0 ;
time = [0:length(sst)-1]*dt + 4.0*60 ;  % construct time array
xlim = [4*60,8*60];  % plotting range
pad = 1;      % pad the time series with zeroes (recommended)
dj = 24*dt;    % this will do 4 sub-octaves per octave
s0 = 2*dt;    % this says start at a scale of 6 months
j1 = 1024/6/2/dt/dj;    % this says do 7 powers-of-two with dj sub-octaves each
lag1 = 0.72;  % lag-1 autocorrelation for red noise background
mother = 'Morlet';

% Wavelet transform:
[wave,period,scale,coi] = wavelet_linear(sst,dt,pad,dj,s0,j1,mother);
power = (abs(wave)).^2 ;        % compute wavelet power spectrum

% Significance levels: (variance=1 for the normalized SST)
[signif,fft_theor] = wave_signif(1.0,dt,scale,0,lag1,-1,-1,mother);
sig95 = (signif')*(ones(1,n));  % expand signif --> (J+1)x(N) array
sig95 = power ./ sig95;         % where ratio > 1, power is significant

% Global wavelet spectrum & significance levels:
global_ws = variance*(sum(power')/n);   % time-average over all times
dof = n - scale;  % the -scale corrects for padding at edges
global_signif = wave_signif(variance,dt,scale,1,lag1,-1,dof,mother);

% Scale-average between El Nino periods of 2--8 years
avg = find((scale >= 2) & (scale < 8));
Cdelta = 0.776;   % this is for the MORLET wavelet
scale_avg = (scale')*(ones(1,n));  % expand scale --> (J+1)x(N) array
scale_avg = power ./ scale_avg;   % [Eqn(24)]
scale_avg = variance*dj*dt/Cdelta*sum(scale_avg(avg,:));   % [Eqn(24)]
scaleavg_signif = wave_signif(variance,dt,scale,2,lag1,-1,[2,7.9],mother);

whos

%------------------------------------------------------ Plotting

%--- Plot time series
subplot('position',[0.1 0.75 0.65 0.2])
plot(time,sst)
set(gca,'XLim',xlim(:))
xlabel('Time (Minutes)')
ylabel('NINO3 SST (degC)')
title('a) NINO3 Sea Surface Temperature (seasonal)')
hold off

%--- Contour plot wavelet power spectrum
subplot('position',[0.1 0.37 0.65 0.28])
levels = [0.0625,0.125,0.25,0.5,1,2,4,8,16] * 4;
Yticks = (fix((min(period))):10:fix((max(period))));

[xp,yp] = meshgrid(time, (period));
pcolor(xp,yp,log2(power));
% caxis([0,5]);
colormap winter;
colorbar;
shading interp;

% contour(time,(period),log2(power),log2(levels));  %*** or use 'contourfill'

% imagesc(time,log2(period),log2(power));  %*** uncomment for 'image' plot

xlabel('Time (Minutes)')
ylabel('Period (Minutes)')
title('b) NINO3 SST Wavelet Power Spectrum')
set(gca,'XLim',xlim(:))
set(gca,'YLim',([min(period),max(period)]), ...
	'YDir','reverse', ...
	'YTick',(Yticks(:)), ...
	'YTickLabel',Yticks)
% 95% significance contour, levels at -99 (fake) and 1 (95% signif)
hold on
contour(time,(period),sig95,[-99,1],'k');
hold on
% cone-of-influence, anything "below" is dubious
plot(time,(coi),'k')
hold off

%--- Plot global wavelet spectrum
subplot('position',[0.77 0.37 0.2 0.28])
plot(global_ws,(period))
hold on
plot(global_signif,(period),'--')
hold off
xlabel('Power (degC^2)')
title('c) Global Wavelet Spectrum')
set(gca,'YLim',([min(period),max(period)]), ...
	'YDir','reverse', ...
	'YTick',(Yticks(:)), ...
	'YTickLabel','')
set(gca,'XLim',[0,1.25*max(global_ws)])

%--- Plot 2--8 yr scale-average time series
subplot('position',[0.1 0.07 0.65 0.2])
plot(time,scale_avg)
set(gca,'XLim',xlim(:))
xlabel('Time (year)')
ylabel('Avg variance (degC^2)')
title('d) 4-8 hr Scale-average Time Series')
hold on
plot(xlim,scaleavg_signif+[0,0],'--')
hold off

% end of code