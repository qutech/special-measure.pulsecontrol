function grp = awggrpind(grp)
% function grpind = grpind(grp)
% Find group index from name of loaded group.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;

if ischar(grp)
    grp = {grp};
end

if ~isfield(awgdata(1).pulsegroups,'name')
    names={};
else
    names={awgdata(1).pulsegroups.name};
end

if iscell(grp)   
    for i = 1:length(grp) 
        grp{i} = max(strmatch(grp{i}, names, 'exact'));
        if isempty(grp{i})
            grp{i} = nan;
            %fprintf('Group not loaded.\n');
            %error('Group not loaded.');
        end           
    end
    grp = cell2mat(grp);
elseif any(grp > length(awgdata(1).pulsegroups))
    awgerror('Group index too large.');
end
