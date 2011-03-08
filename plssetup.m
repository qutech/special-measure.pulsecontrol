global awgdata;
global plsdata;


if strcmp(computer, 'GLNX86')
    plsdata.datafile = '~ygroup/qDots/awg_pulses/plsdata_1110.mat';
else
    plsdata.datafile = 'z:/qDots/awg_pulses/plsdata_1110.mat';
end
plssync('load');

if exist('smdata', 'var') && isfield(smdata, 'inst')
    awgdata.awg = smdata.inst(sminstlookup('AWG5000')).data.inst;
    awgloaddata;
%     awgdata.chans = 1:4;
%     awgdata.scale = 600/142;
%     awgdata.pulsegroups = [];
%     awgdata.zeropls = [];
%     awgdata.triglen = 1000;
%     awgdata.clk = 1e9;
end

return;

for i = 1:4
    fprintf(awgdata.awg, 'SOUR%i:VOLT:AMPL .6', i);
end

% using different interfaces
%awg = tcpip('140.247.189.142', 4000); % slow
%awg = visa('ni', 'TCPIP::140.247.189.142::INSTR');
%awg.OutputBufferSize = 2^18;