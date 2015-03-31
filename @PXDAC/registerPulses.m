function registerPulses(self,grp)

            usedHWchanels = [];
            
            for c = grp.chan
                if any(self.virtualChannels == c)
                    usedHWchanels = [usedHWchanels self.getHardwareChannel( c ) ];
                end
            end
            
            channelMask = uint16(sum(2.^(usedHWchanels-1)));
            
            %create pulsegroup object
            if ~isKey(self.storedPulsegroups,grp.name)
                self.storedPulsegroups.add( PXDACPULSEGROUP(grp.name) );
            end
            
            dind = find([grp.pulses(1).data.clk] == self.clk);
            
            %reserve memory (at least i hope so)
            self.storedPulsegroups(grp.name).waveformArray = repmat( PXDACPULSE.empty(0,0), 1,length(grp.pulses) );
            
            for i = 1:length(grp.pulses)
                
                
                pulse = PXDACPULSE(channelMask,size(grp.pulses(i).data.wf,2));
                
                for virtChan = 1:size(grp.pulses(i).data(dind).wf, 1)
                    
                    for hardChan = self.getHardwareChannel(grp.chan(virtChan));
                        
                        if self.outputRange(hardChan) == 0
                            error('Output range of channel %i has not been set.',hardChan);
                        end

                        maximum = (self.outputRange(hardChan) - self.offset(hardChan)) / self.scale(hardChan);
                        minimum = (-self.outputRange(hardChan) - self.offset(hardChan)) / self.scale(hardChan);
                        
                        if any( grp.pulses(i).data(dind).wf(virtChan, :) > maximum ) || any( grp.pulses(i).data(dind).wf(virtChan, :) < minimum )
                            error('Some values in pulse %i in virtual channel %i are to large for the output range.',i,virtChan);
                        end
                        
                        uint16wf =  uint16(...
                            ((grp.pulses(i).data(dind).wf(virtChan, :) * self.scale(hardChan) + self.offset(hardChan))...convert to volts
                            /self.outputRange(hardChan) + 1) ... map to interval [0,2]
                            *(2^(16-1) - 1)); %map to interval [0,2^16-1]
                        

                        pulse.writeToChannel(hardChan,uint16wf);
                    
                    end
                    
                    
                end
                
                self.storedPulsegroups(grp.name).waveformArray(i) = pulse;
                
            end
            
            
            
        end