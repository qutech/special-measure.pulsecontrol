function plsnum = plsreg(pulse, plsnum)
% plsnum = plsreg(pulse, plsnum)
% 
% Adds pulse to plsdata.pulses.   
%
% The return value plsnum is the pulse index for the pulse.
% plsnum defaults to adding to the end.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global plsdata;

pulse = plsdefault(pulse);

if nargin < 2
    plsnum = length(plsdata.pulses) + 1;
end

% check format?

if ~isempty(plsdata.pulses)
    plsdata.pulses(plsnum) = orderfields(pulse, plsdata.pulses);
else
    plsdata.pulses(plsnum) = pulse;
end

