function awglist(ind)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;

if nargin < 1
    ind = 1:query(awgdata.awg, 'WLIS:SIZE?', '%s\n', '%i')-1;
elseif ind < 0
    ind = query(awgdata.awg, 'WLIS:SIZE?', '%s\n', '%i')+(ind:-1);
end

for i = ind
    wf = query(awgdata.awg, sprintf('WLIS:NAME? %d', i));
    if ~query(awgdata.awg, sprintf('WLIS:WAV:PRED? %s', wf), '%s\n', '%i')
        fprintf('%i: %s', i, wf);
    end
end

