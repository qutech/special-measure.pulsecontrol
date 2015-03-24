%
%   This class represents one waveform of which
%    the output during one scanline is composed
%
classdef PXDACPULSE < handle
    properties (GetAccess = public, SetAccess = private)
        channelMask;
        channelCount;
        
        %number of samples in one channel
        samplesPerChannel;
        
        %byte
        byteSize;
        
        rawData;
        
        lastEdit;
    end
    
    methods
        function obj = PXDACPULSE(channelMask,samplesPerChannel)
            if ~isa(channelMask,'uint16')
                error('ChannelMask must be of type uint16');
            end
            
            if sum(bitget(channelMask,5:16)) ~= 0
                maskString = sprintf('%i',bitget(channelMask,1:16));
                error('Only 4 channels available. Recieved channel mask %s',maskString);
            end
            
            
            obj.channelCount = sum(bitget(channelMask,1:16));
            obj.channelMask = channelMask;
            
            if obj.channelCount == 3
                error('Playing on 3 channels not possible');
            elseif sum(bitget(channelMask,1:2)) == 1 && sum(bitget(channelMask,3:4)) == 1
                error('May not play channel (1 XOR 2) AND (3 XOR 4).');
            end
            
            obj.samplesPerChannel = samplesPerChannel;
            bytesPerSample = 2; %sizeof(uint16)
            obj.byteSize = obj.channelCount*obj.samplesPerChannel*bytesPerSample;
            
            %hardcoded resolution
            obj.rawData = libpointer('uint16Ptr',zeros(1,obj.samplesPerChannel*obj.channelCount,'uint16'));
            

            obj.lastEdit = now;

        end
        
        function writeToChannel(self,channel,data)
            if length(data)~=self.samplesPerChannel
                error('Dimensions do not fit. Expected %i points but got %i.',self.samplesPerChannel,length(data));
            end
            
            if bitand(channel,self.channelMask) == 0
                error('The channel %i is not included in channel mask %i%i%i%i',channel,bitget(self.channelMask,5-(1:4)));
            end
            
            channelsBefore = sum(bitget(self.channelMask,1:channel)-1);
            
            self.rawData.Value(...
                channelsBefore+... %offset
                1:self.channelCount:self.samplesPerChannel*self.channelCount)... % every channelCount datapoint
                = data;
            self.lastEdit=now;
        end
    end
end