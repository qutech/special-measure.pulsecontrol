function pulse = plstotab(pulse)
% pulse = plstotab(pulse)
%
% Convert 'elem' to 'tab' pulse format.
%
% Integer pulse is taken from the database.
% Fields of pulse:
% name, xval, and taurc remain unchanged.
%
% format: must be 'elem' or 'tab'. Nothing is done for 'tab';
%
% data: struct array with fields type, time, val corresponding to pulse elements
%           to be concatenated.  type is a string specifying the type of element, 
%           val and time specicy pulse voltages and times, respectively.
%           Their meaning and the format of val depend on type.
% 
% Possible type strings and corresponding interpretation of val:
% raw: insert [time; val] into pulse table.
% mark: add time' to marktab
% fill: stretch this element to make the total pulse duration equal to time.
%       Idea for future development: allow several fills, each spreading a subset.
%       Would need a second element to flush previous fill, could be fill without time.
% wait: stay at val (row vector, one entry for each channel) for duration time.
%       If val has 3 entries, third is a scaling factor for the first two.
% mwait: multiple wait, stay at [val(i) -val(i)] for duration time(i).
%       last val entry is a scaling factor, values at 4mV before scaling
%       stay at 4mV ('zero' value for gates)
% reload: relaod pulse at val (row vector, one entry for each channel).
%         time: [ramp time, wait time at load point, wait time at (0, 0) after load] 
% meas: measurement stage at [0, 0] for time(1), RF marker delayed by time(2) and
%       off time(3) before end of the stage.  [time(2) is lead delay,
%       time(3) is negative tail delay. 
%       Optional val(1) is the readout tag. If it is given and not nan, time 4 and 5 set its delays
%       with the sae convention as for the marker.
%       Optional val(2,3) moves the measurement point away from 0,0.  Makes
%       meas_o obsolete.
% meas_o: as meas, but measure at current voltages, not 0,0
% ramp: ramp to val (row vector, one entry for each channel) in time.  opt val(3) is multiplier
% comp: measurement compensation at val(1:2) (one for each channel) for duration time(1). 
%       Ramps voltage to target and back over time(2) and time(3) at the beginning and 
%       end of the stage, respectively. If length(val)>=4, val(3:4) are used as final value.
%       The compensation value could be determined automatically, but this feature is not 
%       implemented yet.
% adprep: adiabatic ramp along second diagonal (epsilon) from val(1) to val(2), ramp duration time.
% adread: same, going the other way.
%
% MARKTAB:
%  each column gives a marker pulse
%  [ start_time; ch1_mk1_wid ; ch1_mk2_wid ; ch_2_mk1_wid ...]
% ie,
%  [ 2 ; 0 ; 1 ; 0 ; 1 ] fires markers ch1mk2 and ch2mk2 for 1 us starting at 2us.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.



pulse = plsdefault(pulse);

% read from database, assumed to have valid format
% if ~isstruct(pulse)
%     pulse = plsdata(pulse);
% end
% while strcmp(pulse.format, 'ind')
%     pulse = plsdata.pulses(pulse.data);
% end
        
dt=-1e-9;  % Shortest meaninful length

switch pulse.format
    case 'tab'
        return;
       
    case 'elem'
        
        pulsetab = zeros(3, 0);
        marktab =  zeros(5, 0);
        comppos = [];
        fillpos = [];
        readout = [];
        readpos = [];
        pulsefn=[]; 
        
        pulsedef = pulse.data;
        
        for i = 1:length(pulsedef)

            switch pulsedef(i).type

                case 'raw'
                    pulsetab = [pulsetab, [pulsedef(i).time; pulsedef(i).val]];

                case 'mark'
                    marktab = [marktab, pulsedef(i).time'];

                case 'fill'
                    fillpos = size(pulsetab, 2);
                    filltime = pulsedef(i).time(1);
                    fillmarkpos = size(marktab,2);                    
                case 'wait'
                    if pulsedef(i).time(1) > 1e-11
                        pulsetab(1, end+(1:2)) = pulsetab(1, end) + [dt, pulsedef(i).time(1)]; %pinf.tbase*1e6/pinf.clk.
                        if length(pulsedef(i).val) > 2
                          pulsetab(2:3, end+(-1:0)) = repmat(pulsedef(i).val(3)*pulsedef(i).val(1:2)', 1, 2);
                        else
                          pulsetab(2:3, end+(-1:0)) = repmat(pulsedef(i).val(1:2)', 1, 2);
                        end
                    end
                case 'mwait'; % multiple wait
                    if pulsedef(i).time(1) > 1e-11
                        lseg = length(pulsedef(i).val)-1;
                        pulsetab(1, end+(1:2*lseg)) = pulsetab(1, end) + cumsum(reshape([repmat(dt,1,lseg); pulsedef(i).time],1,2*lseg));
%                         pulsetab(1, end+(1:2*lseg)) = pulsetab(1, end) + reshape([cumsum(pulsedef(i).time)+dt-pulsedef(i).time(1); cumsum(pulsedef(i).time)],1,2*lseg);
                        % first find non-'zeros' values and scale
                        mask=find(pulsedef(i).val(1:lseg)<pulsedef(i).val(lseg));
                        pulsedef(i).val(mask)=pulsedef(i).val(mask).*pulsedef(i).val(end);
                        %find values above base val and make them base val
                        mask=find(pulsedef(i).val(1:lseg)>pulsedef(i).val(lseg));
                        pulsedef(i).val(mask)=pulsedef(i).val(lseg);
                        %make pulsetab
                        pulsetab(2, end+(-(2*lseg-1):0)) = reshape(repmat(pulsedef(i).val(1:lseg),2,1),1,2*lseg);
                        pulsetab(3, end+(-(2*lseg-1):0)) = -reshape(repmat(pulsedef(i).val(1:lseg),2,1),1,2*lseg);
                        

                    end

                case 'reload'
                    % If we're filling the load, push the fillpos 1 forward
                    % so we stretch the wait at the loadpos, not the ramp
                    % to the loadpos                    
                    % Ignore zero length loads
                    if pulsedef(i).time(2) > 1e-11
                      fillload = (fillpos == size(pulsetab,2));                        
                      pulsetab(1, end+(1:4)) = pulsetab(1, end) + cumsum(pulsedef(i).time([1 2 1 3]));
                      pulsetab(2:3, end+(-3:0)) = [repmat(pulsedef(i).val(1:2)', 1, 2), zeros(2)];
                      fillpos = fillpos + fillload;                    
                    end
                case 'meas_o' % offset measurement
                    pulsetab(1, end+(1:2)) = pulsetab(1, end) + [dt, pulsedef(i).time(1)]; %pinf.tbase*1e6/pinf.clk.
                    pulsetab(2:3, end-1) = pulsetab(2:3,end-2);
                    pulsetab(2:3, end) = pulsetab(2:3,end-2);
                    marktab(:, end+1) = [pulsetab(1, end-2)+pulsedef(i).time(2); 0; 0; 0; pulsedef(i).time(1:3)*[1; -1; -1]];
                    if ~isempty(pulsedef(i).val)
                        readout(end+1, :) = [pulsedef(i).val, pulsetab(1, end-2) + pulsedef(i).time(4), pulsedef(i).time([1 4 5])*[1; -1; -1]];
                        readpos(end+1) = size(pulsetab, 2)-2;
                    end
                    
                case 'meas'
                    if length(pulsedef(i).val) == 3
                        mpnt = pulsedef(i).val(2:3);
                    else
                        mpnt = [0,0];
                    end
                    pulsetab(1, end+(1:2)) = pulsetab(1, end) + [dt, pulsedef(i).time(1)]; %pinf.tbase*1e6/pinf.clk.
                    pulsetab(2:3, end-1) = mpnt;
                    pulsetab(2:3, end) = mpnt;
                    marktab(:, end+1) = [pulsetab(1, end-2)+pulsedef(i).time(2); 0; 0; 0; pulsedef(i).time(1:3)*[1; -1; -1]];
                    if length(pulsedef(i).val) > 0 && ~isnan(pulsedef(i).val(1))
                        readout(end+1, :) = [pulsedef(i).val(1), pulsetab(1, end-2) + pulsedef(i).time(4), pulsedef(i).time([1 4 5])*[1; -1; -1]];
                        readpos(end+1) = size(pulsetab, 2)-2;
                    end

                case 'ramp'
                    %allow for multiplies in ramps- helps get direction
                    %right
                    if length(pulsedef(i).val) ==3
                        mult = pulsedef(i).val(3);
                    else
                        mult = 1;
                    end
                    pulsetab(1, end+1) = pulsetab(1, end) + pulsedef(i).time(1);
                    pulsetab(2:3, end) = mult*pulsedef(i).val(1:2);

                case 'comp'
                    comppos = size(pulsetab, 2)+1;
                    compval  = pulsedef(i).val(1:2);

                    pulsetab(1, end+(1:4)) = pulsetab(1, end) + [0 pulsedef(i).time(2), pulsedef(i).time(1)-sum(pulsedef(i).time(2:3)), ...
                        pulsedef(i).time(1)];
                    pulsetab(2:3, end+(-3:0)) = 0;
                    if length(pulsedef(i).val) >= 4
                        pulsetab(2:3, end) = pulsedef(i).val(3:4);
                    end

                case 'adprep'
                    if pulsedef(i).time(1) > 1e-11
                        pulsetab(1, end+(1:2)) = pulsetab(1, end) + [dt, pulsedef(i).time(1)];
                        if(length(pulsedef(i).val) <= 2)
                            dir=[-1 1];
                        else
                            dir = pulsedef(i).val(3:4);
                        end
                        pulsetab(2:3, end-1) = pulsedef(i).val(1)  * dir;
                        pulsetab(2:3, end) = pulsedef(i).val(2) * dir;
                    end
                case 'adread'
                    if pulsedef(i).time(1) > 1e-11
                        pulsetab(1, end+(1:2)) = pulsetab(1, end) + [dt, pulsedef(i).time(1)];
                        if(length(pulsedef(i).val) <= 2)
                            dir=[-1 1];
                        else
                            dir = pulsedef(i).val(3:4);
                        end
                        pulsetab(2:3, end-1) = pulsedef(i).val(2)  * dir;
                        pulsetab(2:3, end) = pulsedef(i).val(1)  * dir;
                    end
                    
                case 'rf'
                    global plsdata; % needed for tbase to scale freq
                    
                    
                    % val = [freq amplitude phase]
                    %                      pulsedef(i).val(1) = pulsedef(i).val(1)./ (1e9/plsdata.tbase);
                    
                    freq=pulsedef(i).val(1); %in MHz
                    amp=pulsedef(i).val(2); % in mV
                    phase=pulsedef(i).val(3); % in rads
                    fm_f= pulsedef(i).val(4); % frequency of FM modulation
                    fm_amp=pulsedef(i).val(5); % depth of FM modulation (zero-peak)
       
                    I = @(t) 2*amp*cos(2*pi*freq*t+fm_amp*sin(2*pi*fm_f*t)+phase); % AWG expects Vpp on default, Vpp=2*Vp, I and Q scaled
                    zero = @(t) 0;
                    
                                 
                    if pulsedef(i).time(1) > 1e-11
                        pulsetab(1, end+1) = pulsetab(1, end) + pulsedef(i).time(1);
                        pulsetab(2:3,end) = [I(pulsedef(i).time(1));0];
                        pulsefn(end+1).fn = {I,zero};
                        pulsefn(end).t = [pulsetab(1,end+(-1:0))];
                    else
                        pulsetab = [pulsetab, [0; I(0); 0]];  
                    end
%                   'rf' has marktab HIGH for M1 and M2 during rf pulse  
                    marktab(:, end+1) = [pulsetab(1, end-1)-pulsedef(i).time(2); 0; pulsedef(i).time(1:3)*[1; 1; 1]; 0; 0];
                    
                case 'rf_chirp'   ;% linear sweep of freq over edsr burst 
                    global plsdata; % needed for tbase to scale freq
                    
                    % val = [freq amplitude phase fm_amp(p-p) tau]
                    % pulsedef(i).val(1) = pulsedef(i).val(1)./ (1e9/plsdata.tbase);
                    
                    freq=pulsedef(i).val(1); %in MHz
                    amp=pulsedef(i).val(2); % in mV
                    phase=pulsedef(i).val(3); % in rads
                    fm_amp=pulsedef(i).val(4); % depth of FM modulation (full min-max range)
                    tau = pulsedef(i).time(1); % length of edsr burst
                    
                    I = @(t) 2*amp*cos(2*pi*((freq-fm_amp/2)*t+((fm_amp/tau)*t.^2)+phase)); % AWG expects Vpp on default, Vpp=2*Vp, I and Q scaled
                    zero = @(t) 0;
                    
                    if pulsedef(i).time(1) > 1e-11
                        pulsetab(1, end+1) = pulsetab(1, end) + pulsedef(i).time(1);
                        pulsetab(2:3,end) = [I(pulsedef(i).time(1));0];
                        pulsefn(end+1).fn = {I,zero};
                        pulsefn(end).t = [pulsetab(1,end+(-1:0))];
                    else
                        pulsetab = [pulsetab, [0; I(0); 0]];
                    end
                    %                   'rf_chirp' has marktab HIGH for M1 and M2 during rf pulse
                    marktab(:, end+1) = [pulsetab(1, end-1)-pulsedef(i).time(2); 0; pulsedef(i).time(1:3)*[1; 1; 1]; 0; 0];
                  
                case 'rfmarkoff'
                    global plsdata; % needed for tbase to scale freq
                    
                    
                    % val = [freq amplitude phase]
                    %                      pulsedef(i).val(1) = pulsedef(i).val(1)./ (1e9/plsdata.tbase);
                    
                    freq=pulsedef(i).val(1); %in MHz
                    amp=pulsedef(i).val(2); % in mV
                    phase=pulsedef(i).val(3);
                    fm_f= pulsedef(i).val(4); % frequency of FM modulation
                    fm_amp=pulsedef(i).val(5); % depth of FM modulation (zero-peak)
       
                    I = @(t) amp*cos(2*pi*freq*t+fm_amp*sin(2*pi*fm_f*t)+phase); % AWG expects Vpp on default, Vpp=2*Vp, I and Q scaled
                    zero = @(t) 0;
                    
                                 
                    if pulsedef(i).time(1) > 1e-11
                        pulsetab(1, end+1) = pulsetab(1, end) + pulsedef(i).time(1);
                        pulsetab(2:3,end) = [I(pulsedef(i).time(1));0];
                        pulsefn(end+1).fn = {I,zero};
                        pulsefn(end).t = [pulsetab(1,end+(-1:0))];
                    else
                        pulsetab = [pulsetab, [0; I(0); 0]];  
                    end
%                   'rf' has marktab HIGH for M1 and M2 during rf pulse  
                    marktab(:, end+1) = [pulsetab(1, end-1)-pulsedef(i).time(2); pulsedef(i).time(1:3)*[0; 0; 0]; pulsedef(i).time(1:3)*[0; 0; 0]; 0; 0];
                                        
                                        
                otherwise
                    error('Invalid pulse element %i: %s.\n', i, pulsedef(i).type)
            end
        end

        if ~isempty(comppos)
            pulsetab(2:3, comppos+(1:2)) = 2*repmat(compval(1:2)', 1, 2);
        end

        %pulsetab(2:3, :) = pulsetab(2:3, :)./pinf.scale;
        %pinf = rmfield(pinf, 'scale');

        if ~isempty(fillpos)
            filltime = filltime - pulsetab(1, end);
            if filltime < 0
                pulsetab
                error('Pulse too long by %g (target %g).',-filltime,filltime+pulsetab(1,end));
            end
            pulsetab(1, fillpos+1:end) = pulsetab(1, fillpos+1:end) + filltime;
            if ~isempty(readpos)
                readout(readpos > fillpos, 2) = readout(readpos > fillpos, 2) + filltime;
            end
            marktab(1, fillmarkpos+1:end) = marktab(1, fillmarkpos+1:end) + filltime;
        end

        mask = all(abs(diff(pulsetab(2:3, :), [], 2)) < 1e-14);
        pulsetab(:, [false, mask(2:end)&mask(1:end-1)]) = [];

        pulse.data = struct;
        pulse.data.pulsetab = pulsetab;
        
        if ~isempty(pulsefn)
            pulsefn.t(1:end)=pulsefn.t(1:end)+filltime;
            pulse.data.pulsefn=pulsefn;
        end
        
        
        pulse.data.marktab = sortrows(marktab',1)';
        pulse.data.readout = readout;
        pulse.data.elem=pulsedef;  % Copy forward documentation.
        pulse.format = 'tab';
        
    otherwise
        error('Invalid format %s.', pulse.format);
end


        
