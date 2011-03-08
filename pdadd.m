function pd2=pdadd(dict, name, val)
%function pd=pdadd(dict, name, val)
% Add a pulse to a dictionary.  The new complete dictionary is returned.
global plsdata;

fn=[plsdata.grpdir, 'pd_', dict, '.mat'];
if exist(fn,'file')
  load(fn);
  pd=setfield(pd{end},name,val);
else
  pd=struct(name,val);
end

pd2=pdsave(dict,pd);
 
return