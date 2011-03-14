function pd = pdload(name, opts)
%function pd = pdload(name, opts)
% Load most recent entry in a pulse dictionary.  Load the entire 
% dictionary if opts='all'

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

global plsdata;

if ~exist('opts','var')
    opts = '';
end

load([plsdata.grpdir, 'pd_', name]);

if isempty(strfind(opts,'all'))
  pd=pd{end};  
end
    
return
