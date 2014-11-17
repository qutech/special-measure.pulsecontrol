function pddump(dict)
% function pddump(dict)
% Provide a human readable dump of a dictionary.
if ischar(dict)
    dict=pdload(dict);
end
fn=fields(dict);
for i=1:length(fn)    
    df=getfield(dict,fn{i});
    if strcmp(fn{i},'time') 
        continue;
    end
    if ~isfield(df,'val')
        df.val=[];
    end
    if ~isfield(df,'time')
        df.time=[];
    end
   
    for j=1:length(df)
      if j == 1
          ns=sprintf('%+10s',fn{i});
      else
          ns=sprintf('%+10s','+>');
      end
      if isempty(df(j).val) && isempty(df(j).time)
        fprintf('%s: => %+7s\n',ns,df(j).type);
      else
        fprintf('%s:    %+7s at %-15s for %s\n',ns,df(j).type,sprintf('%g ',df(j).val),sprintf('%g ',df(j).time));
      end
    end    
end