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
    if strcmp(input('Pulse Exists. Overwrite? (yes/[no])? ','s'), 'yes') == 0
      return;
    else
    plsdata.pulses(plsnum) = orderfields(pulse, plsdata.pulses);
    end
else
    plsdata.pulses(plsnum) = pulse;
end

