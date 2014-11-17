function plsplot(pulse, dict, ctrl)
% plsplot(pulse, dict, ctrl)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

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
    
    % Added by Pascal on 13.06.2014 to plot in a current charge diagram
    if ~isempty(strfind(ctrl, 'chrg'))
      if ishandle(1)
        ax = findall(1,'type','axes');
        sp2 = subplot(222); hold on;        
        copyobj(allchild(ax(end)), sp2);
      end;
    end;

    pls = plstowf(pulse(i),dict);

    
    for c=1:length(pls.data)
        subplot(221)
        x=linspace(0,(size(pls.data(c).wf,2)-1)*1e9/pls.data(c).clk,size(pls.data(c).wf,2));
        
        plot(repmat(x,size(pls.data(c).wf,1),1)',pls.data(c).wf');%, time(1:end-1), round((data + vc)*2^13)./2^13);
        hold on;
        subplot(222)
        hold on;
        
        % Added by Pascal on 13.06.2014 to plot in a current charge diagram
        % This changes the units of subplot(222) so that charge diagram
        % fits. Therefore everything multiplied by 1e-3.
        if ~isempty(strfind(ctrl, 'chrg'))
          pls.data(c).wf = pls.data(c).wf.*1e-3;
          title('Multiplied by 1e-3');
        end;       
        
        for j = 1:2:size(pls.data(c).wf, 1)-1
            plot(pls.data(c).wf(j, :), pls.data(c).wf(j+1, :),styles{(j+1)/2});%, data(1, :) + vc(1, :), data(2, :) + vc(2, :));
        end
        
        if  any(pls.data(c).marker(:))
            subplot(223)
            plot(x,bitand(pls.data(c).marker, 1),'r',x, bitand(pls.data(c).marker, 2)/2,'g');
%             plot(x,pls.data(c).marker(1,:),'r',x, pls.data(c).marker(2,:)/2,'go');
        end
    end
    if i < length(pulse) && isempty(strfind(ctrl, 'nopause'))
        pause;
    end
end
