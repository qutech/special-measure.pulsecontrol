function plsdefgrp(grpdef)
% pldefsgrp(grpdef)
% ctrl: ctrl string for useful default options.
% Starts with group type, then switches:
%        noloop 
%        notrig
%        cat 
%        seq
%
% nrep: rep counts, defaults to 1
% jump: overrides default jumps
% name: group (file) name
%
% chan: physical output channel list (or channels going into matrix)
% matrix: Compensation/linear combination matrix	
% 	    one col per input channel, one row per output channel.
% 	    Default = Identity.
% markmap: optional map for marker channels, first row is input channel, second
%           row the corresponding oputput channel.
% offset: added to pulse voltages before applying matrix. Default = 0; 
% dict: optional name of pulse dictionary to apply to elem style pulses.
% varpar: length(pulses) x m matrix with parameters varying between pulses,  
%           nan entries are ignored, used for last m parameters.
% params: vector with default and start parameters, length determines number of parameters.
% pulsedind: Optional index array determining which pulses will be used in a
%            sequence. Default all.
% xval: Optional xval to be prepended to pulse, varpar xvals.
% trafofn.func, trafofn.args ; called on each channel of data as
%                              func(wf,chan,args)
% type = 'grp'
%    pulses: struct with fields
%     groups: Cell array with group names
%     chan: Matrix with target channels for each group, 0 = ignore.
%           Row index is group index
% 	  Indices refer to columns of matrix. Default chan for source group.
%   
%
% type = 'pls'
%   pulses: struct array with pulses in std format.
%       Only 'elem' format (after database index substitution)  implemented for parametrization.
%       pardef: n x 2 matrix with pulsedef and data entry indices, 
%          -ve second indices refer to time, +ve ones val.
%       trafofn (optional): transforms given parameters into pulse parameters. (Can be a function or matrix.)
%

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


if length(grpdef) > 1
    for l=1:length(grpdef)
        plsdefgrp(grpdef(l));
    end
    return;
end

global plsdata;

file = [plsdata.grpdir, 'pg_', grpdef.name];

if exist(file, 'file') || exist([file, '.mat'], 'file')
    fprintf('File %s exists. Overwrite? (yes/no)', file);
    while 1
        str = input('', 's');
        switch str
            case 'yes'
                break;
            case 'no'
                return;
        end
    end
end

% set defaults
if ~isfield(grpdef, 'ctrl')
    grpdef.ctrl = [];
end
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

if isempty(strfind(grpdef.ctrl, 'seq'))
    
    if ~isfield(grpdef,'params')
        grpdef.params=[];
    end

    if ~isfield(grpdef, 'matrix') || isempty(grpdef.matrix)
        grpdef.matrix = eye(length(grpdef.chan));
    else
        if isfield(grpdef, 'chan')
            grpdef.matrix = grpdef.matrix(:, grpdef.chan);
            if ~isfield(grpdef, 'markmap')
                grpdef.markmap = [1:length(grpdef.chan); grpdef.chan];
            end
        end

        if isfield(grpdef, 'outchan')
            grpdef.chan = grpdef.outchan;
        else
            grpdef.chan =  1:size(grpdef.matrix, 1);
        end
    end

    if ~isfield(grpdef, 'offset') || isempty(grpdef.offset)
        grpdef.offset = zeros(size(grpdef.matrix, 2), 1);
    end
    
    if ~isfield(grpdef, 'dict')
        grpdef.dict=[];
    end
else
    if ~isfield(grpdef, 'pulseind')
        error('Pulseind must be specified with ''seq'' option.');
    end
    
    if size(grpdef.pulseind, 1) == 1
        grpdef.pulseind = repmat(grpdef.pulseind, length(grpdef.pulses.groups), 1);
    end

end


plslog.time = 0; % not loaded yet
lastupdate = now;

save(file,  'grpdef',  'plslog', 'lastupdate');
logentry('Created group %s.', grpdef.name);
