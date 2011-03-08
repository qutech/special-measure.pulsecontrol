function zerolen = awgzero(grp, ind, zerolen)
% zerolen = awgzero(grp, ind, zerolen)
% determine if pulse is zero (helper function)

%global plsdata;
global awgdata;

for i = 1:length(grp.pulses)
    
    data = uint16(min((grp.pulses(i).data.wf./awgdata.scale + 1)*2^13 - 1, 2^14-1)) + uint16(grp.pulses(i).data.marker) * 2^14;
    npts = size(data, 2);

    for j = 1:size(data, 1)
        % optionally catenate pulses and write outside main loop.
        if ~all(data(j, :) == 2^13-1)
            zerolen(ind(i), j) = -npts;
        else
            zerolen(ind(i), j) = npts;
        end
    end
end


