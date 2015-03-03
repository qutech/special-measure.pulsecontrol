function  val = control(self,cntrl, chans)
% awgcntrl(cntrl, chans)
% cntrl: stop, start, on off, wait, raw|amp, israw,  extoff|exton, isexton, err, clr
% several commands given are processed in order.
% isamp and isexton return a vector of length chans specifying which are
% amp or in exton mode

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

val=[];
if nargin <2
    chans = [];
end

breaks = [regexp(cntrl, '\<\w'); regexp(cntrl, '\w\>')];

for k = 1:size(breaks, 2);
    switch cntrl(breaks(1, k):breaks(2, k))
        case 'stop'
            fprintf(self.handle, 'AWGC:STOP');

            
        case 'start'
            fprintf(self.handle, 'AWGC:RUN');
            awgcntrl('wait');
            
        case 'off'
           
                for i = ch(self, chans) %%%%%%%%%%%%%%%%%%%%%% hä?
                    fprintf(self.handle, 'OUTPUT%i:STAT 0', i);
                end
                
        case 'on'
                for i = ch(self, chans)
                    fprintf(self.handle, 'OUTPUT%i:STAT 1', i);
                end

            
            
        case 'wait'
                to = self.handle.timeout;
                self.handle.timeout = 600;
                query(self.handle, '*OPC?');
                self.handle.timeout = to;

            
        case 'raw'
            if any(any(~self.control('israw')))

                    if ~is7k(self)
                        for i = ch(self, chans)
                            fprintf(self.handle, 'AWGC:DOUT%i:STAT 1', i);
                        end
                    end

            else
                fprintf('Already raw\n');
            end
            
        case 'amp'
            if any(any(awg.control('israw')))

                    if ~is7k(self)
                        for i = ch(self, chans)
                            fprintf(self.handle, 'AWGC:DOUT%i:STAT 0', i);
                        end
                    end

            else
                fprintf('Already amp\n');
            end
            
        case 'israw'
            
            val=[];
                if ~is7k(self)
                    for i = ch(self, chans)
                        fprintf(self.handle, 'AWGC:DOUT%i:STAT?',i);
                        val(end+1) = fscanf(self.handle,'%f');
                    end
                end
            
        case 'exton'    %adds external DC to outputs specified in chans

                if ~is7k(self)
                    for i = ch(self,chans)
                        fprintf(self.handle, 'SOUR%i:COMB:FEED "ESIG"', i);
                    end
                end

            
        case 'extoff'   %turns off external DC

                if ~is7k(self)
                    for i = ch(self,chans)
                        fprintf(self.handle, 'SOUR%i:COMB:FEED ""', i);
                    end
                end

        case 'isexton'
            val=[];
                if ~is7k(self)
                    for i = ch(self, chans)
                        
                        fprintf(self.handle, 'SOUR%i:COMB:FEED?',i);
                        val(end+1) = strcmp(fscanf(self.handle, '%f'), 'ESIG');
                    end
                end

        case 'err'
                    err=query(self.handle, 'SYST:ERR?');
                    if strcmp(err(1:end-1), '0,"No error"')
                       % Supress blank error messages. 
                    else
                      fprintf('%d: %s\n',a,err);
                    end

                
            case 'clr'
                    i = 0;
                    err2 = sprintf('n/a.\n');
                    while 1
                        err = query(self.handle, 'SYST:ERR?');
                        if strcmp(err(1:end-1), '0,"No error"')
                            if i > 0
                              fprintf('%s: %i errors. Last %s', self.identifier, i, err2);
                            end
                            break;
                        end
                        err2 = err;
                        i = i + 1;
                    end

        case 'norm'
          for i = 1:4
            fprintf(self.handle, 'SOUR%i:VOLT:AMPL .6', i);
          end
        case 'dbl'
          for i = 1:4
            fprintf(self.handle, 'SOUR%i:VOLT:AMPL 1.2', i);
          end
        end
    end
end

function chans=ch(awg, chans)
  if isempty(chans)
      chans=1:length(awg.channelMap);
  end
end

function val=is7k(awg)
  val=length(awg.channelMap) <= 2;
end