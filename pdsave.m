function pd=pdsave(dict, val)
%function pd=pdsave(dict, val)
% Save a new version of a pulse dictionary.  Old entries are retained for
% documentation purposes.  The pulse dictionary with the time field added
% is returned.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global plsdata;

fn=[plsdata.grpdir, 'pd_', dict,'.mat'];
if exist(fn,'file')
  try
    load(fn);
  catch
    pd={};
  end
else
  pd={};
end

pd{end+1}=val;
pd{end}.time=now;

save(fn,'pd');
pd=pd{end};

fn=[plsdata.grpdir, 'pd_', dict,'_last.mat'];
save(fn,'pd');
% Fixme; there should be code to find loaded groups that need updating
% here.
    
return
