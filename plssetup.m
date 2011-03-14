% (c) 2011 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.
% Copyright 2011 Hendrik Bluhm, Vivek Venkatachalam
% This file is part of Special Measure.
% 
%     Special Measure is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     Special Measure is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with Special Measure.  If not, see <http://www.gnu.org/licenses/>.

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
