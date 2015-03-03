function hardwarePulseTest()
    time = 1000000; %us

    % pulse to test
    testPulseGroup = initPulseGroup(time);

    % DAQ card
    inputChannel = 1;
    testDAC = initDAC(time,inputChannel);

    % awg to test
    testVAWG = initVAWG();

    
    testVAWG.add(testPulseGroup.name);
    testVAWG.setActivePulseGroup(testPulseGroup.name);

    testVAWG.arm();
    
    % has to be adapted
    testDAC.issueTrigger();
    
    while testVAWG.playbackInProgress()
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
    
    dacobject.configureMeasurement(1,sis,inputChannel);
end

function vawg = initVAWG()
    vawg = VAWG();
    
    awg = PXDAC_DC('messrechnerDC',1);
    awg.setOutputVoltage(1,1);
    
    vawg.addAWG(awg);
    vawg.createVirtualChannel(awg,1,1);
end

function pulsegroup = initPulseGroup(time)
    N = 1000;
    rng(42);
    
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

