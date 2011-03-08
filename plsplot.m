function plsplot(pulse, dict, ctrl)
% plsplot(pulse, dict, ctrl)

if ~exist('ctrl','var')
    ctrl = '';
end
if ~exist('dict','var')
    dict = '';
end

styles={'b-','r-','g-'};
for i = 1:length(pulse)
    figure(30);
    if isempty(strfind(ctrl,'hold'))
      clf;
    else        
      hold on;
      subplot(221); hold on;
      subplot(222); hold on;
      subplot(223); hold on;
    end

    pls = plstowf(pulse(i),dict);

    subplot(221)
    plot(pls.data.wf');%, time(1:end-1), round((data + vc)*2^13)./2^13);

    subplot(222)
    hold on;
    for j = 1:2:size(pls.data.wf, 1)-1
        plot(pls.data.wf(j, :), pls.data.wf(j+1, :),styles{(j+1)/2});%, data(1, :) + vc(1, :), data(2, :) + vc(2, :));
    end
    
    if  any(pls.data.marker(:))
        subplot(223)
        plot([bitand(pls.data.marker, 1); bitand(pls.data.marker, 2)./2]');
    end

    if i < length(pulse) && isempty(strfind(ctrl, 'nopause'))
        pause;
    end
end