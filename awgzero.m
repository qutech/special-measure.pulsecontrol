function zerolen = awgzero(grp, ind, zerolen)
% zerolen = awgzero(grp, ind, zerolen)
% determine if pulse is zero (helper function)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


%global plsdata;
global awgdata;

for i = 1:length(grp.pulses)
    npts=size(grp.pulses(i).data.wf,2);
    for j = 1:size(grp.pulses(i).data.wf, 1)        
        if any(abs(grp.pulses(i).data.wf(j, :)) > awgdata.scale(j)/(2^14)) || any(grp.pulses(i).data.marker(j,:) ~= 0)
            zerolen(ind(i),j) = -npts;
        else
            zerolen(ind(i),j) = npts;
        end
    end
end


