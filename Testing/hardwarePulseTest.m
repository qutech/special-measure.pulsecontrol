function hardwarePulseTest()
    InitializePulseData;


    testSetup = RawIOTestSetup();

    testSetup.init();
    testSetup.run();
end