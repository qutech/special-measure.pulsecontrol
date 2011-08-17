function zerolen = awgzero(grp, ind, zerolen)
% zerolen = awgzero(grp, ind, zerolen,awg)
% determine if pulse is zero (helper function)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


%global plsdata;
global awgdata;
for awg=1:length(awgdata)
    scale=min(awgdata(awg).scale/2^(awgdata(awg).bits-1));
    for i = 1:length(grp.pulses)
        dind = find([grp.pulses(i).data.clk == awgdata(awg).clk);
        data = uint16(min((grp.pulses(i).data(dind).wf./awgdata(awg).scale + 1)*2^(awgdata(awg).bits-1) - 1, 2^awgdata(awg).bits-1)) + uint16(grp.pulses(i).data.marker) * 2^(awgdata(awg).bits);
        npts = size(data, 2);
        for j = 1:size(data, 1)
            % optionally catenate pulses and write outside main loop.
            if ~all(data(j, :) == 2^(awgdata(awg).bits-1)-1)
                zerolen{awg}(ind(i), j) = -npts;
            else
                zerolen{awg}(ind(i), j) = npts;
            end
        end
    end
end    
