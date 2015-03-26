classdef MatlabTestDriver < matlab.unittest.TestCase
    % MatlabTestDriver A MATLAB unit test driver for hardware driver IO tests
    %
    
    methods (TestClassSetup)
        
        function initializePlsdata(self)
            % Employs the InitializePulseData script to create a temporary 
            % plsdata struct
            global plsdata;
            InitializePulseData;
        end
        
    end
    
    methods (TestClassTeardown)
        
        function removePlsdata(self)
            % Removes the temporary plsdata struct from global workspace
            clear -global plsdata;
        end
        
    end
    
    methods (Test)
        
        function testRawHardwareIO(self)
            % Tests raw hardware IO. A random signal is output and
            % read and checked for equality.
            pulseBuilder = RandomTestPulseBuilder();
            configurationProvider = RawIOTestConfigurationProvider(1, pulseBuilder);
            driver = IOTestDriver(configurationProvider);
            self.verifyTrue(driver.run());
        end
        
        function testPeriodicMaskDS(self)
            % Tests downsampling with periodic masks.
            pulseBuilder = DSTestPulseBuilder();
            configurationProvider = PeriodicMaskTestConfigurationProvider(1, pulseBuilder);
            driver = IOTestDriver(configurationProvider);
            self.verifyTrue(driver.run());
        end
        
        function testTableMaskDS(self)
            % Tests downsampling with a table mask.
            pulseBuilder = DSTestPulseBuilder();
            configurationProvider = TableMaskTestConfigurationProvider(1, pulseBuilder);
            driver = IOTestDriver(configurationProvider);
            self.verifyTrue(driver.run());
        end
        
        function testPeriodicMaskRSA(self)
            % Tests repetitive signal averaging with periodic masks.
            pulseBuilder = RSATestPulseBuilder();
            configurationProvider = PeriodicMaskTestConfigurationProvider(1, pulseBuilder);
            driver = IOTestDriver(configurationProvider);
            self.verifyTrue(driver.run());
        end
        
        function testTableMaskRSA(self)
            % Tests repetitive signal averaging with a table mask.
            pulseBuilder = RSATestPulseBuilder();
            configurationProvider = TableMaskTestConfigurationProvider(1, pulseBuilder);
            driver = IOTestDriver(configurationProvider);
            self.verifyTrue(driver.run());
        end
        
    end
    
end

