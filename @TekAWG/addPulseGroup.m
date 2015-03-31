function addPulseGroup(self,grpdef)
    self.loadPulsesOfGroup(grpdef);
    
    
    npls = size(grpdef.pulseind, 2);
    
    
    
    usetrig = isempty(strfind(grpdef.ctrl, 'notrig'));
    
    
    if ~isempty( self.storedPulsegroups(grpdef.name).seqind )
        
        startline = self.storedPulsegroups(grpdef.name).seqind;
        if npls + usetrig ~= sum(self.storedPulsegroups(grpdef.name).npulse);
            error('Number of pulses changed in group %s. Use awgrm first!', grpdef.name);
        end
        
        
        if isfield(plslog, 'readout') && exist('zerolen', 'var')
            if any(self.storedPulsegroups(grpdef.name).nrep ~= grpdef.nrep) || ...
                    any(any(self.storedPulsegroups(grpdef.name).readout ~= plslog(end).readout)) || ...
                    any(any(self.storedPulsegroups(grpdef.name).zerolen ~= zerolen)) % nrep or similar changed
                dosave = 1;
            end
        else
            if any(self.storedPulsegroups(grpdef.name).nrep ~= grpdef.nrep) % nrep changed
                dosave = 1;
            end
        end;
        
    else
        % group loaded for the first time
        startline = self.lastFreeSequenceLine();
        
        self.storedPulsegroups(grpdef.name).seqind = startline;
        self.storedPulsegroups(grpdef.name).npulse = [npls usetrig];
        self.storedPulsegroups(grpdef.name).nline = npls+usetrig;

        fprintf(self.handle, sprintf('SEQ:LENG %d', startline +  self.storedPulsegroups(grpdef.name).nline-1));
        dosave = 1;
        
    end
    
    %insert nrep logic here
    loop = strfind(grpdef.ctrl, 'loop');

    self.storedPulsegroups(grpdef.name).nrep = grpdef.repetitions;
    
    if usetrig
        fprintf(self.handle, sprintf('SEQ:ELEM%d:WAV1 "trig_%08d"', startline, self.triglen));
        for j = 2:nchan
            fprintf(self.handle, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d_%d"', startline, j, self.triglen, self.zerochan(j)));
        end
        if isfield(self,'slave') && ~isempty(self.slave) && (self.slave)
            fprintf(self.handle, sprintf('SEQ:ELEM%d:TWAIT 1\n', startline));
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% continue work here
    
    for i = 1:npls
        ind = i-1 + startline + usetrig;
        
        for ch = 1:nchan
            if ~isempty(ch) &&  zerolen(grpdef.pulseind(i), ch) < 0
                % channel in group and not zero
                fprintf(self.handle, sprintf('SEQ:ELEM%d:WAV%d "%s_%05d_%d"', ind, j, ...
                    grpdef.name, grpdef.pulseind(i), ch));
            else
                % hack alert. We should really make zerolen a cell array.  fixme.
                fprintf(self.handle, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d_%d"', ind, j, ...
                    abs(zerolen(grpdef.pulseind(i), 1)),self.zerochan(j))); % think of a way to make clocks sync
            end
        end
        
        if grpdef.nrep(min(i, end)) == Inf  || grpdef.nrep(min(i, end)) == 0 ...
                || (i == npls && isempty(strfind(grpdef.ctrl, 'loop')) && (isempty(grpdef.jump) || all(grpdef.jump(1, :) ~= i)))
            fprintf(self.handle, sprintf('SEQ:ELEM%d:LOOP:INF 1', ind));
        else
            fprintf(self.handle, 'SEQ:ELEM%d:LOOP:INF 0', ind); % default
            fprintf(self.handle, sprintf('SEQ:ELEM%d:LOOP:COUN %d', ind, grpdef.nrep(min(i, end))));
        end
        
        fprintf(self.handle, sprintf('SEQ:ELEM%d:GOTO:STAT 0', ind));
        
        if grpdef.nrep(min(i, end)) == Inf && isreal(grpdef.pulses) &&  ...
                (length(self.seqpulses) < ind || self.seqpulses(ind) ~= grpdef.pulses(grpdef.pulseind(i)));
            dosave = 1;
            self.seqpulses(ind) = grpdef.pulses(grpdef.pulseind(i));
        end
        if ~mod(i, 100)
            fprintf('%i/%i pulses added.\n', i, npls);
        end
    end
    %fprintf('Group load time: %g secs\n',toc-gstart);
    
    %     jstart=toc;
    % event jumps
    %SEQ:ELEM%d:JTARget:IND
    %SEQ:ELEM%d:JTARget:TYPE
    
    for j = 1:size(grpdef.jump, 2)
        fprintf(self.handle, sprintf('SEQ:ELEM%d:GOTO:IND %d', startline+usetrig-1 + grpdef.jump(:, j)));
        fprintf(self.handle, sprintf('SEQ:ELEM%d:GOTO:STAT 1', startline+usetrig-1 + grpdef.jump(1, j)));
    end
    
    if ~exist('seqlog','var')
        seqlog.time = now;
    else
        seqlog(end+1).time = now;
    end
    seqlog(end).nrep = grpdef.nrep;
    seqlog(end).jump = grpdef.jump;
    
    save([plsdata.grpdir, 'pg_', groups{k}], '-append', 'seqlog');
    %fprintf('Jump program time: %f secs\n',toc-jstart);
    %   wstart=toc;
    self.control('wait');
    %fprintf('Wait time: %f secs; total time %f secs\n',toc-wstart,toc-astart);
    nerr=0;
    
    err=query(self.handle, 'SYST:ERR?');
    if ~isempty(strfind(err, 'No error'))
        nerr=nerr+1;
    end

end