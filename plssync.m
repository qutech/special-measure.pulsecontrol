function plssync(ctrl)
% plssync(ctrl)
% ctrl: load, save

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

global plsdata;

switch ctrl  
    case 'load'        
       % avoid complications when moving across computers.
       df = plsdata.datafile;
       load(plsdata.datafile);
       plsdata.datafile = df;
       plsdata.grpdir =  [plsdata.datafile(1:strfind(plsdata.datafile, '/')), ...
           plsdata.grpdir(strfind(plsdata.grpdir, '/')+1:end)];
       
    case 'save'
        save(plsdata.datafile, 'plsdata');
end
