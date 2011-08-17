function awgnpulse(groups, npulse)
% awgnpulse(groups, npulse)
% Set npulse for pulsegroups.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;
groups = awggrpind(groups);

for a=1:length(awgdata)
    
    for i = 1:length(groups)
        pg.name = awgdata(a).pulsegrous(groups(i)).name;
        pg.npulse = npulse(min(i, end));
        pulseupdate(pg);
        awgadd(groups(i));
    end
    
end
