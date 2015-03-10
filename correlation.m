function retval = isCorrelated(expected,measured,maxSingle,maxAll)
retval = true;
% expected = randomList(1000,0);
% measured = disturbList(expected,0,0);
diffvec = abs(expected - measured);
if (max(diffvec) < maxSingle):
    Disp('Single value differs to wide')
    retval = false;
    plot(diffvec,'.')
if (sum(diffvec.^2))/length(diffvec) < maxAll):
    Disp('Overall values differs to wide')
    retval = false;
    plot(diffvec, '.')
else
    retval = true;
end
end
end

function retval = randomList(length,seed)
rng(seed);
retval = rand(1,length)*2-1;
end

function retval = disturbList(list,disturbance,seed)
rng(seed);
lengthOfTheDisturbance = length(list);
retval = list + (rand(1,lengthOfTheDisturbance)-1)*disturbance;
end