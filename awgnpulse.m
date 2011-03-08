function awgnpulse(groups, npulse)
% awgnpulse(groups, npulse)
% Set npulse for pulsegroups.

global awgdata;
groups = awggrpind(groups);
    
for i = 1:length(groups)
    pd.name = awgdata.pulsegrous(groups(i)).name;
    pg.npulse = npulse(min(i, end));    
    pulseupdate(pg);
    awgadd(groups(i));
end