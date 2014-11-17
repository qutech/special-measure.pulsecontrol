function awgadd(groups)
% awgadd(groups)
% Add groups to end of sequence. Store group name and target index in
% awgdata.pulsgroups.name, seqind.

% Group control 'seq' creates sequence combined groups
% -------------------------------------------------------------------------
%   Add groups like: pg.pulses.groups = {'group_1', 'group_2', 'group_4'};
%   At least one of the subgroup names should be the same name as the group
%   name itself followed by an underscore and a number, e.g.
%   pg.name = 'groups' for the above example of pg.pulses.groups.
%   Set group control: pg.ctrl = 'loop seq';
%   Set order of pulses froms groups with pg.pulseind. Subgroups are indexed
%   by row, pulses of the group are indexed by column. The value gives the
%   number of pulse to use from original subgroup. A zero indicates not to
%   use a pulse from the corresponding group in the respective position. For
%   8 pulses per group this might look like:
%   pg.pulseind(1,:) = [1:8 zeros(1,16)];
%   pg.pulseind(2,:) = [zeros(1,8) 1:8 zeros(1,8)];
%   pg.pulseind(3,:) = [zeros(1,16) 1:8];
% -------------------------------------------------------------------------
%
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
gstart=toc;


for k = 1:length(groups)
  load([plsdata.grpdir, 'pg_', groups{k}]);
  
  stayInWhileLoop = true;
  while plsinfo('stale',groups{k}) && stayInWhileLoop
    fprintf('Latest pulses of group %s not loaded; %s > %s.\n', groups{k}, ...
      datestr(lastupdate), datestr(plslog(end).time(end)));
    tstart=toc;
    plsmakegrp(groups{k},'upload');
    ts2 = toc;
    awgcntrl('wait');
    %  fprintf('Load time=%f secs, wait time=%f\n',toc-tstart,toc-ts2);
    load([plsdata.grpdir, 'pg_', groups{k}]);
    
    if ~isempty(strfind(grpdef.ctrl, 'seqhack')) % Added by Pascal on 2014_08_01 to fix behaviour of sequence joined groups
      stayInWhileLoop = false;
      warning('Not checking whether pulses stale since grpdef.ctrl = ''seqhack''.');
    end;
  end
  
  
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
    if ~isfield(grpdef, 'pulseind')
      zerolen = plsinfo('zl', grpdef.name); % hack TB
      grpdef.pulseind = 1:size(zerolen, 1);
    end
    
    seqmerge = false;
  end
  
  if ~isfield(grpdef, 'nrep')
    grpdef.nrep = 1;
  end
  
  for a=1:length(awgdata)
    npls = size(grpdef.pulseind, 2);
    nchan = length(awgdata(a).chans); % alternatively use awgdata or data size
    usetrig = (grpdef.nrep(1) ~= Inf) && isempty(strfind(grpdef.ctrl, 'notrig'));
    
    if isempty(awgdata(a).pulsegroups)
      startline = 1;
      gind = [];
    else
      gind = strmatch(grpdef.name, {awgdata(a).pulsegroups.name}, 'exact');
      if ~isempty(gind)
        startline = awgdata(a).pulsegroups(gind(1)).seqind;
        if npls + usetrig ~= sum(awgdata(a).pulsegroups(gind(1)).npulse);
          error('Number of pulses changed in group %s. Use awgrm first!', grpdef.name);
        end
      else
        startline = awgdata(a).pulsegroups(end).seqind + sum(awgdata(a).pulsegroups(end).nline);
      end
    end
    
    if isempty(gind) % group not loaded yet, extend sequence
      
      gind = length(awgdata(a).pulsegroups)+1;
      awgdata(a).pulsegroups(gind).name = grpdef.name;
      awgdata(a).pulsegroups(gind).seqind = startline;
      awgdata(a).pulsegroups(gind).lastupdate = lastupdate;
      awgdata(a).pulsegroups(gind).npulse = [npls usetrig];
      if strfind(grpdef.ctrl,'pack')
        awgdata(a).pulsegroups(gind).nline = 1+usetrig;
        % Hack alert; way too much code assumes zl == pulselen.  For
        % packed groups, we ignore it and work out the correct length
        % ourselves.
        zlmult=npls;
        npls=1;
      else
        zlmult=1;
        awgdata(a).pulsegroups(gind).nline = npls+usetrig;
      end
      fprintf(awgdata(a).awg, sprintf('SEQ:LENG %d', startline + awgdata(a).pulsegroups(gind).nline-1));
      dosave = 1;
    else
      if strfind(grpdef.ctrl,'pack')
        zlmult = npls;
        npls=1;
      else
        zlmult=1;
      end
      if isfield(plslog, 'readout') && exist('zerolen', 'var')
        if any(awgdata(a).pulsegroups(gind).nrep ~= grpdef.nrep) || ...
            any(any(awgdata(a).pulsegroups(gind).readout ~= plslog(end).readout)) || ...
            any(any(awgdata(a).pulsegroups(gind).zerolen ~= zerolen)) % nrep or similar changed
          dosave = 1;
        end
      else
        if any(awgdata(a).pulsegroups(gind).nrep ~= grpdef.nrep) % nrep changed
          dosave = 1;
        end
      end;
    end
    
    if ~isfield(grpdef, 'jump')
      if strfind(grpdef.ctrl, 'loop')
        grpdef.jump = [npls; 1];
      else
        grpdef.jump = [];
      end
    end
    
    
    awgdata(a).pulsegroups(gind).nrep = grpdef.nrep;
    awgdata(a).pulsegroups(gind).lastload = plslog(end).time(1);
    
    % Added block below to fix 'seq', where zerolen and plslog(end).readout
    % are not available  02.05.2014 PC    
    if ~exist('zerolen', 'var')
      zerolen = [];
      for groupInd = 1:length(grpdef.pulses.groups)
        tempGrp = load([plsdata.grpdir, 'pg_', grpdef.pulses.groups{groupInd}]);
        zerolen = vertcat(zerolen, tempGrp.zerolen);
      end
      plslog(end).readout = tempGrp.plslog(end).readout;
      awgdata(a).pulsegroups(gind).lastload = now;
      clear tempGrp groupInd
    end;
    
    awgdata(a).pulsegroups(gind).zerolen = zerolen;  % Cache some handy stuff here.
    awgdata(a).pulsegroups(gind).readout=plslog(end).readout;
    
    if usetrig
      fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:WAV1 "trig_%08d"', startline, awgdata(a).triglen));
      for j = 2:nchan
        fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d_%d"', startline, j, awgdata(a).triglen, awgdata(a).zerochan(j)));
      end
      if isfield(awgdata(a),'slave') && ~isempty(awgdata(a).slave) && (awgdata(a).slave)
        fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:TWAIT 1\n', startline));
      end
    end
    
    
    for i = 1:npls
      ind = i-1 + startline + usetrig;
      if ~seqmerge % pulses combined here.
        for j = 1:nchan
          ch = find(awgdata(a).chans(j) == grpdef.chan);
          if ~isempty(ch) &&  zerolen(grpdef.pulseind(i), ch) < 0
            % channel in group and not zero
            fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:WAV%d "%s_%05d_%d"', ind, j, ...
              grpdef.name, grpdef.pulseind(i), ch));
          else
            % hack alert. We should really make zerolen a cell array.  fixme.
            fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d_%d"', ind, j, ...
              zlmult*abs(zerolen(grpdef.pulseind(i), 1))*awgdata(a).clk/awgdata(1).clk,awgdata(a).zerochan(j)));
          end
        end
      else % completely overhauled  02.05.2014 PC
        for m = 1:length(grpdef.pulses.groups)
          for j = 1:nchan % channels of component groups
            ch = find(awgdata(a).chans(j) == chan{m});
            if grpdef.pulseind(m, i) > 0 % Do not add if pulseind == 0
              if ~isempty(ch) && zerolen(grpdef.pulseind(m, i), ch) < 0
                % channel in group and not zero
                fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:WAV%d "%s_%05d_%d"', ind, j, ...
                  grpdef.pulses.groups{m}, grpdef.pulseind(m, i), ch));
              else
                fprintf(awgdata.awg, sprintf('SEQ:ELEM%d:WAV%d "zero_%08d_%d"', ind, j, ...
                  zlmult*abs(zerolen(grpdef.pulseind(m, i), 1))*awgdata(a).clk/awgdata(1).clk,awgdata(a).zerochan(j)));
              end
            end;
          end
        end
      end
      if grpdef.nrep(min(i, end)) == Inf  || grpdef.nrep(min(i, end)) == 0 ...
          || (i == npls && isempty(strfind(grpdef.ctrl, 'loop')) && (isempty(grpdef.jump) || all(grpdef.jump(1, :) ~= i)))
        fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:LOOP:INF 1', ind));
      else
        fprintf(awgdata(a).awg, 'SEQ:ELEM%d:LOOP:INF 0', ind); % default
        fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:LOOP:COUN %d', ind, grpdef.nrep(min(i, end))));
      end
      
      fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:GOTO:STAT 0', ind));
      
      if grpdef.nrep(min(i, end)) == Inf && isreal(grpdef.pulses) &&  ...
          (length(awgdata(a).seqpulses) < ind || awgdata(a).seqpulses(ind) ~= grpdef.pulses(grpdef.pulseind(i)));
        dosave = 1;
        awgdata(a).seqpulses(ind) = grpdef.pulses(grpdef.pulseind(i));
      end
      if ~mod(i, 100)
        fprintf('%i/%i pulses added.\n', i, npls);
      end
    end
    %fprintf('Group load time: %g secs\n',toc-gstart);
    
    jstart=toc;
    % event jumps
    %SEQ:ELEM%d:JTARget:IND
    %SEQ:ELEM%d:JTARget:TYPE
    
    for j = 1:size(grpdef.jump, 2)
      fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:GOTO:IND %d', startline+usetrig-1 + grpdef.jump(:, j)));
      fprintf(awgdata(a).awg, sprintf('SEQ:ELEM%d:GOTO:STAT 1', startline+usetrig-1 + grpdef.jump(1, j)));
    end
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
  wstart=toc;
  awgcntrl('wait');
  %fprintf('Wait time: %f secs; total time %f secs\n',toc-wstart,toc-astart);
  nerr=0;
  for a=1:length(awgdata(a))
    err=query(awgdata(a).awg, 'SYST:ERR?');
    if ~isempty(strfind(err, 'No error'))
      nerr=nerr+1;
    end
  end
  if nerr == 0
    fprintf('Added group %s on index %i. %s', grpdef.name, gind, err);
    logentry('Added group %s on index %i.', grpdef.name, gind);
  end
end
if dosave
  awgsavedata;
end
