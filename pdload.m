function pd = pdload(name, opts)
%function pd = pdload(name, opts)
% Load most recent entry in a pulse dictionary.  Load the entire 
% dictionary if opts='all'
% if opts is a number, load the most recent dictionary before that.


% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

global plsdata;


if ~exist('opts','var')
    opts = '';
end


if isempty(strfind(opts,'all')) && ~isnumeric(opts)
  load([plsdata.grpdir, 'pd_', name,'_last']);
else
  load([plsdata.grpdir, 'pd_', name]);
  if isnumeric(opts)
     times=cellfun(@(x) getfield(x,'time'),pd);
     i=find(times < opts,1,'last');
     i
     pd=pd{i};
  end
end
    
return
