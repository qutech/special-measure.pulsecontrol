function zerolen = awgload(grp, ind, zerolen)
% zerolen = awgload(grp)
% load pulses from group to AWG. 

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


%global plsdata;
global awgdata;

%nchan = length(grp.chan); % alternatively use data size
%nchan = size(grp.pulses(1).data, 1); % assumed same for all.

awgcntrl('stop'); %changing pulses while running is slow.
awgsyncwaveforms(); % make sure the waveform list is up-to-date.
dosave = false;
% create trig pulse (and corresponding 0) if waveform list empty.
if query(awgdata.awg, 'WLIS:SIZE?', '%s\n', '%i') == 25 % nothing loaded (except predefined)
    %~query(awgdata.awg, sprintf('WLIS:WAV:PRED? %s', query(awgdata.awg, sprintf('WLIS:NAME? %d', ...
    %    query(awgdata.awg, 'WLIS:SIZE?', '%s\n', '%i')), '%s\n', '%i')))% querying name of last waveform apparently does not work
    fprintf(awgdata.awg, sprintf('WLIS:WAV:NEW "zero_%08d",%d,INT', awgdata.triglen, awgdata.triglen));
    fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "zero_%08d",#7%07d', awgdata.triglen, 2*awgdata.triglen),...
        typecast(2^13-1 + zeros(1, awgdata.triglen, 'uint16'), 'uint8')]);
    fprintf(awgdata.awg, '');
    awgdata.zeropls = awgdata.triglen;
    
    fprintf(awgdata.awg, sprintf('WLIS:WAV:NEW "trig_%08d",%d,INT', awgdata.triglen, awgdata.triglen));
    fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "trig_%08d",#7%07d', awgdata.triglen, 2*awgdata.triglen),...
        typecast(2^14 + 2^13 - 1 + zeros(1, awgdata.triglen, 'uint16'), 'uint8')]);
    fprintf(awgdata.awg, '');
    dosave = 1;
end

chunksize=65536;
for i = 1:length(grp.pulses)
    
    data = uint16(min((grp.pulses(i).data.wf./awgdata.scale + 1)*2^13 - 1, 2^14-1)) + uint16(grp.pulses(i).data.marker) * 2^14;
    npts = size(data, 2);
    if ~any(awgdata.zeropls == npts) % create zero if not existing yet
        fprintf(awgdata.awg, sprintf('WLIS:WAV:NEW "zero_%08d",%d,INT', npts, npts));
        awgdata.waveforms{end+1}=sprintf('zero_%08d',npts);            
        for os=0:chunksize:npts
          if os + chunksize >= npts
              fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "zero_%08d",%d,%d,#7%07d', npts, os, npts-os,2 * (npts-os)),...
                typecast(2^13-1 + zeros(1, npts-os, 'uint16'), 'uint8')]);
          else
              fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "zero_%08d",%d,%d,#7%07d', npts, os, chunksize,2 * chunksize),...
                typecast(2^13-1 + zeros(1, chunksize, 'uint16'), 'uint8')]);
          end
          fprintf(awgdata.awg,'');
        end
        awgdata.zeropls(end+1) = npts;
        dosave = 1;
    end

    for j = 1:size(data, 1)
        % optionally catenate pulses and write outside main loop.
        if ~all(data(j, :) == 2^13-1)

            name = sprintf('%s_%05d_%d', grp.name, ind(i), j);


            %len = query(awgdata.awg, sprintf('WLIS:WAV:LENG "%s"', name), '%s\n', '%d'); 
            % does not retuen if waveform does not exist.
            
            %if len ~= npts
            %    fprintf(awgdata.awg, sprintf('WLIS:WAV:DEL "%s"', name)); % remove waveform to allow size changes
            %    fprintf('Pulse length changed. Reload group %s.', grp.name)
            %end                         
            
            if isempty(strmatch(name,awgdata.waveforms))                
              fprintf(awgdata.awg, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, npts));
              err = query(awgdata.awg, 'SYST:ERR?');
              if ~isempty(strfind(err,'E11113'))
                 fprintf(err(1:end-1));
                 error('Error loading waveform; AWG is out of memory.  Try awgclear(''all''); ');
              end
              awgdata.waveforms{end+1}=name;            
            end
            
            %fprintf('%i, %i: %s', i, j, query(awgdata.awg, 'SYST:ERR?')) % read error message in case waveform already existed
            for os=0:chunksize:npts
                if os + chunksize >= npts
                    fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "%s",%d,%d,#7%07d', name, os, npts-os,2 * (npts-os)),...
                        typecast(data(j,(os+1):end), 'uint8')]);
                else
                    fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "%s",%d,%d,#7%07d', name, os, chunksize,2 * chunksize),...
                        typecast(data(j,(os+1):(os+chunksize)), 'uint8')]);
                end
                fprintf(awgdata.awg,'');
            end
%            fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "%s",#5%05d', name, 2 * npts),...
%                typecast(data(j, :), 'uint8')]);
%            fprintf(awgdata.awg, '');% LF needed for raw interface
            
            zerolen(ind(i), j) = -npts;
        else
            zerolen(ind(i), j) = npts;
        end
    end
end
err = query(awgdata.awg, 'SYST:ERR?');
fprintf(err(1:end-1)); 

if dosave
    awgsavedata;
end
