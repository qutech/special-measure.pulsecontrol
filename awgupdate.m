function awgupdate(groups)
% Obsolete! awgadd now also updates groups already loaded.
% awgupdate(groups)
% Change nrep or jump of previously loaded groups 
% Nothing done if fields don't exist.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global plsdata;
global awgdata;

awgcntrl('stop');

groups = awggrpind(groups);

for k = 1:length(groups)
    if isnan(groups)
        continue;
    end
    
    load([plsdata.grpdir, 'pg_', awgdata.pulsegroups(groups(k)).name]);

    if isfield(grpdef, 'pulseind')
        npls = length(grpdef.pulseind);
    else
        npls = size(zerolen, 1);
    end
    %awgdata.pulsegroups(groups(k)).npulse;
    startline = awgdata.pulsegroups(groups(k)).seqind + (grpdef.nrep(1) ~= Inf && isempty(strfind(grpdef.ctrl, 'notrig')));

    if isfield(grpdef, 'nrep')        
        for i = 1:npls
            ind = i-1 + startline;

            if grpdef.nrep(min(i, end)) == Inf  || grpdef.nrep(min(i, end)) == 0 ...
                || (i == npls && isempty(strfind(grpdef.ctrl, 'loop')) && all(grpdef.jump(1, :) ~= i))

                fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:LOOP:INF 1', ind));
            else
                fprintf(awgdata.awg, 'SEQ:ELEM%d:LOOP:INF 0', ind); % needed?
                fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:LOOP:COUN %d', ind, grpdef.nrep(min(i, end))));
            end

        end
    end

    if isfield(grpdef, 'jump')       
        % event jumps
        %SEQ:ELEM%d:JTARget:IND
        %SEQ:ELEM%d:JTARget:TYPE

        for j = 1:size(grpdef.jump, 2)
            fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:GOTO:IND %d', startline-1 + grpdef.jump(:, j)));
            fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:GOTO:STAT 1', startline-1 + grpdef.jump(1, j)));
        end
    end
    
    if ~exist('seqlog','var')
        seqlog=struct();
    end
    seqlog(end+1).time = now;
    seqlog(end).nrep = grpdef.nrep;
    seqlog(end).jump = grpdef.jump;

    save([plsdata.grpdir, 'pg_', awgdata.pulsegroups(groups(k)).name], '-append', 'seqlog');
    
    fprintf('Updated group %s on index %i. %s', grpdef.name, groups(k), query(awgdata.awg, 'SYST:ERR?'));
    logentry('Updated group %s on index %i.', grpdef.name, groups(k));
end
