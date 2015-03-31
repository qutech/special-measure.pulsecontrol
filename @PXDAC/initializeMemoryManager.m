function initializeMemoryManager(self,sizeInSamples)

[source_dir,~,~] = fileparts(mfilename('fullpath'));

header_location = fullfile(source_dir,'PXDACMemoryManager','PXDAC_memory_manager.h');

release = 'Debug';
%release = 'Release';
dll_location = fullfile(source_dir,'PXDACMemoryManager','x64',release,'PXDACMemoryManager.dll');

if ~libisloaded('PXDACMemoryManager')
    loadlibrary(dll_location,header_location);
else
    status = calllib('PXDACMemoryManager','free_memory');
    if status ~= 0
        fprintf('An error occured during memory release.\n%s',statusToErrorMessage(status));
    end
end

%initialize memory manager
chunkexponent = 22; %2^22 * sizeof(U16) ~ 8 MB
maxsamples = sizeInSamples;

%make chunk size smaller as long as allocation fails
%bigger chunks are much faster to upload but are not as easy to
%create for the operating system

while true
    
    chunksamples = 2^chunkexponent;
    status = calllib('PXDACMemoryManager','initializeU16',self.handle,uint32(maxsamples),uint32(chunksamples));
    
    if status == 0
        fprintf('Initialized memory manager with 2^%d samples per chunk.\n', chunkexponent);
        break;
    else
        %reduce chunk size
        chunkexponent = chunkexponent-1;
        if chunkexponent == 0
            error('Can not allocate enough DMA buffers for PXDAC.');
        end
    end
end


end