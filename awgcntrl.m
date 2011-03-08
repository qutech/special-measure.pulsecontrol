function  val = awgcntrl(cntrl, chans)
% awgcntrl(cntrl, chans)
% cntrl: stop, start, on off, wait, raw|amp, israw,  extoff|exton, isexton, err, clr
% several commands given are processed in order.
% isamp and isexton return a vector of length chans specifying which are
% amp or in exton mode

global awgdata;

if nargin <2
    chans = awgdata.chans;
end

breaks = [regexp(cntrl, '\<\w'); regexp(cntrl, '\w\>')];

for k = 1:size(breaks, 2);
    switch cntrl(breaks(1, k):breaks(2, k))
        case 'stop'
            fprintf(awgdata.awg, 'AWGC:STOP');
            
        case 'start'
            fprintf(awgdata.awg, 'AWGC:RUN');
            
        case 'off'
            for i = chans
                fprintf(awgdata.awg, 'OUTPUT%i:STAT 0', i);
            end
            
        case 'on'
            for i = chans
                fprintf(awgdata.awg, 'OUTPUT%i:STAT 1', i);
            end
            
        case 'wait'
            to = awgdata.awg.timeout;
            awgdata.awg.timeout = 600;
            query(awgdata.awg, '*OPC?');
            awgdata.awg.timeout = to;
            
        case 'raw'
            %awgcntrl('stop');
            %awgcntrl('off');
            for i = chans
                fprintf(awgdata.awg, 'AWGC:DOUT%i:STAT 1', i);
            end
            %awgcntrl('on');
            %awgcntrl('start');
            
        case 'amp'
            %awgcntrl('stop');
            %awgcntrl('off');
            for i = chans
                fprintf(awgdata.awg, 'AWGC:DOUT%i:STAT 0', i);
            end
            %awgcntrl('on');
            %awgcntrl('start');
            
        case 'israw'
            for i = chans
                %fprintf('%s',query(awgdata.awg, 'AWGC:DOUT%i:STAT?',i));
                fprintf(awgdata.awg, 'AWGC:DOUT%i:STAT?',i);
                val(i) = fscanf(awgdata.awg,'%f');
            end
            
        case 'exton'    %adds external DC to outputs specified in chans
            %awgcntrl('stop');
            %awgcntrl('off');
            for i = chans
                fprintf(awgdata.awg, 'SOUR%i:COMB:FEED "ESIG"', i);
            end
            %awgcntrl('on');
            %awgcntrl('start');
            
        case 'extoff'   %turns off external DC
            %awgcntrl('stop');
            %awgcntrl('off');
            for i = chans
                fprintf(awgdata.awg, 'SOUR%i:COMB:FEED ""', i);
            end
            %awgcntrl('on');
            %awgcntrl('start');
            
        case 'isexton'
            for i = chans
                fprintf(awgdata.awg, 'SOUR%i:COMB:FEED?',i);
                val(i) = strcmp(fscanf(awgdata.awg, '%f'), 'ESIG');
            end
            
        case 'err'
            fprintf(query(awgdata.awg, 'SYST:ERR?'));
            
        case 'clr'
            i = 0;
            err2 = sprintf('n/a.\n');
            while 1
                err = query(awgdata.awg, 'SYST:ERR?');
                if strcmp(err(1:end-1), '0,"No error"')
                    fprintf('%i errors. Last %s', i, err2);
                    return;
                end
                err2 = err;
                i = i + 1;
            end
    end
end