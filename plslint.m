function plslint(pg)   % Try to find errors in pulse group before they happen
err=0;
% Global checks.
if isempty(pg)
   err=1;
   fprintf('No pulse groups\n');
end
if(length(pg) > 1)
 if(isfield(pg(1),'xval'))
    xv=[pg.xval];
    if isempty(find(diff(xv) ~= 0,1))
        fprintf('Group xval is defined but not changing\n');       
        err=1;
    end
 end
end
for i=1:length(pg)  % Individual group checks    
  if ~isempty(strfind(pg(i).ctrl,'seq'))    
   fprintf('Sequence combining\n');
   err=1;
   for l=1:length(pg(i).pulses.groups)
      fprintf('\t%-15s (',pg(i).pulses.groups{l});
      fprintf('%02d ',pg(i).pulseind(l,:));
      fprintf(')\n');
   end   
  end
end
if err
  input('Last chance to hit ^C\n','s');
end
