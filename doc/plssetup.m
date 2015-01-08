%% create pulse database from scratch for iq mixer calibration
clear global plsdata;
global plsdata;

% name of database
dbName = 'iqmx';

% get the path to this script
[scriptPath, ~, ~] = fileparts(mfilename('fullpath'));

% save pathes in database
plsdata.datafile = [scriptPath '/awg_pulses/plsdata_' dbName '.mat'];
plsdata.grpdir = [scriptPath '/awg_pulses/pulsegroups_' dbName '/'];

% create pulse structure
% plsdata.pulses = struct('data', {}, 'format', {}, ...
% 	'xval',{}, 'taurc',{}, 'name',{},'trafofn',{},'pardef',{});
plsdata.pulses = struct('name', {}, 'data', {}, ...
	'xval',{}, 'taurc',{}, 'pardef',{},'trafofn',{},'format',{});

% set timebase to microseconds
plsdata.tbase = 1000;

% create folders
mkdir 'awg_pulses';
mkdir(plsdata.grpdir);

% save database
plssync('save');

% clean up
clear dbName scriptPath;