function awggroups(ind)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;

if nargin < 1
    ind = 1:length(awgdata(1).pulsegroups);
end

for i = ind
    zl=plsinfo('zl',awgdata(1).pulsegroups(i).name);
    fprintf('%2i:  %-15s  (%3i pulses, %5.2f us, %d lines)\n', i, awgdata(1).pulsegroups(i).name, awgdata(1).pulsegroups(i).npulse(1), abs(zl(1)*1e-3),awgdata(1).pulsegroups(i).nline);
end
