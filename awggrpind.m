function grp = awggrpind(grp)
% function grpind = grpind(grp)
% Find group index from name of loaded group.

global awgdata;

if ischar(grp)
    grp = {grp};
end

if iscell(grp)   
    for i = 1:length(grp)
        grp{i} = max(strmatch(grp{i}, {awgdata.pulsegroups.name}, 'exact'));
        if isempty(grp{i})
            grp{i} = nan;
            fprintf('Group not loaded.\n');
            %error('Group not loaded.');
        end           
    end
    grp = cell2mat(grp);
elseif any(grp > length(awgdata.pulsegroups))
    error('Group index too large.');
end