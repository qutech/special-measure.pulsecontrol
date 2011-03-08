function awgclear(groups)
% awgclear(groups)
%    OR
% awgclear('all')
% awgclear('pack') removes all groups, adds back groups loaded in sequences

global awgdata;
global plsdata;

if strcmp(groups, 'pack')
   grps={awgdata.pulsegroups.name};
   awgrm(1,'after');
   awgrm(1);
   awgclear('all');
   awgadd(grps);
   return;
end
if strcmp(groups, 'all')
    groups = query(awgdata.awg, 'WLIS:SIZE?', '%s\n', '%i')-1:-1:1;
    logentry('Cleared all pulses.');
    % Mark all pulse groups as not loaded
    g=plsinfo('ls');
    for i=1:length(g)
       load([plsdata.grpdir, 'pg_', g{i}, '.mat'], 'plslog');       
       if(plslog(end).time(end) <= 0)
          %fprintf('Skipping group ''%s''; already unloaded\n',g{i});
       else          
          plslog(end).time(end+1) = -now;
          save([plsdata.grpdir, 'pg_', g{i}, '.mat'], 'plslog','-append');
%          fprintf('Marking group ''%s'' as unloaded\n',g{i});
       end
    end
end
    

if ischar(groups)
    groups = {groups};
end
tic;
if isreal(groups)    
    groups = sort(groups, 'descend');    
    for i = groups
        wf = query(awgdata.awg, sprintf('WLIS:NAME? %d', i));
        if ~query(awgdata.awg, sprintf('WLIS:WAV:PRED? %s', wf), '%s\n', '%i')
            fprintf(awgdata.awg, 'WLIS:WAV:DEL %s', wf);
            awgcntrl('wait');
        end
        if toc > 20
            fprintf('%i/%i\n', i, length(groups));
            tic;
        end
    end
    return;
end
    
for k = 1:length(groups)
    load([plsdata.grpdir, 'pg_', groups{k}], 'zerolen', 'plslog');
    awgrm(groups{k});
    
    for i = 1:size(zerolen, 1)
        for j = find(zerolen(i, :) < 0)
            fprintf(awgdata.awg, sprintf('WLIS:WAV:DEL "%s_%05d_%d"', groups{k}, i, j));
        end
    end
    plslog(end).time(end+1) = -now;
    save([plsdata.grpdir, 'pg_', groups{k}], '-append', 'plslog');
    logentry('Cleared group %s.', groups{k});
    fprintf('Cleared group %s.', groups{k});
end