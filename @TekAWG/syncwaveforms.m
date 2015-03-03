function syncwaveforms(self)
% Make sure the list of pulses in awgdata is consistent with the awg.
% we assume if the number of pulses is right, everything is.\
self.control('clr');


    npls=str2num(query(self.handle,'WLIS:SIZE?'));
    if (length(self.waveforms) == npls)
      return;
    end
    fprintf('TekAWG %s waveform list out of date.  Syncing.',self.identifier);
    self.waveforms=cell(npls,1);
    for l=1:npls
      r=query(self.handle,sprintf('WLIS:NAME? %d',l-1));
      self.waveforms{l}=r(2:end-2); %-2 since communication adds newline at end
    end
    fprintf('..  Done.\n');
end
