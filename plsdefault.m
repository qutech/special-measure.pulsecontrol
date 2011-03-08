function pulse = plsdefault(pulse)
% pulse = plsdefault(pulse)
% set defaults and guess format if not given

global plsdata;
if ~isstruct(pulse) % database indices given
    pulse = plsdata.pulses(pulse);        
    return;
    %     pulse = num2cell(pulse);
    %     pulse = struct('data', pulse, 'format', 'ind');
end


if ~isfield(pulse, 'xval') %||isempty(pulse.xval) % fails for pulse arrays. Would have to define mask, assign only empty ones
     [pulse.xval] = deal([]);
end

if ~isfield(pulse, 'taurc') %|| isempty(pulse.taurc)
    [pulse.taurc] = deal(Inf);
end

if ~isfield(pulse, 'name')
    [pulse.name] = deal('');
end

if ~isfield(pulse, 'pardef')
    [pulse.pardef] = deal([]);
end

if ~isfield(pulse, 'trafofn')
    [pulse.trafofn] = deal([]);
end


% only implemented for single pulse
if ~isfield(pulse, 'format') || isempty(pulse(1).format)
    if isreal(pulse.data)
        pulse.format = 'ind';
    elseif isfield(pulse.data, 'type')
        pulse.format = 'elem';
    elseif isfield(pulse.data, 'wf')
        pulse.format = 'wf';
    elseif isfield(pulse.data, 'pulsetab') || isfield(pulse.data, 'marktab') || isfield(pulse.data, 'pulsefn')
        pulse.format = 'tab';
    else
        error('Invalid format.\n')
    end
end
