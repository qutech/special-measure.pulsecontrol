%% create awg structure from scratch
clear global awgdata;
global awgdata;

% number of instrument channels
nChan = 4;


awgdata.chans = 1:nChan; % determines order of channels, not used
awgdata.scale = ones(1,nChan); % pre-scale waveform valus before upload. 
                               % Used with offset to relate arbitrary
                               % pulse scale to, e.g. mV
awgdata.pulsegroups = []; % pulsegroups synchroniced with the AWG
awgdata.zeropls = []; % available placeholder zero-pulse lengths
awgdata.triglen = 1200; % length of optional trigger pulse preceding a group
awgdata.clk = 1.2e9; % number of samples per second of instrument
awgdata.seqpulses = []; % !!! functinoality not clear
awgdata.waveforms = {''}; % waveforms present on instrument
awgdata.offset = zeros(1,nChan); % pre-offset waveform valus before upload
awgdata.zerochan = ones(1,nChan); % !!! functinoality not clear
awgdata.bits = 14; % bit-resolution of instrument.
                   % in case of AWG7000 12bit may be useable, check
awgdata.slave = []; % !!! elaborate
awgdata.current = 'awg5k'; % name of the current instrument
awgdata.awg=[]; % handle to the openend instrument object
awgdata.alternates = awgdata; % alternative configurations of awgdata

% save current awg
awgsavedata;

% clean up
clear nChan;