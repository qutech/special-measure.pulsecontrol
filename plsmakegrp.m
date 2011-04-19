function grpdef = plsmakegrp(name, ctrl, ind)
% grpdef = plsmakegrp(name, ctrl, ind)
% Covert pulses in pulsegroup to wf format.
% name: group name.
% ctrl: 'plot', 'check', 'upload'
%       for maintenance/debugging: 'clrzero', 'local'.
%       These may mess with the upload logging, so use with care.
% ind: optional pulse index. The default is pulseind or all pulses.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global plsdata;
global awgdata;

if nargin < 2
    ctrl = '';
end

if ~iscell(name)
    name = {name};
end
            
for k = 1:length(name)
    if(~isstruct(name{k}))
       zerolen = []; % avoid using zerolen from previous group.
       load([plsdata.grpdir, 'pg_', name{k}]);
    else
       grpdef=name{k};
    end
           
    if strfind(grpdef.ctrl, 'seq')
        fprintf('Sequence joined groups: %s\n',sprintf('%s ',grpdef.pulses.groups{:}));
        for m = 1:length(grpdef.pulses.groups)
            if ~exist('ind','var')
            plsmakegrp(grpdef.pulses.groups{m},ctrl);
            else
            plsmakegrp(grpdef.pulses.groups{m},ctrl,ind);
            end
        end    
        return;
    end
       
    pack = ~isempty(strfind(grpdef.ctrl,'pack'));
    
    if ~ isfield(grpdef, 'varpar')
        grpdef.varpar = [];
    end
    if ~ isfield(grpdef, 'params')
        grpdef.params = [];
    end
    
    switch grpdef.ctrl(1:min([end find(grpdef.ctrl == ' ', 1)-1]))
        
        case 'pls'
            
            grpdef.pulses = plsdefault(grpdef.pulses);
            
            npar = max(1, size(grpdef.varpar, 1));
            
            plsdef = grpdef.pulses;%(ind);
            
            if nargin < 3 || isempty(ind)
                if isfield(grpdef, 'pulseind')
                    ind = unique(grpdef.pulseind);
                else
                    ind = 1:length(plsdef)*npar;
                end
                
            end
            
            grpdef.pulses(length(ind)+1:end) = [];
            
            for m = 1:length(ind)
                
                i = floor((ind(m)-1)/npar)+1;
                j = mod(ind(m)-1, npar)+1;
                
                % transfer valid pulse dependent parameters. Interpretation of nan may not be so useful here,
                % but should not hurt.
                params = grpdef.params;
                if ~isempty(grpdef.varpar)
                    mask = ~isnan(grpdef.varpar(j, :));
                    params(end-size(grpdef.varpar, 2) + find(mask)) = grpdef.varpar(j, mask);
                end
                
                if ~isempty(plsdef(i).trafofn)
                    params = plsdef(i).trafofn(params);
                end
                
                % Apply dictionary before varpars; avoids many random bugs.
                if isfield(grpdef,'dict') && ~isempty(grpdef.dict) && strcmp(plsdef(i).format,'elem')
                    plsdef(i)=pdapply(grpdef.dict, plsdef(i));
                end                
                mask = ~isnan(params);
                % update parameters - could move to plstowf
                if ~isempty(plsdef(i).pardef)
                    switch plsdef(i).format
                        case 'elem'
                            pardef = plsdef(i).pardef;
                            for n = 1:size(pardef, 1)
                                if isnan(params(n))
                                    continue;
                                end
                                if pardef(n, 2) < 0
                                    plsdef(i).data(pardef(n, 1)).time(-pardef(n, 2)) = params(n);
                                else
                                    plsdef(i).data(pardef(n, 1)).val(pardef(n, 2)) = params(n);
                                end
                            end
                            
                        case 'tab'
                            pardef = plsdef(i).pardef;
                            for n = 1:size(pardef, 1)
                                if isnan(params(n))
                                    continue;
                                end
                                if pardef(n, 1) < 0
                                    plsdef(i).data.marktab(pardef(n, 2), -pardef(n, 1)) = params(n);
                                else
                                    plsdef(i).data.pulsetab(pardef(n, 2), pardef(n, 1)) = params(n);
                                end
                            end
                            
                        otherwise
                            error('Parametrization of pulse format ''%s'' not implemented yet.', plsdef(i).format);
                    end
                end
                
                grpdef.pulses(m) = plstowf(plsdef(i));
                
                
                if ~isempty(grpdef.varpar)
                    grpdef.pulses(m).xval = [grpdef.varpar(j, end:-1:1), grpdef.pulses(m).xval];
                end
            end
            
        case 'grp'
            
            groupdef = grpdef.pulses;
            grpdef.pulses = struct([]);
            
            nchan = size(grpdef.matrix, 2); % # input channels to matrix
            
            %         if ~isfield(groupdef, 'chan')
            %             [groupdef.chan] = deal(length(groupdef.groups), nan(nchan));
            %         end
            %
            %         if ~isfield(groupdef, 'markchan')
            %             groupdef.markchan = groupdef.chan;
            %         end
            
            
            for j = 1:length(groupdef.groups)
                pg = plsmakegrp(groupdef.groups{j});
                
                if ~isfield(pg, 'pulseind') %|| some flag set to apply pulseind after adding, same for all groups
                    pg.pulseind = 1:length(pg.pulses);
                end
                
                % probably pointless code:
                %                 if j == 1  % set defaults from pg(1)
                %                     if nargin < 3
                %                         ind = 1:length(pg.pulses);
                %                     end
                %                 end
                %                 pg.pulses = pg.pulses(ind);
                
                
                
                % target channels for j-th group
                if isfield(groupdef, 'chan')
                    chan = groupdef.chan(j, :);
                else
                    chan = pg.chan;
                end
                mask = chan > 0;
                chan(~mask) = [];
                
                % target channels for markers
                if ~isfield(groupdef, 'markchan')
                    markchan = chan;
                else
                    markchan = groupdef.markchan(j, :);
                end
                markmask = markchan > 0;
                markchan(~markmask) = [];
                
                %ind not given to recursive call above, so plsmagegrp makes all pulses, specified by pulseind or default
                % of source group. Need to reconstruct indices as used for file names by inverting unique
                [pind, pind, pind] = unique(pg.pulseind);
                
                for i = 1:length(pg.pulseind)
                    if j == 1 % first pf determines size
                        grpdef.pulses(i).data.wf = zeros(nchan, size(pg.pulses(pind(i)).data.wf, 2));
                        grpdef.pulses(i).data.marker = zeros(nchan, size(pg.pulses(pind(i)).data.wf, 2), 'uint8');
                        grpdef.pulses(i).xval = [];
                        grpdef.pulses(i).data.readout = pg.pulses(pind(i)).data.readout; % a bit of a hack.
                    else
                        for ii=1:size(pg.pulses(pind(i)).data.readout,1)                            
                            roi=find(grpdef.pulses(pind(i)).data.readout(:,1) == pg.pulses(pind(i)).data.readout(ii,1));
                            if ~isempty(roi)
                                grpdef.pulses(pind(i)).data.readout(roi(1),2:3) = pg.pulses(pind(i)).data.readout(ii,2:3);
                            else
                                grpdef.pulses(pind(i)).data.readout(end+1,:) = pg.pulses(pind(i)).data.readout(ii,1:3);
                            end
                        end
                    end
                    
                    grpdef.pulses(i).data.wf(chan, :) = grpdef.pulses(i).data.wf(chan, :) + pg.pulses(pind(i)).data.wf(mask, :);
                    grpdef.pulses(i).data.marker(markchan, :) = bitor(grpdef.pulses(i).data.marker(markchan, :), ...
                        pg.pulses(pind(i)).data.marker(markmask, :));
                    grpdef.pulses(i).xval = [grpdef.pulses(i).xval, pg.pulses(pind(i)).xval];
                end
            end
            
            if nargin < 3
                ind = 1:length(grpdef.pulses);
            else
                grpdef.pulses = grpdef.pulses(ind);
            end
            
            [grpdef.pulses.format] = deal('wf');
            
            %grpdef = rmfield(grpdef, 'groups', 'matrix', 'offset');
        case 'grpcat'
            
            groupdef = grpdef.pulses;
            grpdef.pulses = struct([]);
            
            nchan = size(grpdef.matrix, 2); % # input channels to matrix
            
            %         if ~isfield(groupdef, 'chan')
            %             [groupdef.chan] = deal(length(groupdef.groups), nan(nchan));
            %         end
            %
            %         if ~isfield(groupdef, 'markchan')
            %             groupdef.markchan = groupdef.chan;
            %         end
            
            for j = 1:length(groupdef.groups)
                pg = plsmakegrp(groupdef.groups{j});
                grpdef.pulses = [grpdef.pulses pg.pulses];
            end
            [grpdef.pulses.format] = deal('wf');
            ind=1:length(grpdef.pulses);
            %grpdef = rmfield(grpdef, 'groups', 'matrix', 'offset');
        otherwise
            error('Group control %s not understood.\n',grpdef.ctrl);
    end
    
    if isfield(grpdef, 'xval') && ~isempty(grpdef.xval)
        for i=1:length(grpdef.pulses)
            grpdef.pulses(i).xval = [grpdef.xval grpdef.pulses(i).xval];
        end
    end
    
    for i = 1:length(ind)
        grpdef.pulses(i).data.wf = grpdef.matrix * (grpdef.pulses(i).data.wf + ...
            repmat(grpdef.offset, 1, size(grpdef.pulses(i).data.wf, 2)));
        if isfield(grpdef, 'trafofn') && ~isempty(grpdef.trafofn)
            wf=grpdef.pulses(i).data.wf;
            fn=grpdef.trafofn.func;
            args=grpdef.trafofn.args;
            for matlab_scoping_sucks=1:size(grpdef.pulses(i).data.wf,1)
                wf(matlab_scoping_sucks,:) = ...
                    fn(wf(matlab_scoping_sucks,:),matlab_scoping_sucks,args);
            end
            grpdef.pulses(i).data.wf=wf;
        end
        if isfield(grpdef, 'markmap')
            md = grpdef.pulses(i).data.marker;
            grpdef.pulses(i).data.marker = zeros(size(grpdef.matrix, 1), size(md, 2), 'uint8');
            grpdef.pulses(i).data.marker(grpdef.markmap(2, :), :) = md(grpdef.markmap(1, :), :);
        end
    end
    
    grpdef.ctrl = ['pls', grpdef.ctrl(find(grpdef.ctrl == ' ', 1):end)];
    
    
    switch ctrl(1:min([end find(ctrl == ' ', 1)-1]))
        case 'plot'
            if isfield(grpdef,'dict') && ~isempty(grpdef.dict)
                plsplot(grpdef.pulses,grpdef.dict,ctrl);
            else
                plsplot(grpdef.pulses,[],ctrl);
            end
            
        case 'check'
            
            for i = 1:length(ind)
                if any(abs(grpdef.pulses(i).data.wf(:)) > awgdata.scale)
                    fprintf('Pulse %i exceeds range.\n', i);
                end
            end

        case 'upload'
            if ~isempty(strfind(ctrl, 'force')) || plslog(end).time(end) < lastupdate
                %  modified since last upload (or upload forced)

                % A little naughty; secretly pack all the pulse waveforms together for load...
                if pack
                   if any(~strcmp('wf',{grpdef.pulses.format}))
                       error('Pack can only deal with waveforms.');
                   end
                   packdef = grpdef;
                   packdef.pulses=[];
                   packdef.pulses(1).format='wf';
                   data=[grpdef.pulses.data];                   
                   packdef.pulses(1).data.marker = [data.marker];
                   packdef.pulses(1).data.wf = [data.wf];
                   % awgload/zero doesn't use anything else.
                else
                   packdef = grpdef; 
                end
                  
                if isempty(zerolen) || ~isempty(strfind(ctrl, 'clrzero'))
                    zerolen = zeros(length(packdef.pulses), length(packdef.chan));
                end
                
                if isempty(strfind(ctrl, 'local'))
                    zerolen  = awgload(packdef, ind, zerolen);
                else
                    zerolen = awgzero(packdef, ind, zerolen);
                end
                
                if pack
                    zerolen=repmat(zerolen(1,:)/length(grpdef.pulses),length(grpdef.pulses),1);
                end
                
                % save update time in log.
                plslog(end+1).time = now;
                plslog(end).params = grpdef.params;
                plslog(end).matrix = grpdef.matrix;
                plslog(end).varpar = grpdef.varpar;
                plslog(end).offset = grpdef.offset;
                
                if isfield(grpdef, 'dict')
                  plslog(end).dict = grpdef.dict;
                end
    
                if isfield(grpdef, 'trafofn')
                    plslog(end).trafofn = grpdef.trafofn;
                end

                if length(plslog) > 2 % copy in case not all pulses updated. First plslog has no xval
                    plslog(end).xval = plslog(end-1).xval;
                end                
                %plslog(end).xval(:, ind) = vertcat(grpdef.pulses.xval)';
                plslog(end).xval = vertcat(grpdef.pulses.xval)'; % temporary bug fix
                plslog(end).ind = ind;
                
                save([plsdata.grpdir, 'pg_', name{k}], '-append', 'plslog', 'zerolen');
                logentry('Uploaded group %s, revisions %i.', grpdef.name, length(plslog));
                fprintf(' in upload of group %s.\n', grpdef.name);
            else
                fprintf('Skipping group %s.\n', grpdef.name);
            end

    end
end
