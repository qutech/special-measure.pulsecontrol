function plssync(ctrl)
% plssync(ctrl)
% ctrl: load, save
global plsdata;

switch ctrl  
    case 'load'        
       % avoid complications when moving across computers.
       df = plsdata.datafile;
       load(plsdata.datafile);
       plsdata.datafile = df;
       plsdata.grpdir =  [plsdata.datafile(1:strfind(plsdata.datafile, '/')), ...
           plsdata.grpdir(strfind(plsdata.grpdir, '/')+1:end)];
       
       %plsdata.xval = zeros(1, length(plsdata.pulses));       
       %for i = 1:length(plsdata.pulses)
       %    plsdata.xval(i) = plsdata.pulses(i).xval(1);
       %end

    case 'save'
        save(plsdata.datafile, 'plsdata');
end
