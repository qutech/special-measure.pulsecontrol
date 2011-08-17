function awgclear(groups)
% awgclear(groups)
%    OR
% awgclear('all')
% awgclear('pack') removes all groups, adds back groups loaded in sequences

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;
global plsdata;

if strcmp(groups, 'pack')
   grps={awgdata(1).pulsegroups.name};
   awgrm(1,'after');
   awgrm(1);
   awgclear('all');
   awgadd(grps);
   return;
end
if strcmp(groups, 'all')
%    groups = query(awgdata.awg, 'WLIS:SIZE?', '%s\n', '%i')-1:-1:1;
    for a=1:length(awgdata)
      fprintf(awgdata(a).awg,'WLIS:WAV:DEL ALL\n')
    end
    logentry('Cleared all pulses.');
    % Mark all pulse groups as not loaded
    if 1
        g=plsinfo('ls');
    end
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
    return;
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
    fprintf('Cleared group %s.', groups{k});
end
