function pd = pdload(name, opts)
%function pd = pdload(name, opts)
% Load most recent entry in a pulse dictionary.  Load the entire 
% dictionary if opts='all'

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

global plsdata;

if ~exist('opts','var')
    opts = '';
end

if isempty(strfind(opts,'all'))
  load([plsdata.grpdir, 'pd_', name,'_last']);
else
  load([plsdata.grpdir, 'pd_', name]);
end
    
return
