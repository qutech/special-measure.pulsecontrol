%% Functions by Category
% Special Measure Pulsecontrol
%
% Requires Instrument Control Toolbox(TM).
%
%% AWG Control
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgadd.m')) |awgadd(groups)|>
%
% Uploads one or more pulsegroups to the connected AWG.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgclear.m')) |awgclear(groups,options)|>
%
% Used to delete pulses from the AWG or clear them up.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgcntrl.m')) |val = awgcntrl(cntrl, chans))|>
%
% Control the AWG to start/stop, etc.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awggetdata.m')) |data = awggetdata(time)|>
%
% Load latest awgdata.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awggroups.m')) |awggroups(ind)|>
%
% Prints a list of the pulsegroups in the awgdata struct.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awggrpind.m')) |grp = awggrpind(grp)|>
%
% Find group index in awgdata.pulsegroups based on provided group name.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awglist.m')) |awglist(ind,awg)|>
%
% List the waveforms present on an AWG.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgload.m')) |zerolen = awgload(grp, ind)|>
%
% Transmit pulses from group to AWG.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgloaddata.m')) |awgloaddata()|>
%
% Load latest awgdata file saved by awgsavedata().
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgnpulse.m')) |awgnpulse(groups, npulse)|>
%
% Set npulse for pulsegroups.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgrm.m')) |awgrm(grp, ctrl)|>
%
% Used to delete pulses from the AWG.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgsavedata.m')) |awgsavedata()|>
%
% Save awgdata in plsdata.grpdir, with name generated from date and time.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgseqind.m')) |seqind = awgseqind(pulses,rep)|>
%
% Find the pulse line associated with a pulse group or pulse index.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgswap.m')) |awgswap(name)|>
%
% Swap the current active AWG with an alternative.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgsyncwaveforms.m')) |awgsyncwaveforms()|>
%
% Make sure the list of pulses is awgdata is consistent with the AWG.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgupdate.m')) |awgupdate(groups)|>
%
% Obsolete!
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgwaveforms.m')) |waveforms = awgwaveforms(group,awg,opts)|>
%
% Give a list of waveforms that are known to be loaded.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'awgzero.m')) |zerolen = awgzero(grp, ind, zerolen)|>
%
% Helper function to determine if a pulse is zero.
%
% <html>
%  <br>
% </html>
%
%% Pulse Databse Management
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsdefault.m')) |pulse = plsdefault(pulse)|>
%
% Enshures correct pulse-formating and updates the format-string pulse.format depending on
% the content of pulse.data.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plslist.m')) |inds = plslist(rng, name)|>
%
% Tabular representation of specified pulses.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsplot.m')) |plsplot(pulse, dict, ctrl)|>
%
% Plots pulse using plstowf() as time vs. channelA and channelB, channelA
% vs. channelB, time vs. markerA and markerB.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsreadxval.m')) |plsreadxval()|>
%
% Extracts xval from pulses inside plsdata.pulses database and collecting
% them in plsdata.xval.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsreg.m')) |plsnum = plsreg(pulse, plsnum)|>
%
% Adds pulse to plsdata.pulses database, while enshuring correct elements
% and correct order of elements.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plssync.m')) |plssync(ctrl)|>
%
% Used to save and load pulse databese plsdata, while enshuring correct
% path-handling.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plstotab.m')) |pulse = plstotab(pulse)|>
%
% Downconverts pulses of format 'elem' to format 'tab'.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsIqFnCreate.m')) |[I Q] = plsIqFnCreate(coeff, ...)|>
%
% Auxiliary function for plstotab(), to process pulse elements of type
% 'rfpulse'.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plstowf.m')) |pulse = plstowf(pulse, dict)|>
%
% Downconverts pulses of format 'tab' to format 'wf'.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsdefgrp.m')) |plsdefgrp(grpdef)|>
%
% Enshures correct group-formating. Saves a pulse group to the path
% specified in plsdata.grpdir.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plslint.m')) |plslint(pg)|>
%
% Some preliminary checks for a pulsegroups.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsmakegrp.m')) |grpdef = plsmakegrp(name, ctrl, ind, opts)|>
%
% Processes pulse group to 'wf' format and saves to disk. Used by 
% awgadd(). Can be controlled by a string ctrl containing swiches:
%
% * 'plot': plot pulse group
% * 'check': check if any voltage value is out of awgdata.scale bounds
% * 'upload': uploads pulse group to the AWG
%
% Changes to the pulsegroup are logged inside plslog (stored with pulse).
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsupdate.m')) |plsupdate(newdef)|>
%
% Updates the fields of a pulsegroup. The fields name, chan, markmap, offset, pulseind,
% pulses cannot be updated. Formatting of the other fields must remain the
% same.
%
% <html>
%  <br>
% </html>
%
% <matlab:open(fullfile(fileparts(which('plstotab')),'plsinfo.m')) |val = plsinfo(ctrl, group, ind, time)|>
%
% Used to retrieve fileds of a pulsegroup at a given time or
% check if the provided group is stale ( previously not existing, old
% timestamp, ...).
% Variable at a given time can be reclaimed using the ctrl strings:
%
% * 'ro': returns readout
% * 'zl': returns zerolen
% * 'gd': returns grpdef
% * 'sl': returns seqlog
%
% Ctrl strings not honoring time:
%
% * 'ls': list/returns pulsegroup(s) of provided name(mask) in grpdir. E.g. 'dBz*'
% * 'params': returns params
% * 'pl' or 'log': returns plslog
% * 'rev': prints avalible revisions of the pulse in plslog
% * 'stale': returns, whether the pulse is stale or not
%
% Copyright 2007-2009 Not The MathWorks, Inc.
