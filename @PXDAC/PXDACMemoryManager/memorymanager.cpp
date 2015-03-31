#include <vector>
#include <memory>
#include <algorithm>

#include <iostream>
#include <fstream>
#include <string>

#include <cassert>



#include "internal_header.h"
#include "MemoryManager.hpp"

static std::unique_ptr< MemoryManager<U16> > manager;

EXPORT int initializeU16(HXD48 handle, unsigned int total_memory, unsigned int chunk_size)
{
	try
	{
		if (manager)
		{
			logger::log("Deleting old memory manager.");
			int status = free_memory();
			if (status)
				return status;
		}
		logger::log("Start allocation of " , total_memory , " bytes of memory in " , total_memory / chunk_size , " buffers of size " , chunk_size , ".");
		manager.reset( new MemoryManager<U16>(handle, total_memory, chunk_size) );
	}
	catch (PXDAC_exception& e)
	{
		return e.status;
	}
	return 0;
}

EXPORT void writeU16(unsigned int position, unsigned int length, U16* data)
{
	if (!manager)
		throw std::runtime_error("Error in writeU16: no memory manager initialized");

	manager->write(position, length, data);
}

EXPORT void writeRAW(unsigned int position, unsigned int length, void* data)
{
	if (!manager)
		throw std::runtime_error("Error in writeRAW: no memory manager initialized");

	//hack
	manager->write(position / sizeof(U16), length / sizeof(U16), (U16*)data);
}

EXPORT int synchronize(bool async)
{
	try
	{
		if (!manager)
			throw std::runtime_error("Error in synchronize: no memory manager initialized");


		manager->synchronize(async);
	}
	catch (PXDAC_exception& e)
	{
		return e.status;
	}
	return 0;
}

EXPORT int free_memory()
{
	if (manager)
	{
		//catch error during memory release
		int status = manager->release();

		//release memory anyway
		manager.reset(nullptr);

		return status;
	}
	return 0;
}

EXPORT void setLogFile(const char* path)
{
	logger::setStreamToFile(std::string(path));
}

EXPORT int getMode()
{
	if (manager)
	{
		return _GetOperatingModeXD48(manager->getHandle(), 0);
	}
	return -1;
}