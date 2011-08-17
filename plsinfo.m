function val = plsinfo(ctrl, group, ind, time)
%val = plsinfo(ctrl, group, ind)
% ctrl: xval, zl, gd, log(=pl), sl, ls, rev, stale, params
% ls: List available pulsegroups.  group can be an optional mask like
%   'dBz*'
% stale: Return 1 if the group needs uploading.  Also prints a message.
% gd: return the groupdef.  Does not honor time.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global plsdata;
global awgdata;

if nargin >= 2 && ~ischar(group)
    group = awgdata(1).pulsegroups(group).name;
end
if ~exist('time','var')
    time=[];
end
    
switch ctrl
    case 'xval'        
        load([plsdata.grpdir, 'pg_', group], 'plslog','grpdef');
        le=logentry(plslog,time);
        if nargin < 3
            ind = 1;
        end

        if strfind(grpdef.ctrl, 'seq')
            val = zeros(0, size(grpdef.pulseind, 2));
            for i = 1:length(grpdef.pulses.groups)
                load([plsdata.grpdir, 'pg_', grpdef.pulses.groups{i}], 'plslog')                
                le=logentry(plslog,time);
                val = [val; plslog(le).xval(:, grpdef.pulseind(i, :))];
            end
            if ~isempty(ind)
              val = val(ind, :);              
            end
        else
            if(isfield(grpdef,'pulseind'))
                pis=unique(grpdef.pulseind);
                for i=1:length(grpdef.pulseind)
                    grpdef.pulseind(i)=find(pis==grpdef.pulseind(i));
                end
                val=[];
                for i=1:size(grpdef.pulseind(1))                  
                  val = [val ; plslog(le).xval(:, grpdef.pulseind(i,:))];
                end
                if ~isempty(ind)
                    val=val(ind,:);
                end
            else
                while(max(ind) > size(plslog(le).xval,1))
                    fprintf('Warning; not enough xvals on group %s.  Trying next log entry\n', ...
                        group);                    
                    le=le+1;
                end
                if isempty(ind)
                  val = plslog(le).xval(:, :);
                else
                  val = plslog(le).xval(ind, :);
                end
            end
        end
   case 'params'        
        load([plsdata.grpdir, 'pg_', group], 'plslog','grpdef');
        le=logentry(plslog,time);
        if nargin < 3 || isempty(ind)
            ind = 1;
        end

        if strfind(grpdef.ctrl, 'seq')
            val = zeros(0, size(grpdef.pulseind, 2));
            for i = 1:length(grpdef.pulses.groups)
                load([plsdata.grpdir, 'pg_', grpdef.pulses.groups{i}], 'plslog')                
                le=logentry(plslog,time);
                val = [val  plslog(le).params(1,:)];
            end
            if ~isempty(ind)
              val = val(:,ind);              
            end
        else
          while(max(ind) > size(plslog(le).params,1))
              fprintf('Warning; not enough params on group %s.  Trying next log entry\n', ...
                   group);                    
              le=le+1;
          end
          val = plslog(le).params(ind,:);
        end
        
    case 'ro'
        warning('off', 'MATLAB:load:variableNotFound');
        load([plsdata.grpdir, 'pg_', group], 'grpdef', 'zerolen','plslog');
        warning('on', 'MATLAB:load:variableNotFound');  
        if isfield(plslog(end),'readout')
            val=plslog(end).readout;            
        elseif strfind(grpdef.ctrl,'grp')
            val=[];
            for l=1:length(grpdef.pulses.groups)
                val=[val ; plsinfo('ro',grpdef.pulses.groups{l})];
                [u i]=unique(val(:,1));
                val=val(i,:);
            end            
        else            
            if exist('zerolen','var') && size(zerolen,1) > 1
              pd = plsmakegrp(group,'',[1 size(zerolen,1)]) ; % minor bug; assume all pulses have same readout.                        
              val = [pd.pulses(1).data.readout ; pd.pulses(2).data.readout];            
              if any(abs(diff(val,[],1)) > 1e-10)
                  warning('Readout changes between pulses in %s\n',group);
              end
              val=val(1,:);
            else
              pd = plsmakegrp(group,'',1) ; % minor bug; assume all pulses have same readout.                        
              val = pd.pulses.data(1).readout;                
            end
            
        end
    case 'zl'
        warning('off', 'MATLAB:load:variableNotFound');
        load([plsdata.grpdir, 'pg_', group], 'zerolen');
        warning('on', 'MATLAB:load:variableNotFound');       
        
        if ~exist('zerolen', 'var')
            load([plsdata.grpdir, 'pg_', group], 'grpdef');
            load([plsdata.grpdir, 'pg_', grpdef.pulses.groups{1}], 'zerolen');
        end % hack as a dirty bug fix. Size of zerolen does not match group format.
        % would have to read and merge all component groups.
        val = zerolen;
        
    case 'gd'
        load([plsdata.grpdir, 'pg_', group], 'grpdef');
        val = grpdef;

    case {'pl', 'log'}
        load([plsdata.grpdir, 'pg_', group], 'plslog');
        val = plslog;
        if(~isempty(time))
           val=val(logentry(val,time)); 
        end
    case 'stale'
        load([plsdata.grpdir, 'pg_', group], 'lastupdate','plslog','grpdef');
        if(isempty(strfind(grpdef.ctrl,'seq')))
          val = lastupdate > plslog(end).time(end);
          if val && nargout == 0
              fprintf('Pulse group ''%s'' is stale.\n',group);
          end   
        else
          val = 0;
          for i=1:length(grpdef.pulses.groups)
            val = val || plsinfo('stale',grpdef.pulses.groups{i});   
          end
        end
        
    case 'sl'
        load([plsdata.grpdir, 'pg_', group], 'seqlog');
        val = seqlog;

    case 'ls'
        cwd = pwd;
        cd(plsdata.grpdir);
        if nargin < 2
            group = '*';
        end
        if nargout >= 1
            val = dir(['pg_', group, '.mat']);
            val = {val.name};
            val=regexprep(val,'^pg_','');
            val=regexprep(val,'.mat$','');
        else
            val=dir(['pg_', group, '.mat']);
            val = {val.name};
            val=regexprep(val,'^pg_','');
            val=regexprep(val,'.mat$','');
            for i=1:length(val)
              fprintf('%s\n',val{i});
            end
            clear val;
        end            
        cd(cwd);
        
    case 'rev'
        load([plsdata.grpdir, 'pg_', group], 'plslog');
        for i = 1:length(plslog)
            switch length(plslog(i).time)
                case 1
                    fprintf('%i: %s\n', i, datestr(plslog(i).time));
                case 2
                    fprintf('%i: %s - %s\n', i, datestr(plslog(i).time(1)), datestr(plslog(i).time(2)));
                case 3
                    fprintf('%i: %s - % + further entries\n', i, datestr(plslog(i).time(1)), datestr(plslog(i).time(2)));
            end
        end
end
return

function l=logentry(plslog, time)

l = length(plslog);

if ~isempty(time)
    while plslog(l).time(1) > time        
        l = l - 1;
    end
    
    if l == 0
        error('Time travellers beware!');
    end
    
    if length(plslog(l).time) > 1 && -plslog(l).time(2) < time
         error('Group not loaded at requested time!');
    end
end
return
