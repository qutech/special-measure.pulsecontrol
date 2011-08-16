function [pd]=pdpreload(pd, time)
%function [pd]=pdpreload(pd, time)
% replace any dictionaries in pd with the contents of the dictionary.  Judicous
% use can vastly speed up pulse dictionaries
% time, if specified, gives the effective time to load the dictionary at.

if ~exist('time','var')
    time=[];
end

if iscell(pd)
   for i=1:length(pd)
     pd{i} = pdpreload(pd{i},time);
   end
   return;
end

if ischar(pd)
    pd=pdload(pd,time);
end
end

