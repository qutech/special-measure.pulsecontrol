function awgloaddata
% awgloaddata
% load latest awgdata file saved by awgsavedata.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;
global plsdata;

d = dir(sprintf('%sawgdata_*', plsdata.grpdir));
[mi, mi] = max([d.datenum]);
load([plsdata.grpdir, d(mi).name]);
if exist('awgdata','var') && isfield(awgdata,'awg')
  for a=1:length(awgdata)
     data(a).awg = awgdata(a).awg;
  end
end
awgdata = data;

