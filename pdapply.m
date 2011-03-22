function [pulse changed]=pdapply(pd,pulse)
%function [pulse changed]=pdapply(pd, pulse)
% Apply a pulse dictionary to a pulse.  Return the new pulse.  Changed is
% true if the application was non-trivial

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

if ~strcmp(pulse.format,'elem')
    changed=0;
    return;
end

% If pd is a cell array, apply each dictionary in sequence.  This allows
% for some *neat* effects. :p
if iscell(pd)
   changed = 0;
   for i=1:length(pd)
     [pulse c2] = pdapply(pd{i},pulse)
     changed = changed || c2;
   end
   return;
end

if ischar(pd)
    pd=pdload(pd);
end

for i=1:length(pulse.data)
   if pulse.data(i).type(1) == '@' % dictionary pulse
     if(isfield(pd,pulse.data(i).type(2:end)))
        nel=getfield(pd,pulse.data(i).type(2:end));
        ot = ~isnan(pulse.data(i).time);
        ov = ~isnan(pulse.data(i).val);
        nel.time(ot)=pulse.data(i).time(ot);
        nel.val(ov)=pulse.data(i).val(ov);
        changed=1;
        pulse.data(i)=nel;
     end
   end
end
 
return
