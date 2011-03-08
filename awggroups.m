function awggroups(ind)

global awgdata;

if nargin < 1
    ind = 1:length(awgdata.pulsegroups);
end

for i = ind
    zl=plsinfo('zl',awgdata.pulsegroups(i).name);
    fprintf('%2i:  %-15s  (%3i pulses, %5.2f us)\n', i, awgdata.pulsegroups(i).name, awgdata.pulsegroups(i).npulse(1), abs(zl(1)*1e-3));
end