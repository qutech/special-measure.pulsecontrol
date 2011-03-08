function plsreadxval
% set xvals

global plsdata;

plsdata.xval = zeros(1, length(plsdata.pulses));

for i = 1:length(plsdata.pulses)
    plsdata.xval(i) = plsdata.pulses(i).xval(1);
end


