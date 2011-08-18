function plsupdate(newdef)
% plsupdate(newdef)
% Update group parameters. (offset, matrix, params, varpar, trafofn; jump, nrep) 
% All other fields of the group definition struct are ignored.
% Their dimensions are not allowed to change to keep the group size the
% same. The current time is stored in lastupdate. Changing jump and nrep only
% (no other fields set) does not require reloading pulses.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

% Not implmented: Missing or nan entries of params are taken from previous values.

global plsdata;

if length(newdef) > 1
    if iscell(newdef)
        for l=1:length(newdef)
            plsupdate(newdef{l});
        end
    else        
        for l=1:length(newdef)
            plsupdate(newdef(l));
        end
    end
    return;
end

file = [plsdata.grpdir, 'pg_', newdef.name];
load(file);

plschng = false;

if isfield(newdef, 'offset')
    if length(newdef.offset) ~= length(grpdef.offset)
        error('Size of offset changed.');
    end
    grpdef.offset = newdef.offset;
    plschng = 1;
end

if isfield(newdef, 'matrix')
    if any(size(newdef.matrix) ~= size(grpdef.matrix))
        error('Size of matrix changed.');
    end
    grpdef.matrix = newdef.matrix;
    plschng = 1;
end

if isfield(newdef, 'dict')    
    grpdef.dict=newdef.dict;
    plschng=1;
end

if isfield(newdef, 'params')
    if length(newdef.params) ~= length(grpdef.params)
        error('Size of params changed.');
    end
    grpdef.params = newdef.params;
    plschng = 1;
end

if isfield(newdef, 'varpar')
    if any(size(newdef.varpar, 1) ~= size(grpdef.varpar, 1))
        error('Size of varpar changed.');
    end
    grpdef.varpar = newdef.varpar;
    plschng = 1;
end

if isfield(newdef, 'xval')
    grpdef.xval = newdef.xval;
    plschng = 1;
end

if isfield(newdef,'ctrl')
    grpdef.ctrl = newdef.ctrl;
    if isempty(grpdef.ctrl) || isempty(strmatch(grpdef.ctrl(1:min([end find(grpdef.ctrl == ' ', 1)-1])), {'pls', 'grp', 'grpcat'}))
    % format not given
    if ~isstruct(grpdef.pulses) || isfield(grpdef.pulses, 'data')
        grpdef.ctrl = ['pls ' grpdef.ctrl];
    elseif isfield(grpdef.pulses, 'groups')
        grpdef.ctrl = ['grp ' grpdef.ctrl];   
    else
        error('Invalid group format.');
    end
    end
    plschng = 1;
end

if isfield(newdef, 'trafofn')
    if isempty(newdef.trafofn) && isfield(newdef, 'trafofn')
        grpdef = rmfield(grpdef, 'trafofn');
    end
    grpdef.trafofn = newdef.trafofn;
    plschng = 1;
end

% some may not be valid for 'grp' groups
% allow channel changes?

% didn't want to log this, but should be able to log add it any time (only
% logged if given)
% if isfield(newdef, 'pulseind')
%     if any(size(newdef.pulseind) ~= size(grpdef.pulseind))
%         error('Size of pulseind changed.');
%     end
%     grpdef.pulseind = newdef.pulseind;
% end

%if isfield(newdef, 'pulseind') % currently not updateable
%    grpdef.pulseind = newdef.pulseind;
%end

if isfield(newdef, 'nrep')
    plschng = 1;
    grpdef.nrep = newdef.nrep;
end

if isfield(newdef, 'jump')
    plschng = 1;
    grpdef.jump = newdef.jump;
end


if plschng % pulses changed
    lastupdate = now;
    save(file, '-append', 'grpdef', 'lastupdate');
    logentry('Updated group %s.', grpdef.name);
    ind = awggrpind(grpdef.name);
    
    if ~isnan(ind)
        awgdata.pulsegroups(ind).lastupdate=now;
    end
else
    fprintf('Didn''t update group "%s": nothing changed\n',grpdef.name);
end

%fprintf('Updated group %s.\n', grpdef.name);
