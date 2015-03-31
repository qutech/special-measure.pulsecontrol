#ifndef PXDAC_MEM_MAN
#define PXDAC_MEM_MAN

#include <string>
#include <stdexcept>

#include "DMABuffer.hpp"

#ifdef min
#define __PXDAC_tempmin min
#undef min
#endif

#ifdef max
#define __PXDAC_tempmax max
#undef max
#endif


template< typename SampleType >
class MemoryManager
{
private:
	HXD48 mHandle;

	std::vector< DMABuffer<SampleType> > mData;

public:
	static const size_type sMaximalMemory = 1 << 30;

	const size_type mChunkByteSize;
	const size_type mSamplesPerChunk;
	const size_type mMaxSamples;
	const size_type mTotalByteSize;

	static int mErrorFlag;

	MemoryManager(HXD48 handle, size_type elements_to_manage, size_type chunk_size) :
		mHandle(handle), mData(),
		mChunkByteSize(chunk_size*sizeof(SampleType)),
		mSamplesPerChunk(chunk_size),
		mMaxSamples(elements_to_manage + ((elements_to_manage%mSamplesPerChunk > 0) ? (mSamplesPerChunk - elements_to_manage%mSamplesPerChunk) : (0))), //rount up to amultiple of samplesperchunk
		mTotalByteSize(mMaxSamples*sizeof(SampleType))
	{
		if (mTotalByteSize > sMaximalMemory)
		{
			throw std::runtime_error("To much memory requested");
		}

		if (mMaxSamples == 0)
			return;
		if (mChunkByteSize % (1 << 13))
		{
			throw std::runtime_error(std::string("The chunk size is not a multiple of ") + std::to_string((1 << 13)));
		}

		size_type nChunks = mMaxSamples / mSamplesPerChunk;

		if( SIG_SUCCESS != SetDacSampleFormatXD48(handle, XD48SAMPFMT_UNSIGNED) )
			throw std::runtime_error("Could not set unsigned format.");

		mData.reserve(nChunks);
		for (size_type i = 0; i < nChunks; i++)
			mData.emplace_back(mHandle, i*mChunkByteSize, mSamplesPerChunk);
	}

	HXD48 getHandle() { return mHandle;  }

	void synchronize(bool asynchrone)
	{
		for (DMABuffer<SampleType>& buffer : mData)
			buffer.update(asynchrone);
	}

	void write(size_type position, size_type length, SampleType* data)
	{
		if (length == 0)
			return;
		if (position + length > mMaxSamples)
			throw std::runtime_error("Request to write from " + std::to_string(position) + " to " + std::to_string(position + length) + " is out of memory(" + std::to_string(mMaxSamples) + " samples maximum).");

		size_type firstOffset = position%mSamplesPerChunk;
		size_type firstChunk = position / mSamplesPerChunk;
		size_type firstCopy = std::min(length, mSamplesPerChunk - firstOffset);

		mData[firstChunk].copy(firstOffset, data, firstCopy);
		data += firstCopy;



		//total number of chunks that are completely filled
		size_type completeChunks = (length - firstCopy) / mSamplesPerChunk;

		// this chunk is either filled parially or not at all
		size_type partialChunk = firstChunk + 1 + completeChunks;

		for (size_type c = firstChunk + 1; c < partialChunk; c++)
		{
			mData[c].copy(0, data, mSamplesPerChunk);

			data += mSamplesPerChunk;
		}


		size_type lastCopy = length - firstCopy - mSamplesPerChunk*completeChunks;
		if (lastCopy)
			mData[partialChunk].copy(0, data, lastCopy);

	}

	MemoryManager(const MemoryManager&) = delete;
	MemoryManager(MemoryManager&&) = delete;

	// breaks resource release if an error occurs.
	int release()
	{
		for (DMABuffer<SampleType>& buffer : mData)
		{
			int status = buffer.release();
			if (status)
				return status;
		}
		return 0;
	}
	~MemoryManager()
	{
		for (DMABuffer<SampleType>& buffer : mData)
			buffer.release();
	}
};

#ifdef __PXDAC_tempmin
#define min __PXDAC_tempmin
#undef __PXDAC_tempmin
#endif

#ifdef __PXDAC_tempmax
#define max __PXDAC_tempmax
#undef __PXDAC_tempmax
#endif


#endif