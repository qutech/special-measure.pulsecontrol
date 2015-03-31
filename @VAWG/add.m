function add(self,groups)
% awgadd(groups)
% Add groups to end of sequence. Store group name and target index in
% awgdata.pulsgroups.name, seqind.

% Group control 'seq' creates sequence combined groups
% -------------------------------------------------------------------------
%   Add groups like: pg.pulses.groups = {'group_1', 'group_2', 'group_4'};
%   Give the container group a regular expression name, that matches all
%   subgroups (and ONLY them, not any other group on the AWG), like
%   'tomo_[A-Za-z0-9]{7}'
%
%   Set order of pulses froms groups with pg.pulseind. Subgroups are indexed
%   by row, pulses of the group are indexed by column. The value gives the
%   number of pulse to use from original subgroup. A zero indicates not to
%   use a pulse from the corresponding group in the respective position. For
%   8 pulses per group this might look like:
%
%   pg.pulseind(1,:) = [1:8 zeros(1,16)];
%   pg.pulseind(2,:) = [zeros(1,8) 1:8 zeros(1,8)];
%   pg.pulseind(3,:) = [zeros(1,16) 1:8];
% -------------------------------------------------------------------------

% Group control 'loop seq pack' creates sequence combined groups. Each
% subgroup will be one single waveform. Each subgroup needs to have group
% control 'loop pack'
% -------------------------------------------------------------------------
%   As 'seq' but pg.pulseind of the container group references the
%   subgroups (since each of the subgroups will be one waveform later).
% -------------------------------------------------------------------------
%
% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

if ~iscell(groups)
    groups = {groups};
end

for k = 1:length(groups)
    
    
    %updates groupdef
    grpdef = makeGroupDef(groups{k},'uploadsimulation');
    
    
    
    if strcmp(grpdef.ctrl(1:min([end find(grpdef.ctrl == ' ', 1)-1])), 'grp')...
            && ~isempty(strfind(grpdef.ctrl, 'seq')) % combine groups at sequence level.
        % retrieve channels of component groups
        clear chan;
        for m = 1:length(grpdef.pulses.groups)
            gd=plsinfo('gd', grpdef.pulses.groups{m});
            rf={'varpar', 'pulseind', 'time'}; % Required fields that may be missing
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
        if ~isfield(grpdef, 'pulseind') || isempty(grpdef.pulseind)
            warning('pulseind not specified. Ask for policy.')
            zerolen = self.zero(grpdef,[],[]);
            grpdef.pulseind = 1:size(zerolen, 1);
        end
        seqmerge = false;
    end
    
    
    
    
    npls = size(grpdef.pulseind, 2);
 %   nchan = length(self.awgs.nChannels); % alternatively use awgdata or data size
    
    if ~isfield(grpdef, 'nrep')
        grpdef.nrep = ones(1,npls);
    elseif length(grpdef.nrep)<npls
        %proposal:
        grpdef.nrep(end+1:npls) = 1;
        
        warning('nrep not specified for all pulses. filling up with ones.');
    elseif length(grpdef.nrep) > npls
        error('length(grpdef.nrep) > npls');      
    end
    

    
    
%     if ~isfield(grpdef, 'jump')
%         if strfind(grpdef.ctrl, 'loop')
%             grpdef.jump = [npls; 1];
%         else
%             grpdef.jump = [];
%         end
%     end
    
    groupDefAWG = struct('name',grpdef.name,'pulses',[],'pulseind',[],'repetitions',[],'ctrl',grpdef.ctrl);
    if isfield(grpdef,'chan')
        groupDefAWG.chan = grpdef.chan;
    end
    
    if isfield(grpdef,'ctrl')
        groupDefAWG.ctrl = grpdef.ctrl;
    end
    
    % fill pulseind
    if ~seqmerge % pulses combined here.
        groupDefAWG.pulses = grpdef.pulses;
        groupDefAWG.pulseind = grpdef.pulseind;
        groupDefAWG.nrep = grpdef.nrep;
        
    elseif strfind(grpdef.ctrl,'pack') % added 14.11.2014 PC
        %do nothing
        groupDefAWG.pulses = grpdef.pulses;
        groupDefAWG.pulseind = grpdef.pulseind;
        groupDefAWG.nrep = grpdef.nrep;

    else % completely overhauled  02.05.2014 PC
        error('work out what to du here');
        
        groupDefAWG.nrep = grpdef.nrep;
        %guess:
        groupDefAWG.pulses = zeros(1,npls)
        
        for m = 1:length(grpdef.pulses.groups)
            pulses = find( grpdef.pulseind(m,:) > 0 )
            
            if any(groupDefAWG.pulseind(pulses))
                error('You can only play one pulse at a time.');
            end
            
            groupDefAWG.pulseind(pulses) = grpdef.pulseind(m,pulses)+length(groupDefAWG.pulses);
            
            groupDefAWG.pulses = [groupDefAWG.pulses(:) grpdef.groups.pulses{m}(:)];            
        end
        
        
%         for m = 1:length(grpdef.pulses.groups)
%             for j = 1:nchan % channels of component groups
%                 ch = find(awgdata(a).chans(j) == chan{m});
%                 if grpdef.pulseind(m, i) > 0 % Do not add if pulseind == 0
%                     if ~isempty(ch) && zerolen(grpdef.pulseind(m, i), ch) < 0
%                         % channel in group and not zero
%                         fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:WAV%d "%s_%05d_%d"', ind, j, ...
%                             grpdef.pulses.groups{m}, grpdef.pulseind(m, i), ch));
%                     else
%                         fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d_%d"', ind, j, ...
%                             zlmult*abs(zerolen(grpdef.pulseind(m, i), 1))*awgdata(a).clk/awgdata(1).clk,awgdata(a).zerochan(j)));
%                     end
%                 end;
%             end
%             
%         end
    end
    
    if isfield(grpdef,'jump')
        error('jump not implemented yet. (too lazy)');
    end
    
    for awg = self.awgs
        awg.addPulseGroup(groupDefAWG);
    end
% end
% if ~exist('seqlog','var')
%     seqlog.time = now;
% else
%     seqlog(end+1).time = now;
% end
% seqlog(end).nrep = grpdef.nrep;
% seqlog(end).jump = grpdef.jump;
% 
% save([plsdata.grpdir, 'pg_', groups{k}], '-append', 'seqlog');
% %fprintf('Jump program time: %f secs\n',toc-jstart);
% wstart=toc;
% awgcntrl('wait');
% %fprintf('Wait time: %f secs; total time %f secs\n',toc-wstart,toc-astart);
% nerr=0;
% for a=1:length(awgdata(a))
%     err=query(awgdata(a).awg, 'SYST:ERR?');
%     if ~isempty(strfind(err, 'No error'))
%         nerr=nerr+1;
%     end
% end
% if nerr == 0
%     fprintf('Added group %s on index %i. %s', grpdef.name, gind, err);
%     logentry('Added group %s on index %i.', grpdef.name, gind);
% end
% 
% if dosave
%     awgsavedata;
% end

end
