clear; clc;

kp = load('kp_2015.mat').data;
ap = load('ap_2015.mat').data;
ae = load('ae_2015.mat').data;
ssn = load('ssn_2015.mat').data;
dst = load('dst_2015.mat').data;
f107 = load('f107_2015.mat').data;

date_st = 31 + 28 + 15;
date_ed = 31 + 28 + 19;
kp = kp((date_st-1)*24+1:(date_ed)*24);
ap = ap((date_st-1)*24+1:(date_ed)*24);
ae = ae((date_st-1)*24+1:(date_ed)*24);
ssn = ssn((date_st-1)*24+1:(date_ed)*24);
f107 = f107((date_st-1)*24+1:(date_ed)*24);
dst = dst((date_st-1)*24+1:(date_ed)*24);

subplot(7,1,1);
plot(1:120,kp);
subplot(7,1,2);
plot(1:120,ap);
subplot(7,1,3);
plot(1:120,ae);
subplot(7,1,4);
plot(1:120,ssn);
subplot(7,1,5);
plot(1:120,f107);
subplot(7,1,6);
plot(1:120,dst);
