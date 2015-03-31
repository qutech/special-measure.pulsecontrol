function loadwfm(self,data, marker, name, chan,define)
% Send waveform 'data,marker' to the awg with name 'name' intended for channel c.
% data is scaled and offset by awgdata.scale and awgdata.offset *before* sending.
start = now;
if exist('define','var') && define
   fprintf(self.handle, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, length(data))); 
   self.waveforms{end+1}=name;
end
chunksize=65536;
if(size(data,1) > size(data,2))
    data=data';
end
    data=(self.offset(min(chan,end)) + data)./self.scale(chan) + 1;
    tb=find(data > 2);
    tl=find(data < 0);
    if ~isempty(tb) || ~isempty(tl)
      %  fprintf('Pulse exceeds allowed range: %g - %g\n',min(data),max(data));
        data(tb) = 2;
        data(tl) = 0;
    end % 14 bit data offset is hard-coded in the AWG.
    data = uint16(min(data*(2^(14-1) - 1), 2^(14)-1)) + uint16(marker) * 2^14;
    npts = length(data);
    for os=0:chunksize:npts
        if os + chunksize >= npts
            fwrite(self.handle, [sprintf('WLIS:WAV:DATA "%s",%d,%d,#7%07d', name, os, npts-os,2 * (npts-os)),...
                typecast(data((os+1):end), 'uint8')]);
        else
            fwrite(self.handle, [sprintf('WLIS:WAV:DATA "%s",%d,%d,#7%07d', name, os, chunksize,2 * chunksize),...
                typecast(data((os+1):(os+chunksize)), 'uint8')]);
        end
        fprintf(self.handle,'');
    end
    time=(now-start)*24*60*60;
    fprintf('Load time for pulse %s: %g seconds for %g points (%g bytes/sec)\n',name,time, npts,npts*2/time);
end