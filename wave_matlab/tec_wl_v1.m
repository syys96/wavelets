clear; clc;


cp_data = load('tec_-70--60_20.mat').sig_fil;
% cp_data = load('tec_-70--60_-40.mat').nseq;
sst = cp_data;

%------------------------------------------------------ Computation

% normalize by standard deviation (not necessary, but makes it easier
% to compare with plot on Interactive Wavelet page, at
% "http://paos.colorado.edu/research/wavelets/plot/"
variance = std(sst)^2;
sst = (sst - mean(sst))/sqrt(variance) ;

n = length(sst);
dt = 5.0/60.0;
time = [0:length(sst)-1]*dt/24 + 14.0 ;  % construct time array
xlim = [14,14+(length(sst)/288)];  % plotting range
pad = 1;      % pad the time series with zeroes (recommended)
dj = 0.125/8;    % this will do 4 sub-octaves per octave
s0 = 2*dt;    % this says start at a scale of 6 months
j1 = 9/dj;    % this says do 7 powers-of-two with dj sub-octaves each
lag1 = 0.72;  % lag-1 autocorrelation for red noise background
mother = 'Morlet';

% Wavelet transform:
[wave,period,scale,coi] = wavelet(sst,dt,pad,dj,s0,j1,mother);
power = (abs(wave)).^2 ;        % compute wavelet power spectrum

% Significance levels: (variance=1 for the normalized SST)
[signif,fft_theor] = wave_signif(1.0,dt,scale,0,lag1,-1,-1,mother);
sig95 = (signif')*(ones(1,n));  % expand signif --> (J+1)x(N) array
sig95 = power ./ sig95;         % where ratio > 1, power is significant

% Global wavelet spectrum & significance levels:
global_ws = variance*(sum(power')/n);   % time-average over all times
dof = n - scale;  % the -scale corrects for padding at edges
global_signif = wave_signif(variance,dt,scale,1,lag1,-1,dof,mother);

% Scale-average between El Nino periods of 10--30 minutes
avg = find((scale >= 1) & (scale < 5));
Cdelta = 0.776;   % this is for the MORLET wavelet
scale_avg = (scale')*(ones(1,n));  % expand scale --> (J+1)x(N) array
scale_avg = power ./ scale_avg;   % [Eqn(24)]
scale_avg = variance*dj*dt/Cdelta*sum(scale_avg(avg,:));   % [Eqn(24)]
scaleavg_signif = wave_signif(variance,dt,scale,2,lag1,-1,[1,4.9],mother);

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
Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));

[xp,yp] = meshgrid(time, log2(period));
pcolor(xp,yp,log2(power));
caxis([4,7]);
colormap jet;
% colorbar;
shading interp;

% contour(time,log2(period),log2(power),log2(levels));  %*** or use 'contourfill'

% imagesc(time,log2(period),log2(power));  %*** uncomment for 'image' plot

xlabel('Time (Minutes)')
ylabel('Period (Minutes)')
title('b) NINO3 SST Wavelet Power Spectrum')
set(gca,'XLim',xlim(:))
set(gca,'YLim',log2([min(period),max(period)]), ...
	'YDir','reverse', ...
	'YTick',log2(Yticks(:)), ...
	'YTickLabel',Yticks)
% 95% significance contour, levels at -99 (fake) and 1 (95% signif)
hold on
contour(time,log2(period),sig95,[-99,1],'y');
hold on
% cone-of-influence, anything "below" is dubious
plot(time,log2(coi),'r')
hold off

%--- Plot global wavelet spectrum
subplot('position',[0.77 0.37 0.2 0.28])
plot(log10(global_ws),log2(period))
hold on
plot(log10(global_signif),log2(period),'--')
hold off
xlabel('Power (degC^2)')
title('c) Global Wavelet Spectrum')
set(gca,'YLim',log2([min(period),max(period)]), ...
	'YDir','reverse', ...
	'YTick',log2(Yticks(:)), ...
	'YTickLabel','')
set(gca,'XLim',[0,1.25*log10(max(global_ws))])

%--- Plot 1--5 hour scale-average time series
subplot('position',[0.1 0.07 0.65 0.2])
plot(time,scale_avg)
set(gca,'XLim',xlim(:))
xlabel('Time (year)')
ylabel('Avg variance (degC^2)')
title('d) 10-30 min Scale-average Time Series')
hold on
plot(xlim,scaleavg_signif+[0,0],'--')
hold off

% end of code