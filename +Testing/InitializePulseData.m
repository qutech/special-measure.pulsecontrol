global plsdata;
plsdata = [];
plsdata.datafile = [tempdir 'hardwaretest\plsdata_hw'];
plsdata.grpdir = [tempdir 'hardwaretest\plsdef\plsgrp'];
try
    rmdir([tempdir 'hardwaretest'],'s');
end
mkdir(plsdata.grpdir);

plsdata.pulses = struct('data', {}, 'name', {},	'xval',{}, 'taurc',{}, 'pardef',{},'trafofn',{},'format',{});
plsdata.tbase = 1000;