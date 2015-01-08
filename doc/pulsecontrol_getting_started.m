%% Special Measure Pulsecontrol: Getting Started
%
%% What Is Pulsecontrol?
% Pulsecontrol is a script bundle with the aim to standardise the operation
% of Arbitrary Waveform Generators (AWGs) in a MATLAB(R) context. Pulses
% for AWGs can be created using a flexible syntax. They are stored in a global
% database (|plsdata|). Groups of pulses from |plsdata| can be transfered
% to an AWG for execution in sequence.
%
% An AWG is represented in the data structure |awgdata|. Changes to pulses
% loaded to an AWG are documented, by autosaving the current AWG state.

%% What Is A Pulse?
% An AWG runs so called waveforms. Waveforms consist of a number of
% values stepped through with a certain clock rate.
%
% The values can range from -1 to 1 and are mapped according to the maximum
% peak-to-peak amplitude on the device to a voltage:
%
% <html>
%  <table border=1 bordercolor=black>
%   <tr><td>voltage</td><td>normalized value</td></tr>
%   <tr><td>offset - amplitude(p-p)/2</td><td>-1</td></tr>
%   <tr><td>offset + amplitude(p-p)/2</td><td>+1</td></tr>
%  </table>
% </html>
%
% Exceding values are clipped.
%
% Besides the analog part of the data, a waveform inclueds two digital marker
% parts, which can be set for every clock individually to 'on' or 'off' on
% additional output channels.
% This is useful for triggering other instruments based on the index
% position within the waveform.
% More Information on the 14-bit integer encoding used for
% transmission and storage of pulses on the AWG can be found in
% <matlab:doc('awgload') awgload.>
%
% Waveforms are produced by a more general data type in Pulsecontrol called
% a pulse.
%
% In Pulsecontrol a pulse can be created in several ways defined by the
% following formats:
%
% * |'wf'| is the most basic format. The pulse is described via
% data values for every clock of the AWG. This is the format transmitted to
% the instrument and corresponds to a waveform.
% * |'tab'| defines pulses in a tabular manner. Data values are defined at
% distinct times of the pulse. The intermediate values are ramped.
% * |'elem'| defines pulses out of several pulse elements. A pulse element
% describes distinct shapes controlled by parameters, e.g. 'wait' will stay
% at at a specific voltage for a given time.
%
% The format of a pulse is determinded by the string |pinf.format| where
% |pinf| is a data structure defining the pulse.
%
% Pulses of the format |'elem'| and |'tab'| are converted into |'wf'| when
% transmitted to the AWG.
%
%% What Setup Do I Need?
% To use Pulsecontrol the AWG must be connected and opened for
% communication via the Instrument Control Toolbox(TM). Two global data
% structures |plsdata| and |awgdata| must be present in the MATLAB(R) workspace.
% |awgdata| contains the instrument object, a representation of uploaded
% pulses and other important poroperties. |plsdata| contains
% pulsedefenitions and defines paths where to store groups of pulses, and
% backup |awgdata|. The next section
% describes the creation and upload of a pulse plus the necessery setup.
%
%% Example: Creation Of A Simple Pulse Using Example |plsdata|, |awgdata| 
% The example data structures |plsdata| and |awgdata| can be created by
% executing the scripts <matlab:open(fullfile(fileparts(which('plstotab')),'html','awgsetup.m')) awgsetup.m> and 
% <matlab:open(fullfile(fileparts(which('plstotab')),'html','plssetup.m')) plssetup.m>
% Copy them to your own location, for modification purposes.

plssetup
awgsetup


%%
% They define necessary properties in the structures and create a folder
% structure to store pulses and AWG states for Pulsecontrol. Now a pulse
% can be defined.

clear pinf;
pinf.name = 'pulse1';
pinf.data.pulsetab = [0 1; 0.1 0.3; 0.2 0.4];

%%
% The above code creates a pulse of the format |'tab'| with the name
% 'pulse1'. The format is specified automatically depending on the content of
% |pinf.data|. In this case a |pulsetab| array creates a |'tab'| pulse. The
% first row in the array defines the time. While the subsequent two rows
% define values at this times. Since start and end value are not
% equal, the intermediate values are linear interpolated. The length of the
% rows is arbitrary.
%
% The atomar unit of time is 1ns. A scaling factor |plsdata.tbase| is used
% when evaluating time in Pulsecontrol. The default
% value is 1000. Thus |pinf| is a pulse of 1ns* |plsdata.tbase| *1 = 1us,
% which reaches 1 starting from 0 in 1200 steps for a clock speed of 1.2GHz
% of the connected AWG. The used speed can be found in awgdata.clk.
%
% <html>
%  <table border=1 bordercolor=black>
%   <tr><td>time</td><td>first chan.</td><td>second chan.</td></tr>
%   <tr><td>0</td><td>0.1</td><td>0.3</td></tr>
%   <tr><td>1</td><td>0.2</td><td>0.4</td></tr>
%  </table>
% </html>
%
% Since the values have an arbitrary unit and the resulting voltage is
% dependent on the actual settings of the AWG peak-to-peak voltage, it is
% commune to normalize the values to the unit 'mV' using awgdata.scale and
% when requiered awgdata.offset.
%
% The created pulse can be plotted using the function |plsplot()|.

plsplot(pinf);

%%
% |pinf| is then added into the |plsdata.pulses| database at the index |plsnum|.

plsnum = 1;
plsreg(pinf, plsnum);

%%
% Next a pulse group needs to be defined. Only groups can be
% uploaded to the AWG. In this case the group consist of only one pulse.

clear pg;
pg.name='pulse1_loop';
pg.ctrl = 'notrig'; % no trigger signal
pg.pulses = plsnum; % index of pulse1
pg.nrep = Inf;
pg.chan = [1 2];

%%
% Pulse 'pulse1' is selected by the index |plsnum| of the database. For several
% pulses an 1xm index array can be specified in |pg.pulses|, then the pulses are
% concatenated together.
%
% |pg.nrep| can be used to specify the number of repetitions of the group.
% |pg.chan| defines which physical channels are used to output the pulse.
% More advanced options are possible. Further information can be found in the
% <pulsecontrol_user_guide.html User Guide>.
%
% The function |plsdefgrp()| is used to save the group as a mat-file to
% disk inside |plsdata.grpdir| with the name 'gr_pulse1_loop'.

plsdefgrp(pg);

%%
% All supported features of a group can be found in the comment of
% <matlab:doc('plsdefgrp') plsdefgrp.>
%
% Finally the group is added to end of the sequence of the connected AWG
% with:

awgadd('pulse1_loop')

%%
% Copyright 2009 Not The MathWorks, Inc.
