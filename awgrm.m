function awgrm(grp, ctrl)
% awgrm(grp, ctrl)
% grp: 'all' or group name
% ctrl: 'after' remove all following groups
% (otherwise, specified group is removed by removing it and following ones
% and then reloading the latter.

global awgdata;


if strcmp(grp, 'all')
    awgcntrl('stop');
    fprintf(awgdata.awg, 'SEQ:LENG 0');
    awgdata.pulsegroups = [];
    awgdata.seqpulses = [];
    awgsavedata;
    return;
end

grp = awggrpind(grp); %strmatch(grp, strvcat(awgdata.pulsegroups.name), 'exact');
grp(2:end) = [];
if isnan(grp)
    return;
end
  
awgcntrl('stop');

if exist('ctrl','var') && strfind(ctrl, 'after')
    fprintf(awgdata.awg, 'SEQ:LENG %d', awgdata.pulsegroups(grp).seqind-1 + sum(awgdata.pulsegroups(grp).npulse));
    awgdata.seqpulses(awgdata.pulsegroups(grp).seqind + sum(awgdata.pulsegroups(grp).npulse):end) = [];
    awgdata.pulsegroups(grp+1:end) = [];
    % may miss trigger line.
    return;
end

fprintf(awgdata.awg, 'SEQ:LENG %d', awgdata.pulsegroups(grp).seqind-1);
awgdata.seqpulses(awgdata.pulsegroups(grp).seqind:end) = [];
groups = {awgdata.pulsegroups(grp+1:end).name};
awgdata.pulsegroups(grp:end) = [];
% log unloading here if necessary
awgadd(groups);
