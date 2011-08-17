function pulse = plstowf(pulse, dict)
% pulse = plstowf(pulse, dict)
% Convert any (valid) pulse format to wf format.
%
% If pulse is an integer, it is taken as a database index. 
% Otherwise, pulse is a struct with fields:
% format: 'tab', 'wf', 'elem
% data: struct with following fields
%   format = 'tab':
% 	pulsetab
% 	marktab
% 	pulsefn
% 	readout
%   format = 'elem': val, time (array)
%   format = 'wf': wf, marker, readout
% 
% name 
% taurc (optional)
% xval

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

dt=1e-11;

global plsdata;
global awgdata;
pulse = plsdefault(pulse);

if strcmp(pulse.format, 'wf')
    return
end
    
if strcmp(pulse.format, 'elem');
    if exist('dict','var') && ~isempty(dict)
        pulse = pdapply(dict,pulse);
    end
    pulse = plstotab(pulse);
end

if ~strcmp(pulse.format, 'tab');
    error('Invalid format %s.', pulse.format);
end

pulseinf = pulse.data;
pulse.data = [];




% if ~isfield(pulse, 'xval') || isempty(pulse.xval)
%     pulse.xval = nan;
% end

% these fields are optional, no need to store in database
if ~isfield(pulseinf, 'marktab')
    pulseinf.marktab = [];
end

if ~isfield(pulseinf, 'pulsefn')
    pulseinf.pulsefn = [];
elseif ~isempty(pulseinf.pulsefn) && ~isfield(pulseinf.pulsefn, 'args')
    [pulseinf.pulsefn.args] = deal(cell(2, 0));
end

if ~isfield(pulseinf, 'readout')
    pulseinf.readout = [];
end
clk = unique([awgdata.clk]);
for c=1:length(clk)
  pulsetab = pulseinf.pulsetab;
  nchan = size(pulsetab, 1)-1;
  
  npoints = round(max(pulsetab(1, :)) * plsdata.tbase * clk(c)/1e9);

  data = zeros(nchan, npoints+1);
  time = linspace(pulsetab(1, 1), pulsetab(1, end), npoints+1);
  
  
  if pulse.taurc == Inf
      avg = zeros(nchan, 1);
  else
      avg = 0.5 * sum((pulsetab(2:end, 2:end) + pulsetab(2:end, 1:end-1)).*...
          repmat((pulsetab(1, 2:end) - pulsetab(1, 1:end-1)), nchan, 1), 2)./(pulsetab(1, end) - pulsetab(1, 1));
      pulsetab(2:end, :) = pulsetab(2:end, :) - repmat(avg, 1, size(pulsetab, 2));
  end
  
  for j = 1:nchan
      for i = 2:size(pulsetab, 2)          
          mask = time >= pulsetab(1, i-1)-dt & time <= pulsetab(1, i)+dt;
          % added small shifts to mitigate rounding errors 08/04/09. Never seen to matter.
          % below makes writes the pulse into data using lines to connect the
          % corners defined in pulstab
          if 0
              data(j, mask) = (-pulsetab(j+1, i-1) * (time(mask) - pulsetab(1, i)) ...
                  + pulsetab(j+1, i) * (time(mask) - pulsetab(1, i-1)))./...
                  (pulsetab(1, i) -  pulsetab(1, i-1));
          else
              data(j, mask) = ((-pulsetab(j+1, i-1) + pulsetab(j+1,i)) * time(mask) + ...
                  pulsetab(j+1,i-1) * pulsetab(1, i) - pulsetab(j+1,i) * pulsetab(1, i-1))./...
                  (pulsetab(1, i) -  pulsetab(1, i-1));
          end
          
      end
  end
  % lets pulses be defined with functions (eg. sin, cos) instead of
  % just lines
  for i = 1:length(pulseinf.pulsefn)
      mask = time > pulseinf.pulsefn(i).t(1) & time <= pulseinf.pulsefn(i).t(2);
      for j = 1:nchan
          data(j, mask) = pulseinf.pulsefn(i).fn{j}(time(mask)-pulseinf.pulsefn(i).t(1), pulseinf.pulsefn(i).args{j, :}) - avg(j);
      end
  end
  
  data(:, end) = [];
  %below calculates input voltage based on output voltage (different bc
  %of bias T.
  if any(isfinite(pulse.taurc))
    if length(pulse.taurc) == 1 
       vc = cumsum(data, 2) * (pulsetab(1, end) - pulsetab(1, 1))/(npoints * pulse.taurc);
    else
      vc = cumsum(data, 2) * (pulsetab(1, end) - pulsetab(1, 1))./repmat(npoints * pulse.taurc', 1, npoints) ;
    end
  else
      vc=0;
  end
  
  
  marker = zeros(nchan, npoints, 'uint8');
  
  % extend marktab to be right dimensions
  marktab = pulseinf.marktab;
  marktab(end+1:2*nchan+1,:) = 0;
  
  for i = 1:size(pulseinf.marktab, 2)
      for j = 1:nchan
          for k = 1:2;
              mask = time(1:end-1) >= marktab(1, i) - dt &...
                  time(1:end-1) < marktab(1, i) + marktab(j*2+k-1, i)-2e-11;
              marker(j, mask) = bitor(marker(j, mask), k);
          end
      end
  end
  
  pulse.data(c).marker = marker;
  pulse.data(c).wf = data + vc;
  pulse.data(c).readout = pulseinf.readout;
  if isfield(pulseinf,'elem')
    pulse.data(c).elem=pulseinf.elem;
  end
  pulse.data(c).clk = clk(c);
pulse.data.pulsetab = pulsetab;
pulse.data.marktab = marktab;
pulse.format = 'wf';

