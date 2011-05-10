function awgsyncwaveforms()
% Make sure the list of pulses is awgdata is consistent with the awg.
% we assume if the number of pulses is right, everything is.\
global awgdata;
  awgcntrl('clr');
  npls=str2num(query(awgdata.awg,'WLIS:SIZE?'));
  if isfield(awgdata,'waveforms') && length(awgdata.waveforms) == npls
      return;
  end
  fprintf('AWG waveform list out of date.  Syncing.');
  awgdata.waveforms=cell(npls,1);
  for l=1:npls
     r=query(awgdata.awg,sprintf('WLIS:NAME? %d',l-1));
     awgdata.waveforms{l}=r(2:end-1);
  end
  fprintf('..  Done.\n');
end