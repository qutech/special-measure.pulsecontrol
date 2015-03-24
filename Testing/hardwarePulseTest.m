function hardwarePulseTest()
    InitializePulseData;


    pulseBuilder = RandomTestPulseBuilder();
    configurationProvider = RawIOTestConfigurationProvider(1, pulseBuilder);
    testSetup = IOTestDriver(configurationProvider);

    testSetup.run();
end