function awgrm(grp, ctrl)
% awgrm(grp, ctrl)
% grp: 'all' or group name
% ctrl: 'after' remove all following groups
% (otherwise, specified group is removed by removing it and following ones
% and then reloading the latter.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;


if strcmp(grp, 'all')
    awgcntrl('stop');
    for a=1:length(awgdata)
        fprintf(awgdata(a).awg, 'SEQ:LENG 0');
        awgdata(a).pulsegroups = [];
        awgdata(a).seqpulses = [];
    end
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
    for a=1:length(awgdata)
      fprintf(awgdata(a).awg, 'SEQ:LENG %d', awgdata(a).pulsegroups(grp).seqind-1 + sum(awgdata(a).pulsegroups(grp).nline));
      awgdata(a).seqpulses(awgdata(a).pulsegroups(grp).seqind + sum(awgdata(a).pulsegroups(grp).npulse):end) = [];
      awgdata(a).pulsegroups(grp+1:end) = [];
    end
    % may miss trigger line.
    return;
end
for a=1:length(awgdata)
  fprintf(awgdata(a).awg, 'SEQ:LENG %d', awgdata(a).pulsegroups(grp).seqind-1); 
  awgdata(a).seqpulses(awgdata(a).pulsegroups(grp).seqind:end) = [];
  groups = {awgdata(a).pulsegroups(grp+1:end).name};
  awgdata(a).pulsegroups(grp:end) = [];
end
% log unloading here if necessary
awgadd(groups);
