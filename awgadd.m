function awgadd(groups)
% awgadd(groups)
% Add groups to end of sequence. Store group name and target index in 
% awgdata.pulsgroups.name, seqind.
% For sequence combined groups (only), pulseind is a 2D array.  Each
% row corresponds to a groups, each column to a varpar in this group.
% ie, pulseind = [ 1 1 1 1 ; 1 2 3 4] will use pls 1 from group 1, pulse
% 1-4 on group 2.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

global plsdata;
global awgdata;
astart=toc;
awgcntrl('clr');
awgcntrl('stop');

if ~iscell(groups)
    groups = {groups};
end

dosave = false; % keeps track of whether awgdata changed.

for k = 1:length(groups)
    gstart=toc;
    load([plsdata.grpdir, 'pg_', groups{k}]);

    while plsinfo('stale',groups{k})
        fprintf('Latest pulses of group %s not loaded; %s > %s.\n', groups{k}, ...
            datestr(lastupdate), datestr(plslog(end).time(end)));
        tstart=toc;
        plsmakegrp(groups{k},'upload');
        ts2 = toc;
        awgcntrl('wait');
        fprintf('Load time=%f secs, wait time=%f\n',toc-tstart,toc-ts2);
        load([plsdata.grpdir, 'pg_', groups{k}]);        
    end

        
    if strcmp(grpdef.ctrl(1:min([end find(grpdef.ctrl == ' ', 1)-1])), 'grp')...
            && ~isempty(strfind(grpdef.ctrl, 'seq')) % combine groups at sequence level.

        % retrieve channels of component groups
        clear chan;
        for m = 1:length(grpdef.pulses.groups)            
            gd=plsinfo('gd', grpdef.pulses.groups{m});
            rf={'varpar'}; % Required fields that may be missing
            for qq=1:length(rf)
                if ~isfield(gd,rf{qq})
                    gd=setfield(gd,rf{qq},[]);
                end
            end
            chan(m) = orderfields(gd);
        end    
        chan = {chan.chan};
        seqmerge = true;
    else
        if ~isfield(grpdef, 'pulseind')
            grpdef.pulseind = 1:size(zerolen, 1);
        end

        seqmerge = false;
    end
    
    nchan = length(awgdata.chans); % alternatively use awgdata or data size

    if ~isfield(grpdef, 'nrep')
        grpdef.nrep = 1;
    end

    npls = size(grpdef.pulseind, 2);
    
    if ~isfield(grpdef, 'jump')
        if strfind(grpdef.ctrl, 'loop')
            grpdef.jump = [npls; 1];
        else
            grpdef.jump = [];
        end
    end

    usetrig = (grpdef.nrep(1) ~= Inf) && isempty(strfind(grpdef.ctrl, 'notrig'));

    if isempty(awgdata.pulsegroups)
        startline = 1;
        gind = [];
    else
        gind = strmatch(grpdef.name, {awgdata.pulsegroups.name}, 'exact');
        if ~isempty(gind)
            startline = awgdata.pulsegroups(gind(1)).seqind;
            if npls + usetrig ~= sum(awgdata.pulsegroups(gind(1)).npulse);
                error('Number of pulses changed in group %s. Use awgrm first!', grpdef.name);
            end
        else
            startline = awgdata.pulsegroups(end).seqind + sum(awgdata.pulsegroups(end).npulse);
        end
    end
    if isempty(gind) % group not loaded yet, extend sequence 
        fprintf(awgdata.awg, sprintf('SEQ:LENG %d', startline + usetrig + npls - 1));
        gind = length(awgdata.pulsegroups)+1;        
        awgdata.pulsegroups(gind).name = grpdef.name;
        awgdata.pulsegroups(gind).seqind = startline;
        awgdata.pulsegroups(gind).npulse = [npls usetrig];
        dosave = 1;
    elseif any(awgdata.pulsegroups(gind).nrep ~= grpdef.nrep) % nrep changed
        dosave = 1;
    end
    awgdata.pulsegroups(gind).nrep = grpdef.nrep;
    
    if usetrig
        fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:WAV1 "trig_%08d"', startline, awgdata.triglen));
        for j = 2:nchan 
            fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d"', startline, j, awgdata.triglen));
        end
    end
    

    
    for i = 1:npls
        ind = i-1 + startline + usetrig;
        if ~seqmerge % pulses combined here.
            for j = 1:nchan
                if any(j == grpdef.chan) &&  zerolen(grpdef.pulseind(i), find(j == grpdef.chan)) < 0
                    % channel in group and not zero
                    fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:WAV%d "%s_%05d_%d"', ind, awgdata.chans(j), ...
                        grpdef.name, grpdef.pulseind(i), find(j == grpdef.chan)));
                else
                    fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d"', ind, awgdata.chans(j), ...
                        abs(zerolen(grpdef.pulseind(i), 1))));
                end
            end
        else
            for m = 1:length(grpdef.pulses.groups)
                for j = 1:length(chan{m}) % channels of component groups
                    %if 1 % zero replacement not implemented
                    fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:WAV%d "%s_%05d_%d"', ind, awgdata.chans(chan{m}(j)), ...
                        grpdef.pulses.groups{m}, grpdef.pulseind(m, i), j));
                    %else
                        %fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d"', ind, awgdata.chans(j), ...
                        %    abs(zerolen(grpdef.pulseind(i), 1))));
                    %end
                end
            end
        end
        if grpdef.nrep(min(i, end)) == Inf  || grpdef.nrep(min(i, end)) == 0 ...
                || (i == npls && isempty(strfind(grpdef.ctrl, 'loop')) && (isempty(grpdef.jump) || all(grpdef.jump(1, :) ~= i)))
            fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:LOOP:INF 1', ind));
        else
            fprintf(awgdata.awg, 'SEQ:ELEM%d:LOOP:INF 0', ind); % default
            fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:LOOP:COUN %d', ind, grpdef.nrep(min(i, end))));
        end

        fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:GOTO:STAT 0', ind));
        
        if grpdef.nrep(min(i, end)) == Inf && isreal(grpdef.pulses) &&  ...
                (length(awgdata.seqpulses) < ind || awgdata.seqpulses(ind) ~= grpdef.pulses(grpdef.pulseind(i)));
            dosave = 1;
            awgdata.seqpulses(ind) = grpdef.pulses(grpdef.pulseind(i));
        end
        if ~mod(i, 100)
            fprintf('%i/%i pulses added.\n', i, npls);
        end
    end
    fprintf('Group load time: %g secs\n',toc-gstart);

    jstart=toc;
    % event jumps
    %SEQ:ELEM%d:JTARget:IND
    %SEQ:ELEM%d:JTARget:TYPE

    for j = 1:size(grpdef.jump, 2)
        fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:GOTO:IND %d', startline+usetrig-1 + grpdef.jump(:, j)));
        fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:GOTO:STAT 1', startline+usetrig-1 + grpdef.jump(1, j)));
    end
    
    if ~exist('seqlog','var')
        seqlog.time = now;
    else
        seqlog(end+1).time = now;
    end
    seqlog(end).nrep = grpdef.nrep;
    seqlog(end).jump = grpdef.jump;

    save([plsdata.grpdir, 'pg_', groups{k}], '-append', 'seqlog');
    fprintf('Jump program time: %f secs\n',toc-jstart);
    wstart=toc;
    awgcntrl('wait');
    fprintf('Wait time: %f secs; total time %f secs\n',toc-wstart,toc-astart);
    fprintf('Added group %s on index %i. %s', grpdef.name, gind, query(awgdata.awg, 'SYST:ERR?'));
    logentry('Added group %s on index %i.', grpdef.name, gind);
end
if dosave
    awgsavedata;
end
