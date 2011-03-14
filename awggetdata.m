function data = awggetdata(time)
% awgloaddata
% load latest awgdata file saved by awgsavedata.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global plsdata;

if nargin < 1 
    time = inf;
end

d = dir(sprintf('%sawgdata_*', plsdata.grpdir));
mi = find([d.datenum] < time, 1, 'last');
load([plsdata.grpdir, d(mi).name]);


