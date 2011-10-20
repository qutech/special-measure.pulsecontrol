function waveforms = awgwaveforms
% function waveforms = awgwaveforms
% Give a list of waveforms that are known to be loaded.

global awgdata;
awgsyncwaveforms();

waveforms = regexp(awgdata.waveforms,'(.*)_\d+_\d+','tokens');
waveforms = [waveforms{:}];
waveforms = [waveforms{:}];
waveforms=unique(sort(waveforms));
i=strmatch('zero',waveforms);
waveforms(i)=[];
i=strmatch('trig',waveforms);
waveforms(i)=[];
end
