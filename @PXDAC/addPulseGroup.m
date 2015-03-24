function addPulseGroup(self,grpdef)

if ~isfield(grpdef, 'pulseind') || ~isfield(grpdef, 'repetitions') || ~isfield(grpdef,'pulses') || ~isfield(grpdef,'name')
    error('missing field');
end

if ~isfield(grpdef,'ctrl')
    grpdef.ctrl = '';
end

if length(grpdef.nrep)~=length(grpdef.pulseind)
    error('dim mismatch');
end

% if self.storedPulsegroups.isKey(grpdef.name)
%     warning('Ignoring stored pulsegroup %s for now.',grpdef.name);
%     return;
% end


if isfield(grpdef, 'jump')
    % this error should not be ignored since jumps on a TekAWG may be
    % executed
    error('The only situation where jump makes sense on PXDAC is for reordering. This is not implemented.')
end

usetrig = isempty(strfind(grpdef.ctrl, 'notrig'));
if usetrig
    warning('PXDAC has no trigger capability enabled yet');
end

if any(grpdef.nrep == Inf) || any(grpdef.nrep == 0)
    error('infinitive loop not supported by PXDAC.');
end

% stores/caches the pulsedata in interleaved form for faster upload
self.registerPulses(grpdef);

npls = size(grpdef.pulseind, 2);
for i = 1:npls
    %too stupid to solve without for loop
    self.storedPulsegroups(grpdef.name).pulseSequence(i).index = grpdef.pulseind(i);
    self.storedPulsegroups(grpdef.name).pulseSequence(i).nrep = grpdef.nrep(i);
end

% perform the actual upload on board memory
if strfind(grpdef.ctrl,'loop')
    repeats = 0;
else
    repeats = 1;
end

self.storedPulsegroups(grpdef.name).repetitions = repeats;

self.uploadPulsegroupToCard(grpdef.name);

end