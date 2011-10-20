function awgclear(groups,options)
% awgclear(groups)
%    OR
% awgclear('all')
% awgclear('pack') removes all groups, adds back groups loaded in sequences
% awgclear('all','paranoid') removes all waveforms, including those not known to be loaded.
% awgclear('pack','paranoid') similar

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

if ~exist('options','var')
    options='';
end
global awgdata;
global plsdata;

if strcmp(groups, 'pack')
   grps={awgdata(1).pulsegroups.name};
   awgclear('all',options);
   awgrm(1,'after');
   awgrm(1);   
   awgadd(grps);
   return;
end
    for a=1:length(awgdata)
      fprintf(awgdata(a).awg,'WLIS:WAV:DEL ALL\n')
    end

if strcmp(groups, 'all') 
          % Mark only groups known to be loaded as loaded.
    if isempty(strfind(options,'paranoid'))
       g=awgwaveforms;            
    else  % Mark all pulse groups as not loaded
       g=plsinfo('ls');
    end
    fprintf(awgdata.awg,'WLIS:WAV:DEL ALL\n')
    logentry('Cleared all pulses.');
    for i=1:length(g)        
       load([plsdata.grpdir, 'pg_', g{i}, '.mat'], 'plslog');       
       if(plslog(end).time(end) <= 0)
          fprintf('Skipping group ''%s''; already unloaded\n',g{i});
       else          
          plslog(end).time(end+1) = -now;
          save([plsdata.grpdir, 'pg_', g{i}, '.mat'], 'plslog','-append');
          fprintf('Marking group ''%s'' as unloaded\n',g{i});
       end
    end
    return;       
end

if strcmp(groups,'unused')
    g=awgwaveforms;
    g2={awgdata.pulsegroups.name};
    groups=setdiff(g,g2);
    for i=1:length(groups)
      fprintf('Unloading %s\n',groups{i});
    end
end

if ischar(groups)
    groups = {groups};
end
tic;
for a=1:length(awgdata)
    if isreal(groups)
        groups = sort(groups, 'descend');
        for i = groups
            wf = query(awgdata(a).awg, sprintf('WLIS:NAME? %d', i));
            if ~query(awgdata(a).awg, sprintf('WLIS:WAV:PRED? %s', wf), '%s\n', '%i')
                fprintf(awgdata(a).awg, 'WLIS:WAV:DEL %s', wf);                
            end
            if toc > 20
                fprintf('%i/%i\n', i, length(groups));
                tic;
            end
        end
        return;
    end
    awgcntrl('wait');
end

for k = 1:length(groups)
    load([plsdata.grpdir, 'pg_', groups{k}], 'zerolen', 'plslog');
    awgrm(groups{k});
    
    
    for i = 1:size(zerolen, 1)
        for j = find(zerolen(i, :) < 0)
            for a=1:length(awgdata)
              fprintf(awgdata(a).awg, sprintf('WLIS:WAV:DEL "%s_%05d_%d"', groups{k}, i, j));
            end
        end
    end
    plslog(end).time(end+1) = -now;
    save([plsdata.grpdir, 'pg_', groups{k}], '-append', 'plslog');
    logentry('Cleared group %s.', groups{k});
    fprintf('Cleared group %s.\n', groups{k});
end
