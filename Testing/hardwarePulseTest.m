function hardwarePulseTest()
    InitializePulseData;


    pulseBuilder = RandomTestPulseBuilder([-0.5 0.5]);
    configurationProvider = RawIOTestConfigurationProvider(1, pulseBuilder);
    testSetup = IOTestDriver(configurationProvider);

    testSetup.run();
end