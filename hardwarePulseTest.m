function hardwarePulseTest()
    time = 1000000; %us

    % pulse to test
    testPulseGroup = initPulseGroup(time);



    global vawg;
    % awg to test
    vawg = initVAWG();

    
    vawg.add(testPulseGroup.name);
    vawg.setActivePulseGroup(testPulseGroup.name);

    vawg.arm();
    
        % DAQ card
    inputChannel = 1;
    testDAC = initDAC(time,inputChannel);
    
    % issues trigger
    testDAC.startMeasurement();
    
    while vawg.playbackInProgress()
        pause(1);
        fprintf('Waiting for playback to finish...\n');
    end
    
    measuredData = testDAC.getResult(inputChannel);
    
    compareData(testPulseGroup.pulses,measuredData);

end

%
function dacobject  = initDAC(time,inputChannel)
    dacobject = ATS9440(1);
    
    dacobject.samprate = 100e6; %samples per second
    sis = time * dacobject.samprate / 1e6; % samples in scanline
    
    dacobject.useAsTriggerSource();
    
    dacobject.configureMeasurement(1,sis,1,inputChannel);
end

function vawg = initVAWG()
    vawg = VAWG();
    
    awg = PXDAC_DC('messrechnerDC',1);
    awg.setOutputVoltage(1,1);
    
    vawg.addAWG(awg);
    vawg.createVirtualChannel(awg,1,1);
end

function pulsegroup = initPulseGroup(time)
    N = 10;
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
    pulse.data.pulsetab(2,:) = rand(1,N)*2 - 1;
    
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

