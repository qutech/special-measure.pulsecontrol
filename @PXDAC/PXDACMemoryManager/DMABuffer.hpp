#ifndef PXDAC_DMA_BUF
#define PXDAC_DMA_BUF

#include <string>
#include <stdexcept>

#include "C:\Program Files\Signatec\PXDAC4800\Include\pxdac4800.h"

#include "internal_header.h"
#include "logger.h"

/*	This exception is thrown if any board function returns non-zero status.
*	It should(must) be catched by the calling interface function.*/
class PXDAC_exception
{
	
public:
	PXDAC_exception(int stat) :status(stat)
	{
		wchar_t* buffer = nullptr;

		GetErrorTextXD48(status, &buffer, 0);

		std::basic_string<wchar_t> txt(buffer);

		logger::log("Error ",status,": ",buffer,"\n");

		FreeMemoryXD48(buffer);
	}
	int status;
};

/**
*	All interaction with the card is contained in this class. It throws PXDAC exceptions if anything did not work.
*/
template< typename SampleType >
class DMABuffer
{
private:
	HXD48 mHandle;
	SampleType* mData;
	bool mOutdated;
public:
	const size_type mBoardPosition;
	const size_type mNumElements;
	static int mErrorFlag;

	DMABuffer(HXD48 handle, size_type byte_position, size_type elem) :
		mHandle(handle),
		mData(nullptr),
		mBoardPosition(byte_position),
		mNumElements(elem),
		mOutdated(false)
	{
		if (mBoardPosition % (1 << 13))
			throw std::runtime_error("Illegal DMA buffer position: " + std::to_string(mBoardPosition));

		int status = AllocateDmaBufferXD48(mHandle, mNumElements * sizeof(SampleType), (void**)&mData);
		if (status)
			throw PXDAC_exception(status);
	}
	int release()
	{
		if (mData)
		{
			int status = FreeDmaBufferXD48(mHandle, mData);
			mData = nullptr;
			return status;
		}
		return 0;
	}
	~DMABuffer()
	{
		release();
	}
	DMABuffer(DMABuffer&& other) : mHandle(other.mHandle), mData(other.mData), mNumElements(other.mNumElements), mBoardPosition(other.mBoardPosition)
	{
		other.mData = nullptr;
	}
	DMABuffer(const DMABuffer& other) = delete;

	void copy(size_type position, SampleType* input, size_type length)
	{
		if ( position + length > mNumElements )
			throw std::runtime_error("DMABuffer: Access violation: " + std::to_string(position + length) + " > " + std::to_string(mNumElements));
			
		else
			std::copy_n(input, length, mData + position);
		mOutdated = true;
	}

	void update(bool asynchrone)
	{
		if (!mData)
			throw std::runtime_error("No DMA pointer present");

		if (mOutdated)
		{

			int async = asynchrone ? 1 : 0;
			int status = LoadRamBufXD48(mHandle, mBoardPosition, mNumElements*sizeof(SampleType), (void*)mData, async);

			if (status)
				throw PXDAC_exception(status);

			mOutdated = false;
		}
	}
};

#endif