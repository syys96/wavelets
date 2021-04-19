clear; clc;

seq = [1,2,3,NaN,5,NaN,7];

times = 1:length(seq);
mask =  ~isnan(seq);
nseq = seq;
nseq(~mask) = interp1(times(mask), seq(mask), times(~mask));