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

                        %map to interval [0,2]
                        data =  ((self.offset(min(hardChan,end)) + grp.pulses(i).data(dind).wf(virtChan, :))./self.scale(hardChan) + 1);

                        %convert to uint16 0-2^14-1
                        int16wf = uint16(min(...
                            data*(2^(16-1) - 1),...
                            2^(16)-1));

                        pulse.writeToChannel(hardChan,int16wf);
                    
                    end
                    
                    
                end
                
                self.storedPulsegroups(grp.name).waveformArray(i) = pulse;
                
            end
            
            
            
        end