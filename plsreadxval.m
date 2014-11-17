function plsreadxval
% set xvals

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global plsdata;

plsdata.xval = zeros(1, length(plsdata.pulses));

for i = 1:length(plsdata.pulses)
    plsdata.xval(i) = plsdata.pulses(i).xval(1);
end


