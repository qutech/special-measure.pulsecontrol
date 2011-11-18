function zerolen = awgzero(grp, ind, zerolen)
% zerolen = awgzero(grp, ind, zerolen,awg)
% determine if pulse is zero (helper function)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


%global plsdata;
global awgdata;
for awg=1:length(awgdata)
    scale=min(awgdata(awg).scale/2^(awgdata(awg).bits-1));
    for i = 1:length(grp.pulses)
        dind = find([grp.pulses(i).data.clk] == awgdata(awg).clk);
        npts = size(grp.pulses(i).data(dind).wf, 2);
        for j=1:size(grp.pulses(i).data(dind).wf,1) % FIXME; channel mappings not honored here.
            if any(abs(grp.pulses(i).data(dind).wf(j,:) > awgdata(awg).scale(min(j,end))/(2^awgdata(awg).bits)))
                zerolen{awg}(ind(i),j) = -npts;
            else
                zerolen{awg}(ind(i),j) = npts;
            end
        end
    end
end    
