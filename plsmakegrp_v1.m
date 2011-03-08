function grpdef = plsmakegrp(name, ctrl, ind)
% grpdef = plsmakegrp(name, ctrl, ind)
% Covert pulses in pulsegroup to wf format.
% name: group name.
% ctrl: 'plot', 'check', 'upload'
%       for maintenance/debugging: 'clrzero', 'local'.
%       These may mess with the upload logging, so use with care.
% ind: optional pulse index

global plsdata;
global awgdata;

if nargin < 2
    ctrl = '';
end

if ~iscell(name)
    name = {name};
end

for k = 1:length(name)
    
    zerolen = []; % avoid using zerolen from previous group.
    load([plsdata.grpdir, 'pg_', name{k}]);

    switch grpdef.ctrl(1:min([end find(grpdef.ctrl == ' ', 1)-1]))

        case 'par'
            if nargin < 3
                ind = 1:size(grpdef.pulses.varpar, 1);
            end

            % get template from database
            if ~isstruct(grpdef.pulses.template)
                grpdef.pulses.template = plsdata(grpdef.pulses.template);
            end
            %while strcmp(grpdef.pulses.pulse.format, 'ind')
            %   grpdef.pulses.pulse = plsdata(grpdef.pulses.pulse.data);
            %end
            plsdef = grpdef.pulses;
            plsdef.template = plsdefault(plsdef.template);

            %grpdef.pulses = struct;

            for i = 1:length(ind)

                % transfer valid pulse dependent parameters. Interpretation of nan may not be so useful here,
                % but should not hurt.
                mask = ~isnan(plsdef.varpar(i, :));
                params = plsdef.params;
                params(end-size(plsdef.varpar, 2)+find(mask)) = plsdef.varpar(i, mask);

                if isfield(plsdef.template, 'trafofn') && ~isempty(plsdef.template.trafofn)
                    params = plsdef.template.trafofn(params);
                end

                % update parameters
                switch plsdef.template.format
                    case 'elem'
                        pardef = plsdef.template.pardef;
                        for j = 1:size(pardef, 1)
                            if plsdef.template.pardef(j, 2) < 0
                                plsdef.template.data(pardef(j, 1)).time(-pardef(j, 2)) = params(j);
                            else
                                plsdef.template.data(pardef(j, 1)).val(pardef(j, 2)) = params(j);
                            end
                        end

                    otherwise
                        error('Parametrization of pulse format ''%s'' not implemented yet.', params.pulses.format);
                end

                if i == 1
                    grpdef.pulses = plstowf(plsdef.template);
                else
                    grpdef.pulses(i) = plstowf(plsdef.template);
                end
                grpdef.pulses(i).xval = [plsdef.varpar(i, :), plsdef.template.xval];
            end

        case 'pls'

            if nargin < 3
                ind = 1:length(grpdef.pulses);
            end

            grpdef.pulses = plsdefault(grpdef.pulses(ind));
            for i = 1:length(ind)
                grpdef.pulses(i) = plstowf(grpdef.pulses(i));
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

                if j == 1  % set defaults from pg(1)
                    if nargin < 3
                        ind = 1:length(pg.pulses);
                    end
                end

                pg.pulses = pg.pulses(ind);

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

                for i = 1:length(ind)
                    if j == 1 % first pf determines size
                        grpdef.pulses(i).data.wf = zeros(nchan, size(pg.pulses(i).data.wf, 2));
                        grpdef.pulses(i).data.marker = zeros(nchan, size(pg.pulses(i).data.wf, 2), 'uint8');
                        grpdef.pulses(i).xval = [];
                    end

                    grpdef.pulses(i).data.wf(chan, :) = grpdef.pulses(i).data.wf(chan, :) + pg.pulses(i).data.wf(mask, :);
                    grpdef.pulses(i).data.marker(markchan, :) = bitor(grpdef.pulses(i).data.marker(markchan, :), pg.pulses(i).data.marker(markmask, :));
                    grpdef.pulses(i).xval = [grpdef.pulses(i).xval, pg.pulses(i).xval];
                end
            end

            [grpdef.pulses.format] = deal('wf');

            %grpdef = rmfield(grpdef, 'groups', 'matrix', 'offset');
    end


    for i = 1:length(ind)
        grpdef.pulses(i).data.wf = grpdef.matrix * (grpdef.pulses(i).data.wf + ...
            repmat(grpdef.offset, 1, size(grpdef.pulses(i).data.wf, 2)));

        if isfield(grpdef, 'markmap')
            md = grpdef.pulses(i).data.marker;
            grpdef.pulses(i).data.marker = zeros(size(grpdef.matrix, 1), size(md, 2), 'uint8');
            grpdef.pulses(i).data.marker(grpdef.markmap(2, :), :) = md(grpdef.markmap(1, :), :);
        end
    end

    grpdef.ctrl = ['pls', grpdef.ctrl(find(grpdef.ctrl == ' ', 1):end)];


    switch ctrl(1:min([end find(ctrl == ' ', 1)-1]))
        case 'plot'
            plsplot(grpdef.pulses);

        case 'check'

            for i = 1:length(ind)
                if any(abs(grpdef.pulses(i).data.wf) > awgdata.scale)
                    fprintf('Pulse %i exceeds range.\n', i);
                end
            end

        case 'upload'
            if logdata(end).time < lastupdate || ~isempty(strfind(ctrl, 'force'))
                %  modified since last upload (or upload forced)

                if isempty(zerolen) || ~isempty(strfind(ctrl, 'clrzero'))
                    zerolen = zeros(length(grpdef.pulses), length(grpdef.chan));
                end
                
                if isempty(strfind(ctrl, 'local'))
                    zerolen  = awgload(grpdef, ind, zerolen);
                else
                    zerolen = awgzero(grpdef, ind, zerolen);
                end
                
                switch grpdef.ctrl(1:min([end find(grpdef.ctrl == ' ', 1)-1]));
                    case 'par'
                        lp = plsdef.params;

                    case 'pls'
                        lp = [];

                    case 'grp'
                        if isfield(groupdef, 'matrix');
                            lp.matrix = groupdef.matrix;
                        end
                        if isfield(groupdef, 'offset');
                            lp.offset = groupdef.offset;
                        end
                end
                % save update time in log.
                logdata(end+1).time = now;
                logdata(end).params = lp;
                if length(logdata) > 2 % copy in case not all pulses updated. First logdata has no xval
                    logdata(end).xval = logdata(end-1).xval;
                end
                logdata(end).xval(:, ind) = vertcat(grpdef.pulses.xval)';
                logdata(end).ind = ind;
                
                save([plsdata.grpdir, 'pg_', name{k}], '-append', 'logdata', 'zerolen');
                logentry('Uploaded group %s.', grpdef.name);
                fprintf('Uploaded group %s.\n', grpdef.name);
            else
                fprintf('Skipping group %s.\n', grpdef.name);
            end

    end
end
