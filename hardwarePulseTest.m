function hardwarePulseTest()
    time = 2^14; %us

    % pulse to test
    testPulseGroup = initPulseGroup(time);

        % DAQ card
    inputChannel = 1;
     testDAC = initDAC(time,inputChannel);

    global vawg;
    vawg = [];
    % awg to test
    vawg = initVAWG();

    
    vawg.add(testPulseGroup.name);
    vawg.setActivePulseGroup(testPulseGroup.name);

    vawg.arm();



    % issues trigger
     testDAC.startMeasurement(1);
    %calllib('PXDAC4800_64','IssueSoftwareTriggerXD48',vawg.awgs(1).handle);
    fprintf('START\n');
    while vawg.isPlaybackInProgress()
        pause(1);
        fprintf('Waiting for playback to finish...\n');
    end
    
     measuredData = testDAC.getResult(inputChannel);
    
      plot(measuredData);
    
%     compareData(testPulseGroup.pulses,measuredData);

end

%
function dacobject  = initDAC(time,inputChannel)
    dacobject = ATS9440(1);
    
    dacobject.samprate = 100e6; %samples per second
    sis = time * dacobject.samprate / 1e6; % samples in scanline
    
    dacobject.useAsTriggerSource();
    
    mask.begin = uint32(0);
    mask.end = uint32(2^10);
    mask.period = uint32(2^10);
    mask.hwChannel = uint32(1);
    mask.type = 'Periodic Mask';
    
    dacobject.masks{1} = mask;
    
    
    dacobject.configureMeasurement(2^10,sis/2^10,inputChannel);
end

function vawg = initVAWG()
    vawg = VAWG();
    
    awg = PXDAC_DC('messrechnerDC',1);
    awg.setOutputVoltage(1,1);
    
    calllib('PXDAC4800_64','SetClockDivider1XD48',awg.handle,12);
    calllib('PXDAC4800_64','SetClockDivider2XD48',awg.handle,1);
    
    vawg.addAWG(awg);
    vawg.createVirtualChannel(awg,1,1);
%     vawg.createVirtualChannel(awg,2,2);
%     vawg.createVirtualChannel(awg,3,3);
%     vawg.createVirtualChannel(awg,4,3);
end

function pulsegroup = initPulseGroup(time)
    N = 2;
    rng(42);
    
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
    
    pulse.data.pulsetab = zeros(2,N);
    pulse.data.pulsetab(1,:) = linspace(1,time,N);
    %pulse.data.pulsetab(2,:) = rand(1,N)*2 - 1;
    pulse.data.pulsetab(2,:) = [1 -1];
    
    pulse.name = 'hardwareTestPulse';
    
    pulsegroup.pulses = plsreg(pulse);
    pulsegroup.nrep = 1;
    pulsegroup.name = 'hardwareTestPulseGroup';
    pulsegroup.chan = 1;
    pulsegroup.ctrl = 'notrig';
    
    plsdefgrp(pulsegroup);
end

function compareData(expected,measured)
    error('');
end

