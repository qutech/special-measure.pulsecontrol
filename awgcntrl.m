function  val = awgcntrl(cntrl, chans)
% awgcntrl(cntrl, chans)
% cntrl: stop, start, on off, wait, raw|amp, israw,  extoff|exton, isexton, err, clr
% several commands given are processed in order.
% isamp and isexton return a vector of length chans specifying which are
% amp or in exton mode

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


global awgdata;
    val=[];
    if nargin <2
        chans = [];
    end
    
    breaks = [regexp(cntrl, '\<\w'); regexp(cntrl, '\w\>')];
    
    for k = 1:size(breaks, 2);
        switch cntrl(breaks(1, k):breaks(2, k))
            case 'stop'
                for a=1:length(awgdata)
                  fprintf(awgdata(a).awg, 'AWGC:STOP');
                end
                
            case 'start'
                for a=1:length(awgdata)
                  fprintf(awgdata(a).awg, 'AWGC:RUN');
                end
                awgcntrl('wait');
                
            case 'off'
                for a=1:length(awgdata)
                   for i = ch(awgdata(a), chans)
                     fprintf(awgdata(a).awg, 'OUTPUT%i:STAT 0', i);
                    end
                end
            case 'on'
                for a=1:length(awgdata)
                   for i = ch(awgdata(a), chans)
                     fprintf(awgdata(a).awg, 'OUTPUT%i:STAT 1', i);
                   end
                end
                
                
            case 'wait'
                for a=1:length(awgdata)
                  to = awgdata(a).awg.timeout;
                  awgdata(a).awg.timeout = 600;
                  query(awgdata(a).awg, '*OPC?');
                  awgdata(a).awg.timeout = to;
                end
                
            case 'raw'
               if any(any(~awgcntrl('israw')))
                   for a=1:length(awgdata)
                     for i = ch(awgdata(a), chans)
                       fprintf(awgdata(a).awg, 'AWGC:DOUT%i:STAT 1', i);
                     end
                   end
                else
                    fprintf('Already raw\n');
                end
               
            case 'amp'
               if any(any(~awgcntrl('israw')))
                   for a=1:length(awgdata)
                     for i = ch(awgdata(a), chans)
                       fprintf(awgdata(a).awg, 'AWGC:DOUT%i:STAT 0', i);
                     end
                   end
                else
                    fprintf('Already amp\n');
                end
         
            case 'israw'
                val=[];
                for a=1:length(awgdata)
                    for i = ch(awgdata(a), chans)
                        fprintf(awgdata(a).awg, 'AWGC:DOUT%i:STAT?',i);
                        val(end+1) = fscanf(awgdata(a).awg,'%f');
                    end
                end
                
            case 'exton'    %adds external DC to outputs specified in chans
                for a=1:length(awgdata)
                  for i = ch(awgdata(a),chans)
                    fprintf(awgdata(a).awg, 'SOUR%i:COMB:FEED "ESIG"', i);
                  end
                end
                
            case 'extoff'   %turns off external DC
                for a=1:length(awgdata)
                  for i = ch(awgdata(a),chans)
                    fprintf(awgdata(a).awg, 'SOUR%i:COMB:FEED ""', i);
                  end
                end
            case 'isexton'
                val=[];
                for a=1:length(awgdata)
                    for i = ch(awgdata(a), chans)                        
                        fprintf(awgdata(a).awg, 'SOUR%i:COMB:FEED?',i);
                        val(end+1) = strcmp(fscanf(awgdata(a).awg, '%f'), 'ESIG');
                    end
                end
            case 'err'
                for a=1:length(awgdata)
                  fprintf('%d: %s\n',a,query(awgdata(a).awg, 'SYST:ERR?'));
                end
                
            case 'clr'
                for a=1:length(awgdata)
                    i = 0;
                    err2 = sprintf('n/a.\n');
                    while 1
                        err = query(awgdata(a).awg, 'SYST:ERR?');
                        if strcmp(err(1:end-1), '0,"No error"')
                            fprintf('%d: %i errors. Last %s', a, i, err2);
                            break;
                        end
                        err2 = err;
                        i = i + 1;
                    end
                end
        case 'norm'
          for i = 1:4
            fprintf(awgdata.awg, 'SOUR%i:VOLT:AMPL .6', i);
          end
        case 'dbl'
          for i = 1:4
            fprintf(awgdata.awg, 'SOUR%i:VOLT:AMPL 1.2', i);
          end
        end
    end
end

function chans=ch(awg, chans)
  if isempty(chans)
      chans=1:length(awg.chans);
  end
end