function awgswap(name)
global awgdata;
global smdata;
% strategy: store alternative awgdata sets in awgdata(1).alternates
%  store current alternate in awgdata.current
if ~exist('name') || isempty('name')
   fprintf('Available sets:\n');
   s=fieldnames(awgdata(1).alternates);
   for i=1:length(s)
     fprintf('\t%s\n',s{i});
   end
   fprintf('Currently selected: %s\n',awgdata(1).current);
   return;
end

% Save the current setting
tmp=nicermfield(awgdata,{'alternates','current'});
awgdata(1).alternates.(awgdata(1).current) = tmp;

% Extract the current offsets.
for i=1:length(awgdata)
    o(awgdata(i).chans) = awgdata(i).offset;
end

% Check if new setting exists
if ~isfield(awgdata(1).alternates,name)
    error('No AWG alternate named %s\n',name);
end

if ~strcmp(name,'current')
    fprintf('WARNING: Changing awg configuration.  Some\n awgclear(''pack'',''paranoid'')\n is probably in order\n');
end

% Load the new setting.
tmp=awgdata(1).alternates; 
awgdata=awgdata(1).alternates.(name);
awgdata(1).current=name;
awgdata(1).alternates = tmp;

% Restore the offsets
for i=1:length(awgdata)
    awgdata(i).offset = o(awgdata(i).chans);
end

% Figure out new master/slave relationships
master=nan;
for i=1:length(awgdata)
    if ~isfield(awgdata(i),'slave') || isempty(awgdata(i).slave) || ~awgdata(i).slave
        master = i;
        break;
    end
end
if isnan(master)
    error('No master AWG defined!\n');
end
slaves = setdiff(1:length(awgdata), master);

% Figure out what instruments different AWG's correspond to.
for i=1:length(awgdata)
    insts(i) = findawg(awgdata(i));
end

if ~isempty(slaves)
  for i=1:(length(slaves)-1)
    smdata.inst(insts(slaves(i))).data.chain = insts(slaves(i+1));
  end
  smdata.inst(insts(slaves(end))).data.chain = insts(master);
end

smdata.inst(insts(master)).data.chain=[];

% Rewire pulseline to control the first slave.
plc = smchanlookup('PulseLine');
if isempty(slaves)
  smdata.channels(29).instchan(1) = insts(master);
else
  smdata.channels(29).instchan(1) = insts(slaves(1));
end

end

function s = nicermfield(s, fields)
  if ~iscell(fields)
      fields={fields};
  end
  for i=1:length(fields)
      if isfield(s,fields{i})
          s=rmfield(s,fields{i});
      end
  end
end

function val = findawg(awgdata)
  global smdata;
  val=nan;
  for i=1:length(smdata.inst)
      try
          if smdata.inst(i).data.inst == awgdata.awg
              val = i;
              return;
          end
      catch
      end
  end
  
end