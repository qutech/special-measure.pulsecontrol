function val = smcPXDAC(ico, val, rate)
% 1: none
% 2: clock,
% 3-6: peak to peak range for ch 1-4  
% 7: none
% 8-11 
%
% Extra fields that can go into smdata.inst(x).data
%   chain    ; setting the frequency or pulseline on this instrument 'chains' to the specified instrument;
%              this allows one to seamlessly set the pulseline on many awg's together.
%   clockmult; a multiplier to be applied to any clock frequency sets on this device.
%              allows 7k and 5k to be mixed.

global smdata;

pxdac = smdata.inst(ico(1)).data;

cmds = {':FREQ', ':FREQ', 'SOUR1:VOLT', 'SOUR2:VOLT', 'SOUR3:VOLT', 'SOUR4:VOLT', 'SEQ:JUMP', ...
    'SOUR1:VOLT:OFFS', 'SOUR2:VOLT:OFFS','SOUR3:VOLT:OFFS','SOUR4:VOLT:OFFS','SOUR1:MARK1:VOLT:LOW',...
    'SOUR1:MARK1:VOLT:HIGH', 'SOUR1:MARK2:VOLT:LOW', 'SOUR1:MARK2:VOLT:HIGH', ... 
    'SOUR2:MARK1:VOLT:LOW', 'SOUR2:MARK1:VOLT:HIGH', 'SOUR2:MARK2:VOLT:LOW', 'SOUR2:MARK2:VOLT:HIGH'...
    'SOUR3:MARK1:VOLT:LOW', 'SOUR3:MARK1:VOLT:HIGH', 'SOUR3:MARK2:VOLT:LOW', 'SOUR3:MARK2:VOLT:HIGH'...
    'SOUR4:MARK1:VOLT:LOW', 'SOUR4:MARK1:VOLT:HIGH', 'SOUR4:MARK2:VOLT:LOW', 'SOUR4:MARK2:VOLT:HIGH'};

switch ico(2)
    case 1;
        error('PXDAC provides no frequency generator mode.');
    case 2;
        switch ico(3) 
            case 1
                pxdac.setOutputVoltage(ico(2)-2,val);
            case 0
                val = pxdac.getOutputVoltage(ico(2)-2);
            otherwise
                error('Only supports get and set operations.');
        end
    case 3:6;
        switch ico(3) 
            case 1
                pxdac.setOutputVoltage(ico(2)-2,val);
            case 0
                val = pxdac.getOutputVoltage(ico(2)-2);
            otherwise
                error('Only supports get and set operations.');
        end
        
    case 8:11;
        error('PXDAC supports no hardware DC offset.');        
    otherwise
         error('Operation %d not supported',ico(2));
end
