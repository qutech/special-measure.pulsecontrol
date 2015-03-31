function rm(self,grp, ctrl)
% awgrm(grp, ctrl)
% grp: 'all' or group name
% ctrl: 'after' remove all following groups
% (otherwise, specified group is removed by removing it and following ones
% and then reloading the latter.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


if strcmp(grp, 'all')
    self.control('stop');
    
    fprintf(self.handle, 'SEQ:LENG 0');
    self.pulsegroups = [];
    self.seqpulses = [];

    self.savedata();
    return;
end

grp = self.grpind(grp); %strmatch(grp, strvcat(awgdata.pulsegroups.name), 'exact');
grp(2:end) = [];
if isnan(grp)
    return;
end
  
self.control('stop');

if exist('ctrl','var') && strfind(ctrl, 'after')

  fprintf(self.handle, 'SEQ:LENG %d', self.pulsegroups(grp).seqind-1 + sum(self.pulsegroups(grp).nline));
  self.seqpulses(self.pulsegroups(grp).seqind + sum(self.pulsegroups(grp).npulse):end) = [];
  self.pulsegroups(grp+1:end) = [];

    % may miss trigger line.
    return;
end

fprintf(self.handle, 'SEQ:LENG %d', self.pulsegroups(grp).seqind-1); 
self.seqpulses(self.pulsegroups(grp).seqind:end) = [];
groups = {self.pulsegroups(grp+1:end).name};
self.pulsegroups(grp:end) = [];

% log unloading here if necessary
self.add(groups);
