function awglist(ind,awg)
% function awglist([ind],[awg])
%   List the waveforms present on an awg.  If ind is absent, list all waveforms.
%   If ind is negative, list the last (-ind) waveforms.
% 
%   Awg specifies which awg in awgdata(i) to use, and defaults to 1.  Nominally
%   the output should not depend on awg.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;

if ~exist('awg','var') || isempty(awg)
    awg=1;
end

if nargin < 1
    ind = 1:query(awgdata(awg).awg, 'WLIS:SIZE?', '%s\n', '%i')-1;
elseif ind < 0
    ind = query(awgdata(awg).awg, 'WLIS:SIZE?', '%s\n', '%i')+(ind:-1);
end

for i = ind
    wf = query(awgdata(awg).awg, sprintf('WLIS:NAME? %d', i));
    if ~query(awgdata(awg).awg, sprintf('WLIS:WAV:PRED? %s', wf), '%s\n', '%i')
        fprintf('%i: %s', i, wf);
    end
end

