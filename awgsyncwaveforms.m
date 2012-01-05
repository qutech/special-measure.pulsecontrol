function awgsyncwaveforms()
% Make sure the list of pulses is awgdata is consistent with the awg.
% we assume if the number of pulses is right, everything is.\
global awgdata;
  awgcntrl('clr');
  
  for a=1:length(awgdata)
      npls=str2num(query(awgdata(a).awg,'WLIS:SIZE?'));
      if isfield(awgdata(a),'waveforms') && (length(awgdata(a).waveforms) == npls)
          return;
      end
      fprintf('AWG waveform list out of date.  Syncing.');
      awgdata(a).waveforms=cell(npls,1);
      for l=1:npls
          r=query(awgdata(a).awg,sprintf('WLIS:NAME? %d',l-1));
          awgdata(a).waveforms{l}=r(2:end-1);
      end
      fprintf('..  Done.\n');
  end
end