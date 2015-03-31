function upload(self,name)

global plsdata;


if ~iscell(name)
    name = {name};
end

ind = [];
% if ~exist('opts','var')
%     opts=struct();
% end
% 
% opts=def(opts,'time',[]);

for k = 1:length(name)
    
    if(~isstruct(name{k}))
        zerolen = []; % avoid using zerolen from previous group.
        plslog=[];
        load([plsdata.grpdir, 'pg_', name{k}]);
    else
        grpdef=name{k};
    end
    
    
    if exist('plslog','var')  && length(plslog) > 100
        fprintf('Group %s has %d log entries.\n',name{k},length(plslog));
    end
%     if exist('plslog','var')  && ~isempty(plslog) && ~isempty(opts.time)
%         le=plsinfo_logentry(plslog,opts.time);
%         grpdef.params=plslog(le).params;
%         grpdef.matrix=plslog(le).matrix;
%         grpdef.varpar=plslog(le).varpar;
%         grpdef.offset=plslog(le).offset;
%         grpdef.dict=plslog(le).dict;
%         grpdef.readout=plslog(le).readout;
%     end
    
    
    pack = false;%~isempty(strfind(grpdef.ctrl,'pack'));
    
    if ~ isfield(grpdef, 'varpar')
        grpdef.varpar = [];
    end
    if ~ isfield(grpdef, 'params')
        grpdef.params = [];
    end
    if  isfield(grpdef, 'time')&& ~isempty(grpdef.time)
        fprintf('Ignoring opts.time\n');
        opts.time=grpdef.time;
        
    end
    
    if plsinfo('stale',grpdef.name)
        %  modified since last upload
        


        
        % Actually handle the upload...
        zerolen = self.load(grpdef, ind);
        
        
        % save update time in log.
        plslog(end+1).time = now;
        plslog(end).params = grpdef.params;
        plslog(end).matrix = grpdef.matrix;
        plslog(end).varpar = grpdef.varpar;
        plslog(end).offset = grpdef.offset;
        
        if isfield(grpdef.pulses(1).data,'readout')
            readout=[];
            for ll=1:length(grpdef.pulses)
                if ~isempty(grpdef.pulses(ll).data(1).readout)
                    readout(:,:,ll) = grpdef.pulses(ll).data(1).readout;
                end
            end
            if any(abs(diff(readout,[],3)) > 1e-10)
                warning('Readout changes between pulses in %s\n',name{k});
            end
            if(size(readout,1) > 0)
                plslog(end).readout = readout(:,:,1);
            else
                plslog(end).readout=[];
            end
        end
        
        if isfield(grpdef, 'dict')
            plslog(end).dict = grpdef.dict;
        end
        
        if isfield(grpdef, 'trafofn')
            plslog(end).trafofn = grpdef.trafofn;
        end
        
        if length(plslog) > 2 % copy in case not all pulses updated. First plslog has no xval
            plslog(end).xval = plslog(end-1).xval;
        end
        %plslog(end).xval(:, ind) = vertcat(grpdef.pulses.xval)';
        plslog(end).xval = vertcat(grpdef.pulses.xval)'; % temporary bug fix
        plslog(end).ind = ind;
        
        save([plsdata.grpdir, 'pg_', name{k}], '-append','-v6', 'plslog', 'zerolen');
        logentry('Uploaded group %s, revisions %i.', grpdef.name, length(plslog));
        %  fprintf(' in upload of group %s.\n', grpdef.name);
    else
        fprintf('Skipping group %s.\n', grpdef.name);
    end
end