


/// A handle to a PXDAC4800 device; consider an opaque object

typedef unsigned long* HXD48;

#define _XD48_DEF

//extern "C" __declspec( dllexport ) typedef struct _dx48hs_mat { int mrdlctd; } MAT_HANDLE;

// __FUNCTIONS__        Begin exported function prototypes

// --- Device connection/management --- //

// Obtains number of PXDAC4800 devices in local system
int GetDeviceCountXD48();

// Get handle
extern "C" DllSpecXD48 HXD48 _XD48LIBCALLCONV GetHandleXD48 (HXD48* phDev);
// Obtain a handle to a local PXDAC4800 device
int ConnectToDeviceXD48 (HXD48* phDev, unsigned int brdNum);
// Closes a PXDAC4800 device handle
int DisconnectFromDeviceXD48 (HXD48 hBrd);

// Obtain a handle to a virtual (fake) PXDAC4800 device
int ConnectToVirtualDeviceXD48 (HXD48* phDev, unsigned int serialNum, unsigned int brdNum);

// Duplicate a PXDAC4800 device handle
int DuplicateHandleXD48 (HXD48 hBrd, HXD48* phNew);

// Determines if a given PXDAC4800 device handle is for a virtual device
int IsDeviceVirtualXD48 (HXD48 hBrd);
// Determines if the given PXDAC4800 device handle is connected to a device
int IsHandleValidXD48 (HXD48 hBrd);
// Determines if a given PXDAC4800 device handle is for a remote device
int IsDeviceRemoteXD48 (HXD48 hBrd);

// Get error message from error code and board handle
extern "C" DllSpecXD48 char* _XD48LIBCALLCONV GetErrorMessXD48 (int res, char* bufp, int flags, HXD48 hBrd);

// Obtain the serial number of the PXDAC4800 connected to the given handle
int GetSerialNumberXD48 (HXD48 hBrd, unsigned int* snp);
// Obtain the ordinal number of the PXDAC4800 connected to the given handle
int GetOrdinalNumberXD48 (HXD48 hBrd, unsigned int* onp);

///@defgroup __XD48BRDREV_					PXDAC4800 board revision identifiers (XD48BRDREV_*, XD48BRDREVSUB_*)
///@see GetBoardRevisionXD48
///@note This is the board revision, not to be confused with the hardware revision
///@{
#define XD48BRDREV_PXDAC4800                0			///< Original PXDAC4800
#define XD48BRDREV__COUNT					1
// -- PXDAC4800 board sub-revision identifiers
// -- Sub-revision identifiers relative to revision PXDAC4800 (XD48BRDREV_PXDAC4800)
#define XD48BRDREVSUB_0_PXDAC4800_DP		0			///< Standard PXDAC4800
#define XD48BRDREVSUB_0_PXDAC4800_SP95		1			///< PXDAC4800-SP95
#define XD48BRDREVSUB_0__COUNT				2
///@}

// Obtain board revision and/or sub-revision
int GetBoardRevisionXD48 (HXD48 hBrd, unsigned int* revp, unsigned int* sub_revp);

///@defgroup __XD48GBNF_					XD48GBNF_ : GetBoardNameXD48 flags
///@see _GetBoardNameWXD48
///@{
#define XD48GBNF_NO_SN                      0x00000001	///< Do not include board's serial (or ordinal) number
#define XD48GBNF_USE_ORD_NUM                0x00000002	///< Use ordinal number instead of serial number
#define XD48GBNF_INC_MSCFG                  0x00000004	///< Include master/slave status
#define XD48GBNF_INC_VIRT_STATUS            0x00000008	///< Include virtual status
#define XD48GBNF_INC_REMOTE_STATUS          0x00000010	///< Include remote status
#define XD48GBNF_ALPHANUMERIC_ONLY          0x00000020	///< Alphanumeric only
#define XD48GBNF_USE_UNDERSCORES            0x00000040	///< Use underscores '_' in place of spaces
#define XD48GBNF_INC_SUB_REVISION           0x00000080	///< Include sub-revision info (DP/SP##)
#define XD48GBNF_USE_DASHES                 0x00000100	///< Use dashes '-' in place of spaces
#define XD48GBNF_MSCFG_AT_END               0x00000200	///< Include master/slave status at end of text (like device part number)
#define XD48GBNF__DEFAULT					0
#define XD48GBNF__DETAILED                                   \
    (XD48GBNF_INC_MSCFG | XD48GBNF_INC_SUB_REVISION | XD48GBNF_INC_VIRT_STATUS | XD48GBNF_INC_REMOTE_STATUS)
#define XD48GBNF__PRODUCT_CLASS                              \
    (XD48GBNF_INC_MSCFG | XD48GBNF_MSCFG_AT_END | XD48GBNF_INC_SUB_REVISION | XD48GBNF_USE_DASHES | XD48GBNF_NO_SN)
///@}

// -- Character-type agnostic code should use GetBoardNameXD48 macro
// Obtain descriptive name for given board (char)
int _GetBoardNameAXD48 (HXD48 hBrd, char** bufpp, int flags _XD48_DEF(XD48GBNF__DEFAULT));
// Obtain descriptive name for given board (wchar_t)
int _GetBoardNameWXD48 (HXD48 hBrd, wchar_t** bufpp, int flags _XD48_DEF(XD48GBNF__DEFAULT));

// --- DMA buffer routines --- //

// DMA buffers are only required for fast, unbuffered data transfers.

// Allocate a DMA buffer and map into address space of calling process
int AllocateDmaBufferXD48 (HXD48 hBrd, unsigned int bytes, void** bufpp);
// Un-map and free a DMA buffer
int FreeDmaBufferXD48 (HXD48 hBrd, void* bufp);

// Utility DMA buffers are normal DMA buffers. The only distinction is that
//  the library automatically frees a utility DMA buffer when the handle
//  that allocated the buffer is closed by calling DisconnectFromDeviceXD48

// Ensures that the library managed utility DMA buffer is of the given size
int EnsureUtilityDmaBufferXD48 (HXD48 hBrd, int buf_idx, unsigned int byte_count);
// Frees the utility buffer associated with the given PXDAC4800 handle
int FreeUtilityDmaBufferXD48 (HXD48 hBrd, int buf_idx);
// Get the library managed utility DMA buffer
int GetUtilityDmaBufferXD48 (HXD48         hBrd,
	                             int           buf_idx,
								 void**        bufpp,
                                 unsigned int* buf_bytesp _XD48_DEF(NULL));

// --- Data transfer routines --- //

/// Load PXDAC4800 RAM with playback data for RAM playback using fast, unbuffered transfer
int LoadRamFastXD48 (HXD48        hBrd,
						 unsigned int offset_bytes,
						 unsigned int length_bytes,
						 const void*  dma_bufp,
						 int          bAsynchronous _XD48_DEF(0));

/// Load PXDAC4800 RAM with playback data for RAM playback using buffered transfers
int LoadRamBufXD48  (HXD48        hBrd,
	                     unsigned int offset_bytes,
						 unsigned int length_bytes,
						 const void*  bufp,
						 int          bAsynchronous _XD48_DEF(0));

// Waits for Nth instance of samples complete interrupt
int WaitForSamplesCompleteXD48 (HXD48         hBrd,
									unsigned int  interrupt_count _XD48_DEF(1),
									unsigned int  timeout_ms      _XD48_DEF(0),
									unsigned int* pIntCount       _XD48_DEF(NULL));

// Obtain the current Samples Complete interrupt counter
int GetSamplesCompleteInterruptCountXD48 (HXD48 hBrd, unsigned int* intr_counterp);

// Determine if a data transfer is currently in progress; for asynchronous transfers
int IsTransferInProgressXD48 (HXD48 hBrd);
// Wait (sleep) for an asynchronous data transfer to complete
int WaitForTransferCompleteXD48 (HXD48 hBrd, unsigned int timeout_ms _XD48_DEF(0));

#define XD48_DC		1
#define XD48_AC		0

int IsDcXD48(HXD48 hBrd);

//Channel filters - 50MHz low pass (Only supported on the DC version)
int SetFiltersCHXD48(HXD48 hBrd, int value);
int GetFiltersCHXD48(HXD48 hBrd);

//Default DAC value flag enable (Only supported on the DC version)
int SetCustomDacValueEnableXD48(HXD48 hBrd, int value);
int GetCustomDacValueEnableXD48(HXD48 hBrd);

//Default DAC custom value (Only supported on the DC version)
int SetCustomDacDefaultValueXD48(HXD48 hBrd, int channel, int value);
int GetCustomDacDefaultValueXD48(HXD48 hBrd, int channel);

int UpdateDefaultDacValueXD48(HXD48 hBrd);
void SetBasicDacValue(HXD48 hBrd);
void SetBasicDacValue(HXD48 hBrd, int channel);

///@defgroup LoadFileIntoRamFlags			XD48LFF_ : LoadFileIntoRamXD48 flags
///@see _LoadFileIntoRamWXD48
///@{
#define XD48LFF_NO_UNBUFFERED_FILE_IO		0x00000001	///< Do not try to use faster, unbuffered IO
#define XD48LFF_REALIGN_LENGTH_OK			0x00000002	///< It's okay to realign (down) upload length
#define XD48LFF__DEFAULT					0			///< Default flags value
///@}

// -- Character-type agnostic code should use LoadFileIntoRamXD48 macro
// Synchronously load a file into PXDAC4800 RAM (char)
int _LoadFileIntoRamAXD48 (HXD48              hBrd,
							   unsigned int       dst_offset_bytes,
							   unsigned int       dst_length_bytes,
							   const char*        srcp,
							   unsigned long long src_offset_bytes _XD48_DEF(0),
							   unsigned int       src_length_bytes _XD48_DEF(0),
							   int                flags            _XD48_DEF(XD48LFF__DEFAULT));
// Synchronously load a file into PXDAC4800 RAM (wchar_t)
int _LoadFileIntoRamWXD48 (HXD48              hBrd,
							   unsigned int       dst_offset_bytes,
							   unsigned int       dst_length_bytes,
							   const wchar_t*     srcp,
							   unsigned long long src_offset_bytes _XD48_DEF(0),
							   unsigned int       src_length_bytes _XD48_DEF(0),
							   int                flags            _XD48_DEF(XD48LFF__DEFAULT));

// --- Generic Playback routines --- //

// Determine if a playback is armed or in progress
int IsPlaybackInProgressXD48 (HXD48 hBrd);

// --- RAM Playback routines --- //

// Begin RAM playback from the given region in PXDAC4800 RAM
int BeginRamPlaybackXD48 (HXD48        hBrd,
							  unsigned int ram_offset_bytes,
							  unsigned int ram_length_bytes,
							  unsigned int playback_bytes _XD48_DEF(0));
// End RAM playback
int EndRamPlaybackXD48 (HXD48 hBrd);

///@defgroup __XD48WAVETYPE_				XD48WAVETYPE_ : Waveform types
///@see PlayPeriodicWaveformXD48
///@{
#define XD48WAVETYPE_SINE					0			///< Sine wave
#define XD48WAVETYPE_SQUARE					1			///< Square wave
#define XD48WAVETYPE_TRIANGLE				2			///< Triangle wave
#define XD48WAVETYPE_SAWTOOTH				3			///< Sawtooth wave
#define XD48WAVETYPE__COUNT					4
///@}

///@defgroup __XD48PPWF_					XD48PPWF_ : PlayPeriodicWaveformXD48 flags
///@see PlayPeriodicWaveformXD48
///@{
#define XD48PPWF_RATE_IS_PPC				0x00000001	///< Desired frequency is actually desired points-per-cycle
#define XD48PPWF_KEEP_HW_SETTINGS			0x00000002	///< Do not adjust any hardware settings
#define XD48PPWF_NO_PLAYBACK				0x00000004	///< Do not upload or begin playback; useful for testing desired rate
#define XD48PPWF_NO_SW_TRIGGER				0x00000008	///< Do not issue a software generated trigger for playback
#define XD48PPWF__DEFAULT					0
///@}

// Generate, upload, and begin continuous RAM playback of a periodic waveform
int PlayPeriodicWaveformXD48 (HXD48   hBrd,
	                              double  dWaveformMHz,                                     // Desired frequency of waveform (MHz)
                                  int     waveform_type    _XD48_DEF(XD48WAVETYPE_SINE),    // XD48WAVETYPE_*
                                  int     chan_idx         _XD48_DEF(0),                    // 0=Ch1,1=Ch2,2=Ch3,3=Ch4
                                  int     flags            _XD48_DEF(XD48PPWF__DEFAULT),    // XD48PPWF_*
                                  double* pdWaveformMHzOut _XD48_DEF(NULL));                // Actual freq of generated waveform

// -- Streaming playback routines -- //

/** @brief Lower-level streaming playback interface

	The functions in this group define a lower-level API that may be used
	to do a streaming playback operation. This interface gives the 
	programmer full control of all playback data that is uploaded during
	the streaming playback.

	This interface is not available for remote PXDAC4800 devices. Remote
	PXDAC4800 devices must use the Streaming Playback session interface
	for streaming playback operations.

	@defgroup StreamLowApi	Lower-level streaming playback interface
	@{
*/
// Begin a local streaming playback operation
int BeginStreamingPlaybackXD48 (HXD48 hBrd);
// Upload data for streaming playback using fast, unbuffered transfer from a DMA buffer
int LoadStreamDataFastXD48 (HXD48        hBrd,
								const void*  dma_bufp,
								unsigned int src_bytes,
								int          bAsynchronous _XD48_DEF(0));
// Upload data for streaming playback using buffered transfers from any buffer
int LoadStreamDataBufXD48  (HXD48        hBrd,
								const void*  bufp,
								unsigned int src_bytes,
								int          bAsynchronous _XD48_DEF(0));
// Notifies the PXDAC4800 that all streaming playback data has been uploaded
int NotifyAllStreamDataUploadedXD48 (HXD48 hBrd);
// End a local streaming playback operation
int EndStreamingPlaybackXD48 (HXD48 hBrd);
///@}

/** @brief Streaming Playback session interface

	The functions in this group define a higher-level API that may be used
	to do a library managed streaming playback operation. This interface
	allows the programmer to specify a playback data source (e.g. one or 
	more files) that the PXDAC4800 library will play back. With this API,
	the library handles all the details of the playback: file and buffer 
	management, active memory configuration, operating mode changes, etc.

	A Streaming Playback session runs in a background thread allowing the
	primary thread to continue working while the streaming playback is in
	progress. This allows for easier integration into other environments
	such as LabVIEW, Matlab, or .NET languages that cannot access arbitrary
	unmanaged memory.

	Functions exist for querying the status/progress of the playback as well
	as obtain snapshots of the data currently being loaded.

	This interface is usable with remote PXDAC4800 devices

	@defgroup StreamSessionApi Streaming Playback session interface
	@{
*/

/// A handle to a PXDAC4800 Streaming Playback session instance; consider an opaque object
/// XD48_INVALID_HANDLE represents an invalid handle value
typedef struct _dx48strm_ses_ { int oot; }* HXD48STREAM;

///@defgroup __XD48STREAMF_					XD48STREAMF_ : Streaming Playback session flags
///@see XD48S_STREAM_SES_CREATE::stream_flags
///@{
#define XD48STREAMF_FORCE_SW_TRIGGER		0x00000001	///< Force playback to begin without waiting for an external trigger
#define XD48STREAMF_DO_SNAPSHOTS			0x00000002	///< Periodically grab snapshots of playback data
#define XD48STREAMF_NO_UNBUFFERED_IO		0x00000004	///< Do not try to use unbuffered IO
#define XD48STREAMF_INIT_STATIC_DATA		0x80000000	///< Pre-initialize input buffers with static playback data
#define XD48STREAMF__DEFAULT				0
///@}

//Streaming sessions types
#define XD48_STRMSESS_ONESHOT			0		//Single loading and playback
#define XD48_STRMSESS_INFINITE			1		//Infinite loading and playback
#define XD48_STRMSESS_ONESHOT_SS		2		//Single loading and playback with snap shots
#define XD48_STRMSESS_INFINITE_SS		3		//Infinite loading and playback with snap shots

#define XD48STREAMLEN_INFINITE              0			///< Stream infinitely, looping around source data as necessary
#define XD48STREAMLEN_SOURCE_LENGTH			((unsigned long long)-1)	///< Defines stream size to be length of source data (minus source offset)

/// Streaming Playback session creation parameters; @see _SessionStreamCreateAXD48
typedef struct _XD48S_STREAM_SES_tag
{
	unsigned int		struct_size;					///< struct size in bytes

	int					stream_flags;					///< XD48STREAMF_*
	unsigned long long	stream_bytes;					///< Total bytes to stream or one of XD48STREAMLEN_*
	unsigned long long	src_offset_bytes;				///< Source data offset of playback data
	unsigned long long	src_length_bytes;				///< Source data length of playback data or 0 for all
	unsigned int		xfer_bytes;						///< Transfer size or 0 to let library decide
	int					reserved;						///< Reserved for future use; pass zero

	unsigned int		ss_len_bytes;					///< Playback snapshot size in bytes
	unsigned int		ss_period_xfer;					///< Snapshot period in 1MB DMA transfers
	unsigned int		ss_period_ms;					///<  or snapshot period in milliseconds
	int					reserved2;						///< Reserved for future use; pass zero

} XD48S_STREAM_SES_CREATE;

///@defgroup __XD48SPBSTATUS_				XD48SPBSTATUS_ : Streaming Playback Session Status
///@see XD48S_STREAM_SES_PROG::stream_status
///@{
#define XD48SPBSTATUS_IDLE					0			///< Idle; playback session not yet started
#define XD48SPBSTATUS_ACTIVE				1			///< Active; Playback session is in progress
#define XD48SPBSTATUS_COMPLETE				2			///< Complete; Playback session complete or stopped by user
#define XD48SPBSTATUS_ERROR					3			///< Error; Playback session has ended due to error
#define XD48SPBSTATUS__COUNT				4
///@}

///@defgroup __XD48SPBPROGF_				XD48SPBPROGF_ : Streaming Playback Session Progress Flags
///@see XD48S_STREAM_SES_PROG::progress_flags
///@{
#define XD48SPBPROGF_DAC_FIFOS_FILLED		0x00000001	///< DAC FIFOs have filled; safe to trigger
#define XD48SPBPROGF_SW_TRIG_ISSUED			0x00000002	///< A software trigger has been generated
///@}

/// Streaming Playback session progress; @see SessionStreamProgressXD48
typedef struct _XD48S_STREAM_SES_PROG_tag 
{
	unsigned int		struct_size;					///< struct size in bytes

	int					stream_status;					///< XD48SPBSTATUS_*

	unsigned long long	bytes_uploaded;					///< Total bytes uploaded so far
	unsigned long long	bytes_to_upload;				///< Total bytes to upload or 0 for infinite

	unsigned int		elapsed_time_ms;				///< Current elapsed uptime
	unsigned int		xfer_bytes;						///< Transfer size in bytes
	unsigned int		xfer_count;						///< Current transfer count
	unsigned int		snapshot_count;					///< Current snapshot count

	int					progress_flags;					///< XD48SPBPROGF_*

	// Valid when stream_status == XD48SPBSTATUS_ERROR
	int					err_res;						///< SIG_*
	wchar_t*			err_textp;						///< Caller frees with FreeMemoryXD48

	void*				reserved;						// Reserved for future use

} XD48S_STREAM_SES_PROG;

// -- Character-type agnostic code should use SessionStreamCreateXD48 macro
// Create a Streaming Playback session instance (char)
int _SessionStreamCreateAXD48 (HXD48                    hBrd, 
								   const char*              data_srcp,
								   XD48S_STREAM_SES_CREATE* ses_createp,
								   HXD48STREAM*             handlep);
// Create a Streaming Playback session instance (wchar_t)
int _SessionStreamCreateWXD48 (HXD48                    hBrd, 
								   const wchar_t*           data_srcp,
								   XD48S_STREAM_SES_CREATE* ses_createp,
								   HXD48STREAM*             handlep);

// Create a Streaming Playback session instance, using all parms(char)
int _SessionStreamCreateParmsAXD48 (HXD48                    hBrd, 
										const char*              data_srcp,
										int						 stream_flags,
										double					 stream_bytes,
										double					 stream_samples,
										double					 src_offset_bytes,
										double					 src_length_bytes,
										unsigned int			 xfer_bytes,
										unsigned int			 ss_len_bytes,
										unsigned int			 ss_period_xfer,
										unsigned int			 ss_period_ms,
										unsigned int*			 sessionp);
// Create a Streaming Playback session instance, using all parms(wchar_t)
int _SessionStreamCreateParmsWXD48 (HXD48                    hBrd, 
										const wchar_t*           data_srcp,
										int						 stream_flags,
										double					 stream_bytes,
										double					 stream_samples,
										double					 src_offset_bytes,
										double					 src_length_bytes,
										unsigned int			 xfer_bytes,
										unsigned int			 ss_len_bytes,
										unsigned int			 ss_period_xfer,
										unsigned int			 ss_period_ms,
										unsigned int*			 sessionp);

// -- Character-type agnostic code should use SessionStreamCreateStdXD48 macro
// Create a Streaming Playback session instance from standard parameters(char)
int _SessionStreamCreateStdAXD48 (HXD48                    hBrd, 
									  const char*              data_srcp,
									  int					   SampleSize,
								      int					   SessionType,
									  unsigned int			   SnapShotLen_Bytes,
									  unsigned int			   SnapShotPeriod_ms,
								      HXD48STREAM*			   handlep);

// Create a Streaming Playback session instance from standard parameters(wchar_t)
int _SessionStreamCreateStdWXD48 (HXD48                    hBrd, 
									  const wchar_t*           data_srcp,
									  int					   SampleSize,
								      int					   SessionType,
									  unsigned int			   SnapShotLen_Bytes,
									  unsigned int			   SnapShotPeriod_ms,
								      HXD48STREAM*			   handlep);

// End a Streaming Playback session
int SessionStreamEndXD48 (HXD48STREAM hSes, int bDelete _XD48_DEF(0));

int SessionStreamEndNoStructXD48 ( unsigned int *hSess, int bDelete _XD48_DEF(0));

///@defgroup __XD48SPBPROGF2_				XD48SPBPROGF_ : SessionStreamProgressXD48 flags
///@see SessionStreamProgressXD48
///@{
#define XD48SPBPROGF_NO_ERROR_TEXT			0x00000001	///< Do not generate error text on error
#define XD48SPBPROGF__DEFAULT				0
///@}

// Obtain Streaming Playback session progress
int SessionStreamProgressXD48 (HXD48STREAM            hSes, 
								   XD48S_STREAM_SES_PROG* progp,
								   int                    flags _XD48_DEF(XD48SPBPROGF__DEFAULT));

// Obtain Streaming Playback session progress, without the use of the progress structure
int SessionStreamGetProgressXD48 (unsigned int *hSes,
									  int *StreamStatus,
									  double *bytes_uploaded,
									  double *bytes_to_upload,
									  unsigned int *elapsed_time_ms,
									  unsigned int *xfer_bytes,
									  unsigned int *xfer_count,
									  unsigned int *snapshot_count,
									  int *progress_flags,
									  int *err_res,
									  char *err_textp,
									  int flags _XD48_DEF(XD48SPBPROGF__DEFAULT));

// Obtain Streaming Playback data snapshot
int SessionStreamSnapshotXD48 (HXD48STREAM   hSes,
								   void*         bufp, 
								   unsigned int  buf_bytes,
								   unsigned int* bytes_copiedp     _XD48_DEF(NULL),
								   int*          snapshot_counterp _XD48_DEF(NULL));

// Delete a Streaming Playback session instance
int SessionStreamDeleteXD48 (HXD48STREAM hSes);

int SessionStreamDeleteNoStructXD48 (unsigned int *hSess);

///@}


// --- Data interleaving/deinterleaving functions --- //

// -- 16-bit data

// De-interleave dual channel 16-bit data into separate buffers
int DeInterleaveData16bit2ChanXD48 (const unsigned short* srcp,
                                        unsigned int          samples_in,
                                        unsigned short*       dst_ch1p,
                                        unsigned short*       dst_ch2p);

// (Re)interleave dual channel 16-bit data into a single buffer
int InterleaveData16bit2ChanXD48 (const unsigned short* src_ch1p, 
                                      const unsigned short* src_ch2p, 
                                      unsigned int          samps_per_chan, 
                                      unsigned short*       dstp);

// De-interleave four channel 16-bit data into separate buffers
int DeInterleaveData16bit4ChanXD48 (const unsigned short* srcp, 
                                        unsigned int          samples_in,
                                        unsigned short*       dst_ch1p,
                                        unsigned short*       dst_ch2p,
                                        unsigned short*       dst_ch3p,
                                        unsigned short*       dst_ch4p);

// (Re)interleave four channel 16-bit data into a single buffer
int InterleaveData16bit4ChanXD48 (const unsigned short* src_ch1p,
                                      const unsigned short* src_ch2p, 
                                      const unsigned short* src_ch3p,
                                      const unsigned short* src_ch4p,
                                      unsigned int          samps_per_chan, 
                                      unsigned short*       dstp);

// -- 8-bit data

// De-interleave dual channel 8-bit data into separate buffers
int DeInterleaveData8bit2ChanXD48 (const unsigned char* srcp,
                                       unsigned int         samples_in,
                                       unsigned char*       dst_ch1p,
                                       unsigned char*       dst_ch2p);

// (Re)interleave dual channel 8-bit data into a single buffer
int InterleaveData8bit2ChanXD48 (const unsigned char* src_ch1p, 
                                     const unsigned char* src_ch2p, 
                                     unsigned int         samps_per_chan, 
                                     unsigned char*       dstp);

// De-interleave four channel 8-bit data into separate buffers
int DeInterleaveData8bit4ChanXD48 (const unsigned char* srcp, 
                                       unsigned int         samples_in,
                                       unsigned char*       dst_ch1p,
                                       unsigned char*       dst_ch2p,
                                       unsigned char*       dst_ch3p,
                                       unsigned char*       dst_ch4p);

// (Re)interleave four channel 8-bit data into a single buffer
int InterleaveData8bit4ChanXD48 (const unsigned char* src_ch1p,
                                     const unsigned char* src_ch2p, 
                                     const unsigned char* src_ch3p,
                                     const unsigned char* src_ch4p,
                                     unsigned int         samps_per_chan, 
                                     unsigned char*       dstp);

// --- Hardware settings functions --- //

/// Signature of most all Set...XD48 routines
typedef int (_XD48LIBCALLCONV* xd48lib_set_func_t)(HXD48, int);
/// Signature of most all Get...XD48 routines
typedef int (_XD48LIBCALLCONV* xd48lib_get_func_t)(HXD48, int);

/// Signature of a couple Set...XD48 routines that take double arguments
typedef int (_XD48LIBCALLCONV* xd48lib_setd_func_t)(HXD48, double);
/// Signature of a couple Get...XD48 routines that obtain double values
typedef int (_XD48LIBCALLCONV* xd48lib_getd_func_t)(HXD48, double*, int);

/// Signature of a couple Set...XD48 routines that take 2 int arguments
typedef int (_XD48LIBCALLCONV* xd48lib_set2i_func_t)(HXD48, int, int);

// Determine if the PXDAC4800 is idle; in Standby or Off mode
int InIdleModeXD48 (HXD48 hBrd);
// Determine if the PXDAC4800 is in a playback mode
int InPlaybackModeXD48 (HXD48 hBrd);

// Get state of DAC output FIFO almost full flag from PXDAC4800 hardware
int GetDacOutputFifoFullFlagXD48 (HXD48 hBrd);

//Inform the card that you do a test(Errors management)
int SetProdTestStatus(HXD48 hBrd, int flag);
int GetProdTestError(HXD48 hBrd);

///@defgroup __XD48MODE_					XD48MODE_ : Operating modes
///@see _SetOperatingModeXD48
///@{
#define XD48MODE_OFF                        0			///< Power down mode
#define XD48MODE_STANDBY                    1			///< Standby (ready) mode
#define XD48MODE_PLAY_RAM                   2			///< RAM playback mode
#define XD48MODE_PLAY_PCIE_BUF              3			///< RAM-buffered PCIe playback mode; data buffered through PXDAC4800 RAM
#define XD48MODE_LOAD_RAM					4			///< Load RAM mode; load data for RAM playback
#define XD48MODE_WRITE_RAM1					8			///< Write SDRAM1 unformatted; reserved for internal use
#define XD48MODE_WRITE_RAM2					9			///< Write SDRAM2 unformatted; reserved for internal use
#define XD48MODE_READ_RAM1					10			///< Read SDRAM1; reserved for internal use
#define XD48MODE_READ_RAM2					11			///< Read SDRAM2; reserved for internal use
///@}

// Set the PXDAC4800 operating mode (XD48MODE_*); most users will NOT need to call this
int _SetOperatingModeXD48 (HXD48 hBrd, int val);
// Get the PXDAC4800 operating mode (XD48MODE_*)
int _GetOperatingModeXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// - Output channels 

///@defgroup _-XD48CHANMASK_				XD48CHANMASK_ : Supported Active Channel Masks
///@see SetActiveChannelMaskXD48
///@{
#define XD48CHANMASK_4_CHANNEL				0xF			///< Four channel playback; channels 1, 2, 3, and 4
#define XD48CHANMASK_2_CHANNEL_1_2			0x3			///< Two channel playback; channels 1 and 2
#define XD48CHANMASK_2_CHANNEL_3_4			0xC			///< Two channel playback; channels 3 and 4
#define XD48CHANMASK_2_CHANNEL_1_3			0x5			///< Two channel playback; channels 1 and 3
#define XD48CHANMASK_1_CHANNEL_1			0x1			///< Single channel playback; channel 1
#define XD48CHANMASK_1_CHANNEL_2			0x2			///< Single channel playback; channel 1
#define XD48CHANMASK_1_CHANNEL_3			0x4			///< Single channel playback; channel 1
#define XD48CHANMASK_1_CHANNEL_4			0x8			///< Single channel playback; channel 1
//     Bit 0 (1) = Channel 1 (I1) selected
//     Bit 1 (2) = Channel 2 (Q1) selected
//     Bit 2 (4) = Channel 3 (I2) selected
//     Bit 3 (8) = Channel 4 (Q2) selected
#define XD48CHANMASK__MASK					0xF
///@}

/// Macro for specifying a channel mask; if chX is non-zero it will be set in mask
#define XD48_MAKE_CHAN_MASK(ch1,ch2,ch3,ch4)		\
	(((ch1)?XD48CHANMASK_1_CHANNEL_1:0) |			\
	 ((ch2)?XD48CHANMASK_1_CHANNEL_2:0) |			\
	 ((ch3)?XD48CHANMASK_1_CHANNEL_3:0) |			\
	 ((ch4)?XD48CHANMASK_1_CHANNEL_4:0))

// -- Filters mask - Low pass 50 MHz
#define XD48CHAN_FILTERMASK_NONE			0x0
#define XD48CHAN_FILTERMASK_1				0x1			
#define XD48CHAN_FILTERMASK_2				0x2				
#define XD48CHAN_FILTERMASK_3				0x4			
#define XD48CHAN_FILTERMASK_4				0x8	
#define XD48CHAN_FILTERMASK_1_2				0x3			
#define XD48CHAN_FILTERMASK_1_3				0x5				
#define XD48CHAN_FILTERMASK_1_4				0x9			
#define XD48CHAN_FILTERMASK_2_3				0x6				
#define XD48CHAN_FILTERMASK_2_4				0xA			
#define XD48CHAN_FILTERMASK_3_4				0xC			
#define XD48CHAN_FILTERMASK_1_2_3			0x7			
#define XD48CHAN_FILTERMASK_1_2_4			0xB				
#define XD48CHAN_FILTERMASK_1_3_4			0xD		
#define XD48CHAN_FILTERMASK_2_3_4			0xE		
#define XD48CHAN_FILTERMASK_1_2_3_4			0xF

// -- Custom DAC default value enable
#define XD48DACDEFAULT_ENABLE_NONE			0x0
#define XD48DACDEFAULT_ENABLE_1				0x1			
#define XD48DACDEFAULT_ENABLE_2				0x2				
#define XD48DACDEFAULT_ENABLE_3				0x4			
#define XD48DACDEFAULT_ENABLE_4				0x8	
#define XD48DACDEFAULT_ENABLE_1_2			0x3			
#define XD48DACDEFAULT_ENABLE_1_3			0x5				
#define XD48DACDEFAULT_ENABLE_1_4			0x9			
#define XD48DACDEFAULT_ENABLE_2_3			0x6				
#define XD48DACDEFAULT_ENABLE_2_4			0xA			
#define XD48DACDEFAULT_ENABLE_3_4			0xC			
#define XD48DACDEFAULT_ENABLE_1_2_3			0x7			
#define XD48DACDEFAULT_ENABLE_1_2_4			0xB				
#define XD48DACDEFAULT_ENABLE_1_3_4			0xD		
#define XD48DACDEFAULT_ENABLE_2_3_4			0xE		
#define XD48DACDEFAULT_ENABLE_1_2_3_4		0xF

// Set active channel mask; defines which channels are played back
int SetActiveChannelMaskXD48 (HXD48 hBrd, int chan_mask);
// Get active output channel mask; 1=Ch1, 2=Ch2, 4=Ch3, 8=Ch4
int GetActiveChannelMaskXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Sets the auto channel enable override; when enabled, user manages channel enables
int SetAutoChanEnableOverrideXD48 (HXD48 hBrd, int bOverride);
// Sets the auto channel enable disable; when enabled, user manages channel enables
int GetAutoChanEnableOverrideXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// By default, the library will automatically manage channel output enables
//  based on active channel selection. This can be overridden by calling
//  SetAutoChanEnableOverrideXD48(,1). The SetChannelEnableMaskXD48 can then
//  be used to explicitly control the output enables

// Set channel enable mask; controls actual output enable
int SetChannelEnableMaskXD48 (HXD48 hBrd, int chan_mask);
// Get channel enable mask; controls actual output enable
int GetChannelEnableMaskXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

//Set Tlp Size
int SetTlpSizeXD48(HXD48 hBrd, ULONG value);
//Get tlp Size
int GetTlpSizeXD48 (HXD48 hBrd, int bFromCache);

//reset oserdes
int ResetOserdesXD48 (HXD48 hBrd);

//Set Dac Enable
int SetDacEnableXD48 (HXD48 hBrd, int enable);

// Obtain the number of channels selected in given active channel mask
int GetChanCountFromMaskXD48 (int chan_mask);
// Determine if device supports given channel mask
int IsActiveChannelMaskSupportedXD48 (HXD48 hBrd, int chan_mask);

/// Returns nonzero if channel 1 is selected in given channel mask
#define XD48_IS_CH1_SELECTED(m)				((m) & 0x1)
/// Returns nonzero if channel 2 is selected in given channel mask
#define XD48_IS_CH2_SELECTED(m)				((m) & 0x2)
/// Returns nonzero if channel 3 is selected in given channel mask
#define XD48_IS_CH3_SELECTED(m)				((m) & 0x4)
/// Returns nonzero if channel 4 is selected in given channel mask
#define XD48_IS_CH4_SELECTED(m)				((m) & 0x8)

// - RAM selection -

// Get size of PXDAC4800 sample RAM in bytes
int GetSampleRamSizeXD48 (HXD48 hBrd, unsigned int* pbyte_count);

// Obtain maximum transfer/playback byte count for given active channel mask
int GetMaxByteCountForActiveChanMaskXD48 (HXD48 hBrd, int chan_mask, unsigned int* pmax_bytes);

///@defgroup __XD48ACTMEMF_					XD48ACTMEMF_ : _SetActiveMemoryRegionXD48 flags
///@see _SetActiveMemoryRegionXD48
///@{
#define XD48ACTMEMF_TEST_PARAMS_ONLY		0x00000001	///< Test parameters only; does not modify hardware
#define XD48ACTMEMF_BYTE_COUNT_ALIGN_DN		0x00000002	///< Okay to realign byte count down if necessary
#define XD48ACTMEMF_BYTE_COUNT_ALIGN_UP		0x00000004	///< Okay to realign byte count up if necessary
#define XD48ACTMEMF_IGNORE_BYTE_COUNT		0x00000008	///< Ignore byte_count
#define XD48ACTMEMF_IGNORE_BYTE_START		0x00000010	///< Ignore byte_start
#define XD48ACTMEMF_RESERVED				0x00070000	///< Reserved bits; do not use
#define XD48ACTMEMF__DEFAULT				0
///@}

// Note: All playback/transfer library functions will setup active memory region
// Set the active memory region; defines memory to use for RAM transfers/playbacks
int _SetActiveMemoryRegionXD48 (HXD48        hBrd,
								    unsigned int offset_bytes,
									unsigned int length_bytes,
								    int          flags         _XD48_DEF(XD48ACTMEMF__DEFAULT));
// Get the active memory region; defines memory to use for RAM transfers/playbacks
int _GetActiveMemoryRegionXD48 (HXD48         hBrd,
								    unsigned int* poffset_bytes,
									unsigned int* plength_bytes,
								    int           bFromCache     _XD48_DEF(1));

// Note: All playback library functions will setup playback length

int _SetPlaybackLengthXD48 (HXD48 hBrd, unsigned int length_bytes);
int _GetPlaybackLengthXD48 (HXD48 hBrd, unsigned int* plength_bytes, int bFromCache _XD48_DEF(1));

int _SetStreamingLengthXD48 (HXD48 hBrd, UINT64 length_bytes);

int GetFPGAStatusXD48 (HXD48 hBrd, unsigned int *val);

#define XD48DAC_PLL_LOCKED_STATUS			0x00000010
#define XD48UNDERFLOW_STATUS				0x00000020
#define XD48PROD_TEST_ERROR_STATUS			0x00000040
#define XD48PLAYBACK_IN_PROGRESS_STATUS		0x00000080

// - Playback clock -

///@defgroup ClockSource					XD48CLKSRC_ : Playback clock sources
///@see SetPlaybackClockSourceXD48
///@{
#define XD48CLKSRC_INT_1200_MHZ				0			///< 1200 MHz internal clock (power up default)
#define XD48CLKSRC_INT_900_MHZ				1			///< 900 MHz internal clock
#define XD48CLKSRC_EXTERNAL					2			///< Externally provided playback clock
#define XD48CLKSRC_SLAVE_1					3			///< Slave #1 clock; should be selected for Slave #1
#define XD48CLKSRC_SLAVE_2					4			///< Slave #2 clock; should be selected for Slave #2
#define XD48CLKSRC_SLAVE_3					5			///< Slave #3 clock; should be selected for Slave #3
#define XD48CLKSRC__COUNT					6			// Invalid setting
///@}

// Set the PXDAC4800 playback clock source (XD48CLKSRC_*)
int SetPlaybackClockSourceXD48 (HXD48 hBrd, int val);
// Get the PXDAC4800 playback clock source (XD48CLKSRC_*)
int GetPlaybackClockSourceXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Set the external 10MHz reference clock enable; overrides internal 10MHz reference
int SetExternalReferenceClockEnableXD48 (HXD48 hBrd, int bEnable);
// Get the external 10MHz reference clock enable; overrides internal 10MHz reference
int GetExternalReferenceClockEnableXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

#define XD48_EXT_PB_CLK_MIN_FREQ_MHZ		1			///< Minimum external playback clock frequency in MHz	// MDTODO
#define XD48_EXT_PB_CLK_MAX_FREQ_MHZ		1200		///< Maximum external playback clock frequency in MHz

// Specifies the external playback clock rate in MHz
int SetExternalPlaybackClockRateXD48 (HXD48 hBrd, double dRateMHz);
// Obtains the assumed external playback clock rate in MHz
int GetExternalPlaybackClockRateXD48 (HXD48 hBrd, double* pRateMHz, int bFromCache _XD48_DEF(1));

#define XD48_CLOCKDIV1_MAX					32			///< Playback clock divider #1 maximum; SetClockDivider1XD48
#define XD48_CLOCKDIV2_MAX					6			///< Playback clock divider #2 maximum; SetClockDivider2XD48

// Set the PXDAC4800 clock divider #1 [1,32]
int SetClockDivider1XD48 (HXD48 hBrd, int val);
// Get the PXDAC4800 clock divider #1
int GetClockDivider1XD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Set the PXDAC4800 clock divider #2 [1,6]
int SetClockDivider2XD48 (HXD48 hBrd, int val);
// Get the PXDAC4800 clock divider #2
int GetClockDivider2XD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Obtain current playback clock rate considering clock source and dividers
int GetPlaybackClockRateXD48 (HXD48 hBrd, double* pRateMHz);
// Obtain current playback data rate considering clock source, dividers, and interpolation
int GetPlaybackDataRateXD48 (HXD48 hBrd, double* pRateMHz);

// Synchronize the PXDAC4800 firmware to the playback clock; library manages this by default
int ResetDcmXD48 (HXD48 hBrd, int bDeferOk);
// Resynchronize playback clock outputs; library manages this by default
int ResyncPlaybackClockOutputsXD48 (HXD48 hBrd);

// Obtain the actual clock rate (in MHz) for given clock source setting
int GetBaseClockFreqXD48 (HXD48 hBrd, int clk_src, double* pRateMHz);

// - Playback trigger -

///@defgroup __XD48TRIGMODE_				XD48TRIGMODE_ : Trigger Modes
///@see SetTriggerModeXD48
///@{
#define XD48TRIGMODE_PLAY_PER_TRIGGER		0			///< Per-trigger - Single start trigger runs memory data once
#define XD48TRIGMODE_CONTINUOUS				1			///< Continuous  - Single start trigger runs memory data repeatedly (power up default)
#define XD48TRIGMODE_SINGLE_SHOT			2			///< Single shot - Trigger runs memory data once; subsequent triggers ignored
#define XD48TRIGMODE__COUNT					3
///@}

// Set the playback trigger mode (XD48TRIGMODE_*); defines how trigger events affect playback
int SetTriggerModeXD48 (HXD48 hBrd, int val);
// Get the playback trigger mode (XD48TRIGMODE_*); defines how trigger events affect playback
int GetTriggerModeXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Sets the external trigger enable; allows externally provided triggers to trigger playback
int SetExternalTriggerEnableXD48 (HXD48 hBrd, int bEnable);
// Gets the external trigger enable; allows externally provided triggers to trigger playback
int GetExternalTriggerEnableXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

///@defgroup __XD48TRIGDIR_					XD48TRIGDIR_ : External trigger direction
///@see SetExternalTriggerDirXD48
///@{
#define XD48TRIGDIR_POS						0			///< Positive-going (rising) edge (power-up default)
#define XD48TRIGDIR_NEG						1			///< Negative-going (falling) edge
#define XD48TRIGDIR__COUNT					2
///@}

// Set the external trigger pulse edge to use for a trigger event
int SetExternalTriggerDirXD48 (HXD48 hBrd, int val);
// Get the external trigger pulse edge to use for a trigger event
int GetExternalTriggerDirXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Issue a software-generated trigger event
int IssueSoftwareTriggerXD48 (HXD48 hBrd);

// - Digital IO -

// -- Digital Output Cfg
#define XD48DIGIOCFG_OUT				0			///< Digital output (power up default)
#define XD48DIGIOCFG_IN					1			///< Digital input

#define XD48DIGIOCFG__COUNT				2

// Set the digital IO configuration (output or input)
int SetDigitalIoCfgXD48 (HXD48 hBrd, int bOutput);
// Get the digital IO configuration; output=0 or input=1
int GetDigitalIoCfgXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

///@defgroup __XD48DIGIOMODE_				XD48DIGIOMODE_ : Digital IO Modes
///@see SetDigitalIoModeXD48
///@{
// -- Digital Output modes; valid when digital IO configured for output (XD48DIGIOMODE_OUT_*)
#define XD48DIGIOMODE_OUT_CLOCK_DIV_8				0			///< Digital output: DATA_CLK / 8 : max of 150MHz (power up default)
#define XD48DIGIOMODE_OUT_PULSE_BEGIN_PLAYBACK		1			///< Digital output: Pulse at the beginning of a playback. Not synchronous with the data
#define XD48DIGIOMODE_OUT_PULSE_END_PLAYBACK		2			///< Digital output: Pulse at the end of a playback. Not synchronous with the data
#define XD48DIGIOMODE_OUT_DAC_PLAYING_DATA			3			///< Digital output: DAC are playing data. Not synchronous with the data
#define XD48DIGIOMODE_OUT_DAC_PULSE_UNDERFLOW		4			///< Digital output: Pulse at Underflow error
#define XD48DIGIOMODE_OUT__COUNT					5
// -- Digital input modes; valid when digital IO configured for input (XD48DIGIOMODE_IN_*)
#define XD48DIGIOMODE_IN__COUNT						0			// - No input modes defined yet -
///@}

// Set digital IO mode; interpretation depends on digital IO configuration
int SetDigitalIoModeXD48 (HXD48 hBrd, int val);
// Set digital IO mode; interpretation depends on digital IO configuration
int GetDigitalIoModeXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// - Master/slave settings -

///@defgroup __XD48MSCFG_					XD48MSCFG_ : Master/Slave Configurations
///@see SetMasterSlaveConfigXD48
///@{
#define XD48MSCFG_STANDALONE				0			///< Standalone PXDAC4800 device (power-up default)
#define XD48MSCFG_MASTER_WITH_1_SLAVE		1			///< Master with 1 slave; will provide clock and trigger for slave #1
#define XD48MSCFG_MASTER_WITH_2_SLAVES		2			///< Master with 2 slaves; will provide clock and trigger for slaves #1 and #2
#define XD48MSCFG_MASTER_WITH_3_SLAVES		3			///< Master with 3 slaves; will provide clock and trigger for slaves #1, #2, and #3
#define XD48MSCFG_SLAVE_1					4			///< Slave #1; clock and trigger will be synchronized with master
#define XD48MSCFG_SLAVE_2					5			///< Slave #2; clock and trigger will be synchronized with master
#define XD48MSCFG_SLAVE_3					6			///< Slave #3; clock and trigger will be synchronized with master
#define XD48MSCFG__COUNT					7
///@}

// Set the master/slave configuration (XD48MSCFG_*); masters provide clock/trigger for slaves
int SetMasterSlaveConfigXD48 (HXD48 hBrd, int val);
// Get the master/slave configuration (XD48MSCFG_*); masters provide clock/trigger for slaves
int GetMasterSlaveConfigXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Add a slave board to a master
int AddSlaveToMasterXD48 (HXD48 hBrdSlave, HXD48 hBrdMaster);
// Remove a slave board from a master
int RemoveSlaveFromMasterXD48 (HXD48 hBrdSlave, HXD48 hBrdMaster);

/// Non-zero if given cfg (XD48MSCFG_*) represents a master device
#define IsMasterCfgXD48(cfg)				(((cfg)>=XD48MSCFG_MASTER_WITH_1_SLAVE) && ((cfg)<=XD48MSCFG_MASTER_WITH_3_SLAVES))
/// Non-zero if given cfg (XD48MSCFG_*) represents a slave device
#define IsSlaveCfgXD48(cfg)					(((cfg)>=XD48MSCFG_SLAVE_1) && ((cfg)<=XD48MSCFG_SLAVE_3))

// - DAC settings -

///@defgroup __XD48SAMPSIZE_				XD48SAMPSIZE_ : DAC Sample Sizes
///@see SetDacSampleSizeXD48
///@{
#define XD48SAMPSIZE_8BIT					0			///< 8-bit (0xFF)
#define XD48SAMPSIZE_14BIT_MSBPAD			1			///< 16-bit, MSB padded (0x3FFF)
#define XD48SAMPSIZE_14BIT_LSBPAD			2			///< 16-bit, LSB padded (0xFFFC) (power-up default)
#define XD48SAMPSIZE__COUNT					3
///@}

// Set the sample size/padding (XD48SAMPSIZE_*)
int SetDacSampleSizeXD48 (HXD48 hBrd, int val);
// Get the sample size/padding (XD48SAMPSIZE_*)
int GetDacSampleSizeXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Obtain DAC sample size in bytes for given sample type setting (XD48SAMPSIZE_*)
int SampleSizeFromTypeXD48 (int val);

///@defgroup __XD48SAMPFMT_					XD48SAMPFMT_ : DAC Sample Formats
///@see SetDacSampleFormatXD48
///@{
#define XD48SAMPFMT_UNSIGNED				0			///< Data samples are interpreted as unsigned [0, 16383] (power up default)
#define XD48SAMPFMT_SIGNED					1			///< Data samples are interpreted as signed   [-8192, 8191]
#define XD48SAMPFMT__COUNT					2
///@}

// Set the sample format (XD48SAMPFMT_*); e.g. signed or unsigned data
int SetDacSampleFormatXD48 (HXD48 hBrd, int val);
// Get the sample format (XD48SAMPFMT_*); e.g. signed or unsigned data
int GetDacSampleFormatXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// -- DAC input sample min/mid/max values for all sample sizes/formats

///@defgroup __XD48_SAMP_M_					Min/Mid/Max DAC Sample Values
///@see SetDacSampleFormatXD48, SetDacSampleSizeXD48
///@{

// - 8-bit data (XD48SAMPSIZE_8BIT) --

#define XD48_SAMP_MIN_U_8BIT				0			///< Minimum DAC sample value (unsigned 8-bit)  = 0
#define XD48_SAMP_MID_U_8BIT				128			///< Midscale DAC sample value (unsigned 8-bit) = 128  (0x80)
#define XD48_SAMP_MAX_U_8BIT				255			///< Maximum DAC sample value (unsigned 8-bit)  = 255  (0xFF)
#define XD48_SAMP_MIN_S_8BIT				(-128)		///< Minimum DAC sample value (signed 8-bit)    = -128 (0x80)
#define XD48_SAMP_MID_S_8BIT				0			///< Midscale DAC sample value (signed 8-bit)   = 0
#define XD48_SAMP_MAX_S_8BIT				127			///< Maximum DAC sample value (signed 8-bit)    = 127  (0x7F)

// - 16-bit data (MSB padded) (XD48SAMPSIZE_14BIT_MSBPAD) --

#define XD48_SAMP_MIN_U_16BIT_MSBPAD		0			///< Minimum DAC sample value (unsigned 16-bit MSB-padded)  = 0
#define XD48_SAMP_MID_U_16BIT_MSBPAD		8192		///< Midscale DAC sample value (unsigned 16-bit MSB-padded) = 8192  (0x2000)
#define XD48_SAMP_MAX_U_16BIT_MSBPAD		16383		///< Maximum DAC sample value (unsigned 16-bit MSB-padded)  = 16383 (0x3FFF)
#define XD48_SAMP_MIN_S_16BIT_MSBPAD		(-8192)		///< Minimum DAC sample value (signed 16-bit MSB-padded)    = -8192 (0x2000)
#define XD48_SAMP_MID_S_16BIT_MSBPAD		0			///< Midscale DAC sample value (signed 16-bit MSB-padded)   = 0
#define XD48_SAMP_MAX_S_16BIT_MSBPAD		8191		///< Maximum DAC sample value (signed 16-bit MSB-padded)    = 8191  (0x1FFF)

// - 16-bit data (LSB padded) (XD48SAMPSIZE_14BIT_LSBPAD) --

#define XD48_SAMP_MIN_U_16BIT_LSBPAD		0			///< Minimum DAC sample value (unsigned 16-bit LSB-padded)  = 0
#define XD48_SAMP_MID_U_16BIT_LSBPAD		32768		///< Midscale DAC sample value (unsigned 16-bit LSB-padded) = 32768  (0x8000)
#define XD48_SAMP_MAX_U_16BIT_LSBPAD		65532		///< Maximum DAC sample value (unsigned 16-bit LSB-padded)  = 65532  (0xFFFC)
#define XD48_SAMP_MIN_S_16BIT_LSBPAD		(-32768)	///< Minimum DAC sample value (signed 16-bit LSB-padded)    = -32768 (0x8000)
#define XD48_SAMP_MID_S_16BIT_LSBPAD		0			///< Midscale DAC sample value (signed 16-bit LSB-padded)   = 0
#define XD48_SAMP_MAX_S_16BIT_LSBPAD		32764		///< Maximum DAC sample value (signed 16-bit LSB-padded)    = 32764  (0x7FFC)
///@}

// DAC interpolation (2x) enable 
int SetDacInterpolationEnableXD48 (HXD48 hBrd, int bEnable);
// DAC interpolation (2x) enable 
int GetDacInterpolationEnableXD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

#define XD48_OUTPUTVOLT_MAX					1023		///< Channel offset maximum value; SetOutputVoltageCh1XD48
#define XD48_VOLT_RNG_MIN					0.470		///< Minimum output voltage range in peak-to-peak voltage (300mV)
#define XD48_VOLT_RNG_MAX					1.450		///< Minimum output voltage range in peak-to-peak voltage (900mV)
#define XD48_VOLT_RNG_MIN_DC				0.400		///< Minimum output voltage range in peak-to-peak voltage (300mV)
#define XD48_VOLT_RNG_MAX_DC				1.470		///< Minimum output voltage range in peak-to-peak voltage (900mV)

// Channel 1 output voltage; [0, 1023]
int SetOutputVoltageCh1XD48 (HXD48 hBrd, int val);
// Channel 1 output voltage; [0, 1023]
int GetOutputVoltageCh1XD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Channel 2 output voltage; [0, 1023]
int SetOutputVoltageCh2XD48 (HXD48 hBrd, int val);
// Channel 2 output voltage; [0, 1023]
int GetOutputVoltageCh2XD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Channel 3 output voltage; [0, 1023]
int SetOutputVoltageCh3XD48 (HXD48 hBrd, int val);
// Channel 3 output voltage; [0, 1023]
int GetOutputVoltageCh3XD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Channel 4 output voltage; [0, 1023]
int SetOutputVoltageCh4XD48 (HXD48 hBrd, int val);
// Channel 4 output voltage; [0, 1023]
int GetOutputVoltageCh4XD48 (HXD48 hBrd, int bFromCache _XD48_DEF(1));

// Obtain peak-to-peak voltage for given output voltage encoding [0, 1023]
int GetOutputVoltageRangeVoltsXD48 (int     val,
	                                    double* pPeakToPeakVolts,
										HXD48   hBrd               _XD48_DEF(XD48_INVALID_HANDLE));

// --- Device register access routines --- //

// Restores all PXDAC4800 settings to power up default values
int SetPowerupDefaultsXD48 (HXD48 hBrd);

//BIST
typedef int BistResult [4][16];
int StartDacAutoCalibrationXD48(HXD48 hBrd);
int getBistResult(int* item);

// Refresh local device register cache from driver's cache; no hardware read
int RefreshLocalRegisterCacheXD48 (HXD48 hBrd, int bFromHardware _XD48_DEF(0));

// Bring hardware settings up to date with current cache settings
int RewriteHardwareSettingsXD48 (HXD48 hBrd);

///@defgroup __XD48CHS_						XD48CHS_ : Copy hardware settings flags
///@see CopyHardwareSettingsXD48
///@{
#define XD48CHS_SIMPLE_COPY					0x80000000	///< Simple copy - Blindly copy all software-selectable hardware settings
///@}

// Copy hardware settings from another PXDAC4800 device
int CopyHardwareSettingsXD48 (HXD48 hBrdDst, HXD48 hBrdSrc, int flags _XD48_DEF(0));

// --- Hardware settings persistence --- //

///@defgroup __XD48XMLSET_					XD48XMLSET_ : Hardware settings save/load XML flags
///@see _SaveSettingsToStringXmlWXD48, _LoadSettingsFromStringXmlWXD48, _SaveSettingsToFileXmlWXD48, _LoadSettingsFromFileXmlWXD48
//@{
#define XD48XMLSET_NODE_ONLY                0x00000001	///< Serialize to a node only; do not include XML header info
#define XD48XMLSET_FORMAT_OUTPUT            0x00000002	///< Pretty-print XML output; add newlines and indentation for human eyes
#define XD48XMLSET_NO_PRELOAD_DEFAULTS      0x00000004	///< Do not set default hardware settings prior to loading settings
///@}

// -- Character-type agnostic code should use SaveSettingsToStringXmlXD48 macro
// Save board settings to a library allocated buffer (char)
int _SaveSettingsToStringXmlAXD48 (HXD48  hBrd,
	                                   int    flags,		// XD48XMLSET_*
									   char** bufpp);
// Save board settings to a library allocated buffer (wchar_t)
int _SaveSettingsToStringXmlWXD48 (HXD48     hBrd,
	                                   int       flags,		// XD48XMLSET_*
									   wchar_t** bufpp);

// -- Character-type agnostic code should use LoadSettingsFromStringXmlXD48 macro
// Load board settings from an XML buffer (char)
int _LoadSettingsFromStringXmlAXD48 (HXD48 hBrd, int flags, const char* bufp);
// Load board settings from an XML buffer (wchar_t)
int _LoadSettingsFromStringXmlWXD48 (HXD48 hBrd, int flags, const wchar_t* bufp);

// -- Character-type agnostic code should use SaveSettingsToFileXmlXD48 macro
// Save board settings to an XML file (char)
int _SaveSettingsToFileXmlAXD48 (HXD48       hBrd,
	                                 int         flags,
                                     const char* pathnamep,
                                     const char* encodingp _XD48_DEF("UTF-8"));
// Save board settings to an XML file (wchar_t)
int _SaveSettingsToFileXmlWXD48 (HXD48          hBrd,
	                                 int            flags,
                                     const wchar_t* pathnamep,
                                     const wchar_t* encodingp _XD48_DEF(L"UTF-8"));

// -- Character-type agnostic code should use LoadSettingsFromFileXmlXD48 macro
// Load board settings from an XML file (char)
int _LoadSettingsFromFileXmlAXD48 (HXD48       hBrd,
		                               int         flags,
                                       const char* pathnamep);
// Load board settings from an XML file (wchar_t)
int _LoadSettingsFromFileXmlWXD48 (HXD48          hBrd,
	                                   int            flags,
                                       const wchar_t* pathnamep);

// --- Signatec Recorded Data (*.srdc) file support --- //

#define _XD48_SRDC_DOT_EXTENSIONA           ".srdc"		///< Extension used for Signatec Recorded Data Context (.srdc) files (char*)
#define _XD48_SRDC_DOT_EXTENSIONW          L".srdc"		///< Extension used for Signatec Recorded Data Context (.srdc) files (wchar_t*)
#define _XD48_SRDC_EXTENSIONA               "srdc"		///< Extension used for Signatec Recorded Data Context (.srdc) files (char*)
#define _XD48_SRDC_EXTENSIONW              L"srdc"		///< Extension used for Signatec Recorded Data Context (.srdc) files (wchar_t*)

/// A handle to a SRDC file; consider an opaque object
typedef struct _xd48srdchs_ { int ruby; }* HXD48SRDC;

///@defgroup __XD48SRDCOF_					XD48SRDCOF_ : SRDC file open flags
///@see _OpenSrdcFileWXD48
///@{
#define XD48SRDCOF_OPEN_EXISTING            0x00000001	///< Open existing SRDC file; fail if file does not exist
#define XD48SDRCOF_CREATE_NEW               0x00000002	///< Create a new SDRC file; will ignore and overwrite existing data
#define XD48SRDCOF_PATHNAME_IS_REC_DATA     0x00000004	///< Given pathname is recorded data; have library search for SRDC
///@}

// -- Character-type agnostic code should use OpenSrdcFileXD48 macro
// Open a new or existing .srdc file (char)
int _OpenSrdcFileAXD48 (HXD48       hBrd,
	                        HXD48SRDC*  handlep,
                            const char* pathnamep,
                            unsigned    flags      _XD48_DEF(0));
// Open a new or existing .srdc file (wchar_t)
int _OpenSrdcFileWXD48 (HXD48          hBrd,
	                        HXD48SRDC*     handlep,
                            const wchar_t* pathnamep,
                            unsigned       flags      _XD48_DEF(0));

// -- Character-type agnostic code should use GetSrdcItemXD48 macro
// Look up SRDC item with given name; name is case-sensitive (char)
int _GetSrdcItemAXD48 (HXD48SRDC hFile, const char* namep, char** valuepp);
// Look up SRDC item with given name; name is case-sensitive (wchar_t)
int _GetSrdcItemWXD48 (HXD48SRDC hFile, const wchar_t* namep, wchar_t** valuepp);

// -- Character-type agnostic code should use SetSrdcItemXD48 macro
// Add/modify SRDC item with given name; not written to file (char)
int _SetSrdcItemAXD48 (HXD48SRDC hFile, const char* namep, const char* valuep);
// Add/modify SRDC item with given name; not written to file (wchar_t)
int _SetSrdcItemWXD48 (HXD48SRDC hFile, const wchar_t* namep, const wchar_t* valuep);

// -- Character-type agnostic code should use SaveSrdcFileXD48 macro
// Write SRDC data to file (char)
int _SaveSrdcFileAXD48 (HXD48SRDC hFile, const char* pathnamep);
// Write SRDC data to file (wchar_t)
int _SaveSrdcFileWXD48 (HXD48SRDC hFile, const wchar_t* pathnamep);

// Close given SRDC file without updating contents
int CloseSrdcFileXD48 (HXD48SRDC hFile);

//HW rev
int getHWRev (HXD48 hBrd);

/// Recorded data information; @see _GetRecordedDataInfoWXD48
typedef struct _XD48S_RECORDED_DATA_INFO_tag
{
    unsigned int        struct_size;		///< Init to struct size in bytes

	unsigned int        boardSerialNum;		///< Serial number
    char                boardName[16];		///< Name of board

    unsigned int        channelCount;		///< Channel count
    unsigned int        channelNum;			///< Channel ID; single channel data
	int					channelMask;		///< Channel mask or 0

    unsigned int        sampSizeBytes;		///< Sample size in bytes
    unsigned int        sampSizeBits;		///< Sample size in bits
    int                 bSignedSamples;		///< Signed or unsigned

	unsigned int        segment_size;		///< Segment size or zero
    unsigned int        trig_offset;		///< Relates first sample to trig
    int                 bPreTrigger;		///< ? Pre-trigger : trigger delay

    unsigned int        header_bytes;		///< Size of app-specific header
    int                 bTextData;			///< Data is text (versus binary)?
    int                 textRadix;			///< Radix of text data (10/16)

    double              sampleRateMHz;		///< Sampling rate in MHz
    double              inputVoltRngPP;		///< Peak-to-peak input volt range

} XD48S_RECORDED_DATA_INFO;

// -- Character-type agnostic code should use GetRecordedDataInfoXD48 macro
// Obtain information on data recorded to given file (char)
int _GetRecordedDataInfoAXD48 (const char*               pathnamep,
                                   XD48S_RECORDED_DATA_INFO* infop,
                                   char**                    operator_notespp _XD48_DEF(NULL));
// Obtain information on data recorded to given file (wchar_t)
int _GetRecordedDataInfoWXD48 (const wchar_t*            pathnamep,
                                   XD48S_RECORDED_DATA_INFO* infop,
                                   wchar_t**                 operator_notespp _XD48_DEF(NULL));

///@defgroup __XD48SRDCENUM_				XD48SRDCENUM_ : SRDC enumeration flags
///@see _EnumSrdcItemsWXD48
///@{
#define XD48SRDCENUM_SKIP_STD               0x00000001	///< Skip standard SRDC items; use to obtain only user-defined items
#define XD48SRDCENUM_SKIP_USER_DEFINED      0x00000002	///< Skip user-defined SRDC items; use to obtain only standard items
#define XD48SRDCENUM_MODIFIED_ONLY          0x00000004	///< Only include modified items
///@}

// -- Character-type agnostic code should use EnumSrdcItemsXD48 macro
// Obtain enumeration of all SRDC items with given constraints (char)
int _EnumSrdcItemsAXD48 (HXD48SRDC hFile, char** itemspp, int flags _XD48_DEF(0));
// Obtain enumeration of all SRDC items with given constraints (wchar_t)
int _EnumSrdcItemsWXD48 (HXD48SRDC hFile, wchar_t** itemspp, int flags _XD48_DEF(0));

// Returns > 0 if SRDC data is modified
int IsSrdcFileModifiedXD48 (HXD48SRDC hFile);

// --- Software waveform generation routines --- //

///@defgroup __XD48CYCLECALCF_				XD48CYCLECALCF_ : XD48S_CYCLE_CALC_CTX::flags
///@see XD48S_CYCLE_CALC_CTX
///@{
#define XD48CYCLECALCF_FIND_CLOSEST			0x00000100	///< If given cycle count cannot match, try to find closest that will
#define XD48CYCLECALCF_FINDHOW__MASK		0x0000000F	///< Defines bits that govern how to find closest
#define XD48CYCLECALCF_FINDHOW_CLOSEST		         0	///< Find closest match to requested PPC; higher or lower okay
#define XD48CYCLECALCF_FINDHOW_LOWER		         1	///< Find closest match to PPC without going over
#define XD48CYCLECALCF_FINDHOW_HIGHER		         2	///< Find closest match to PPC without going under
#define XD48CYCLECALCF_ADJUSTED_PPC_COUNT	0x80000000	///< Function had to adjust PPC count; set by CalculateCycleCountsXD48
#define XD48CYCLECALCF__DEFAULT				0
///@}

/// Context structure used for CalculateCycleCountsXD48
///@see CalculateCycleCountsXD48
typedef struct _XD48S_CYCLE_CALC_CTX_tag
{
	unsigned int		sizeofThis;

	/** @brief XD48CYCLECALCF_*

		Flags XD48CYCLECALCF_* that further define function behavior. If
		closest-match finding is enabled and performed, the library will
		set the XD48CYCLECALCF_ADJUSTED_PPC_COUNT flag.
	*/
	unsigned int		flags;				// XD48CYCLECALCF_*


	/** @brief Maximum sample count to consider
		
		Defines the maximum number of samples to consider when finding
		sample count. Passing zero for this member will result in the
		function using the maximum total sample count.
	*/
	unsigned int		max_samples;		// 0,Default: Maximal

	/** @brief Required alignment in samples

		Defines the required alignment required for the resultant sample
		count. Passing zero for this member will result in the function
		using the default PXDAC4800 sample alignment which is 64 bytes
		(32 16-bit samples or 64 b-bit samples)
	*/
	unsigned int		align_override;		// 0,Default: 64 bytes

	/** @brief DAC input data rate

		Defines the DAC input data rate that will be used to playback the
		signal. The DAC input data rate is the DAC's playback rate divided
		by the current interpolation factor. Passing zero for this member
		will result in the function using the given PXDAC4800's current DAC
		input rate.
	*/
	double				dDacDataRateMHz;	// 0,Default: Board's current

	// -- Used when finding closest match 

	/** @brief Frequency alignment used when finding closest match

		Defines an alignment for frequencies used in finding the closest
		match for a points-per-cycle that cannot fit in an acceptable number
		of samples. Passing zero for this member will result in the function
		using an alignment near 100KHz. The actual value will be optimized
		to yield more aligned results.
	*/
	double				dSearchAlignMHz;	// 0,Default: ~100KHz

	/** @brief Frequency delta used when finding closest match

		Defines the delta used when searching for closest match. This value
		will be incrementally added/subtracted from the realigned (via
		dSearchAlignMHz) output frequency. Passing zero for this member will
		result in the function using an optimized value near 100KHz.
	*/
	double				dSearchDeltaMHz;	// 0,Default:  128KHz

	/** @brief Maximum frequency deviation

		Defines the maximum frequency deviation (+/-) to allow when finding
		closest match. Passing zero for this member will allow any valid
		frequency to be used.
	*/
	double				dMaxDeviationMHz;	// 0,Default: No max

	/** @brief Resultant points-per-cycle count

		The function will write the resultant closest-match points-per-cycle
		value to this member.
	*/
	double				dClosestPPC;		// out: Closest pts-per-cycle

	/** @brief Resultant PXDAC4800 output signal frequency

		The function will write the resultant closest-match output frequency
		value to this member.
	*/
	double				dClosestMHz;		// out: Output freq for match
	
} XD48S_CYCLE_CALC_CTX;

// Calculate number of cycles needed to fit in RAM, aligned for playback
int CalculateCycleCountsXD48 (HXD48                 hBrd,
                                  double                dPtsPerCycle,
                                  unsigned int*         pSampleCount,
                                  XD48S_CYCLE_CALC_CTX* ctxp          _XD48_DEF(NULL));

// --- Remote device routines --- //

#define XD48_SERVER_PREFERRED_PORT          3498		///< Preferred port for remote PXDAC4800 servers
#define XD48_SERVER_REQ_TIMEOUT_DEF         3000		///< Default timeout for a remote PXDAC4800 service request in milliseconds

// Call once per application instance to initialize sockets implementation
int SocketsInitXD48();
// Sockets implementation cleanup; call if your app calls InitSocketsXD48
int SocketsCleanupXD48();

// -- Character-type agnostic code should use GetRemoteDeviceCountXD48 macro
// Obtain count (and optionally serial numbers) of remote PXDAC4800 devices
int _GetRemoteDeviceCountAXD48 (const char*    server_addrp,
								    unsigned short port          _XD48_DEF (XD48_SERVER_PREFERRED_PORT),
								    unsigned int** sn_bufpp      _XD48_DEF (NULL));
// Obtain count (and optionally serial numbers) of remote PXDAC4800 devices
int _GetRemoteDeviceCountWXD48 (const wchar_t* server_addrp,
								    unsigned short port          _XD48_DEF (XD48_SERVER_PREFERRED_PORT),
								    unsigned int** sn_bufpp      _XD48_DEF (NULL));

// XD48IMP: Update marshalling in _ConnectToRemoteDeviceWXD48 when updated
///@see _ConnectToRemoteDeviceAXD48
typedef struct _XD48S_REMOTE_CONNECT_CTXA_tag
{
    unsigned int        struct_size;        ///< Init to struct size in bytes
    unsigned short      flags;              ///< Currently undefined, use 0
    unsigned short      port;
    const char*         pServerAddress;
    const char*         pApplicationName;   ///< Optional
    const char*         pSubServices;       ///< Optional

} _XD48S_REMOTE_CONNECT_CTXA;

///@see _ConnectToRemoteDeviceWXD48
typedef struct _XD48S_REMOTE_CONNECT_CTXW_tag
{
    unsigned int        struct_size;        ///< Init to struct size in bytes
    unsigned short      flags;              ///< Currently undefined, use 0
    unsigned short      port;
    const wchar_t*      pServerAddress;
    const wchar_t*      pApplicationName;   ///< Optional
    const wchar_t*      pSubServices;       ///< Optional

} _XD48S_REMOTE_CONNECT_CTXW;

// -- Character-type agnostic code should use ConnectToRemoteDeviceXD48 macro
// Obtain a handle to a PXDAC4800 residing on another computer (char)
int _ConnectToRemoteDeviceAXD48 (HXD48* phDev, unsigned int brdNum, _XD48S_REMOTE_CONNECT_CTXA* ctxp);
// Obtain a handle to a PXDAC4800 residing on another computer (wchar_t)
int _ConnectToRemoteDeviceWXD48 (HXD48* phDev, unsigned int brdNum, _XD48S_REMOTE_CONNECT_CTXW* ctxp);

// -- Character-type agnostic code should use ConnectToRemoteVirtualDeviceXD48 macro
// Obtain a handle to a virtual (fake) PXDAC4800 device on another computer
int _ConnectToRemoteVirtualDeviceAXD48 (HXD48*                      phDev,
                                            unsigned int                brdNum, 
                                            unsigned int                ordNum,
                                            _XD48S_REMOTE_CONNECT_CTXA* ctxp);
// Obtain a handle to a virtual (fake) PXDAC4800 device on another computer
int _ConnectToRemoteVirtualDeviceWXD48 (HXD48*                      phDev, 
                                            unsigned int                brdNum, 
                                            unsigned int                ordNum,
                                            _XD48S_REMOTE_CONNECT_CTXW* ctxp);

// Obtain socket of the underlying connection for remote PXDAC4800
int GetServiceSocketXD48 (HXD48 hBrd, xd48_socket_t* sockp);

// -- Character-type agnostic code should use GetHostServerInfoXD48 macro
// Obtain remote server information (char)
int _GetHostServerInfoAXD48 (HXD48 hBrd, char** server_addrpp, unsigned short* portp);
// Obtain remote server information (wchar_t)
int _GetHostServerInfoWXD48 (HXD48 hBrd, wchar_t** server_addrpp, unsigned short* portp);

///@defgroup __XD48SRF_						XD48SRF_ : SendServiceRequestXD48 flags
///@see SendServiceRequestXD48
///@{
#define XD48SRF_AUTO_HANDLE_RESPONSE        0x00000001	///< Auto-handle response; useful if you're only receive pass/fail info
#define XD48SRF_NO_VALIDATION               0x00000002	///< Do not validate response at all; default is a quick, cursory check
#define XD48SRF_AUTO_FREE_REQUEST           0x00000004	///< SendServiceRequestXD48 will free incoming request data
#define XD48SRF_CONNECTING                  0x80000000	///< Reserved for internal use
#define XD48SRF__DEFAULT					0
///@}

// Send a request to a remote PXDAC4800 service
int SendServiceRequestXD48 (HXD48        hBrd, 
                                const void*  svc_reqp,
								int          req_bytes,
                                void**       responsepp,
                                unsigned int timeoutMs _XD48_DEF(XD48_SERVER_REQ_TIMEOUT_DEF),
                                int          flags     _XD48_DEF(XD48SRF__DEFAULT));

// Free a response from a previous remote service request
int FreeServiceResponseXD48 (void* bufp);

// --- Firmware uploading/querying functions --- //

// -- PXDAC4800 Firmware Context flags (XD48FWCTXF_*)
#define XD48FWCTXF_VERIFY_FILE              0x0001		///< Not really a firmware file; used for things like verify files
#define XD48FWCTXF__DEFAULT                 0

///@defgroup __XD48UFWF_					XD48UFWF_ : Upload Firmware Flags
///@see _UploadFirmwareWXD48
///@{
#define XD48UFWF_REFRESH_ONLY               0x00000001	///< Only upload firmware if given firmware is different from what is loaded
#define XD48UFWF_COMPAT_CHECK_ONLY          0x00000002	///< Check that firmware file is compatible with hardware; no firmware loaded
#define XD48UFWF_FORCE_EEPROM_ERASE         0x00000004	///< Force erasing of unused EEPROMs even if they're already blank
///@}

///@defgroup __XD48UFWOUTF_					XD48UFWOUTF_ : Upload Firmware Output Flags
///@see _UploadFirmwareWXD48
///@{
#define XD48UFWOUTF_SHUTDOWN_REQUIRED       0x00000001	///< System must be shutdown in order for firmware update to have effect
#define XD48UFWOUTF_REBOOT_REQUIRED         0x00000002	///< System must be reboot in order for firmware update to have effect
#define XD48UFWOUTF_FW_UP_TO_DATE           0x00000004	///< All firmware is up-to-date; no firmware uploaded
#define XD48UFWOUTF_VERIFIED                0x00000008	///< Firmware was verified; no new firmware was uploaded
///@}

/** @brief 
        Prototype for optional callback function for PXDAC4800 firmware updating

    Special case: We sometimes need to wait for a specified amount of time
    in order for certain background operations to complete. This can appear
	as dead time during the firmware update process. Firmware update shells
	may want to provide some kind of notification to the operator for these
	long waits. (They can be a couple of minutes.)

    When this callback is called with the file_cur parameter of zero, then 
    the callback is a wait notification:
     If file_cur == 0 then:
      If file_total > 0 then we are about to wait for file_total ms.
      If file_total == 0 then we have just finished a wait
     If file cur != 0 then parameters are interpreted as normal (below).

    @param prog_cur     Current progress value for the current firmware file
    @param prog_total   Total progress counts for the current firmware file
    @param file_cur     1-based index of current firmware file being uploaded
    @param file_total   Total number of firmware files to be uploaded for the current firmware upload operation
*/
typedef void (*XD48_FW_UPLOAD_CALLBACK)(HXD48 hBrd, void* callback_ctx,
                                        int prog_cur, int prog_total,
                                        int file_cur, int file_total);

// -- Character-type agnostic code should use UploadFirmwareXD48 macro
// Upload PXDAC4800 firmware (char)
int _UploadFirmwareAXD48 (HXD48                   hBrd,
	                          const char*             fw_pathnamep, 
                              unsigned int            flags        _XD48_DEF(0),		// XD48UFWF_*
                              unsigned int*           out_flagsp   _XD48_DEF(NULL),		// XD48UFWOUTF_*
                              XD48_FW_UPLOAD_CALLBACK callbackp    _XD48_DEF(NULL),
                              void*                   callback_ctx _XD48_DEF(NULL));
// Upload PXDAC4800 firmware (wchar_t)
int _UploadFirmwareWXD48 (HXD48                   hBrd,
	                          const wchar_t*          fw_pathnamep, 
                              unsigned int            flags         _XD48_DEF(0),		// XD48UFWF_*
                              unsigned int*           out_flagsp    _XD48_DEF(NULL),	// XD48UFWOUTF_*
                              XD48_FW_UPLOAD_CALLBACK callbackp     _XD48_DEF(NULL),
                              void*                   callback_ctx  _XD48_DEF(NULL));

///@see _QueryFirmwareVersionInfoWXD48
typedef struct _XD48S_FW_VER_INFO_tag
{
    unsigned int        struct_size;		///< struct size in bytes

    unsigned int        fw_pkg_ver;         ///< Firmware package version
    unsigned int        fw_pkg_cust_enum;   ///< Custom fw enum (package)

    short               readme_sev;         ///< XD48FWNOTESEV_*
    short               extra_flags;        ///< XD48FWCTXF_*

} XD48S_FW_VER_INFO;

// -- Character-type agnostic code should use QueryFirmwareVersionInfoXD48 macro
// Obtain firmware version information (char)
int _QueryFirmwareVersionInfoAXD48 (const char* fw_pathnamep, XD48S_FW_VER_INFO* infop);
// Obtain firmware version information (wchar_t)
int _QueryFirmwareVersionInfoWXD48 (const wchar_t* fw_pathnamep, XD48S_FW_VER_INFO* infop);

///@defgroup __XD48FWNOTESEV_				XD48FWNOTESEV_ : Firmware Release Notes Severity
///@see _ExtractFirmwareNotesWXD48
///@{
#define XD48FWNOTESEV_NONE                  0			///< No firmware release notes provided
#define XD48FWNOTESEV_NORMAL                1			///< Firmware release notes are available
#define XD48FWNOTESEV_IMPORTANT             2			///< Important firmware release notes available; always prompted
#define XD48FWNOTESEV__COUNT                3
///@}

// -- Character-type agnostic code should use ExtractFirmwareNotesXD48 macro
// Obtain PX1500 firmware release notes from firmware file (char)
int _ExtractFirmwareNotesAXD48 (const char* fw_pathnamep,
                                    char**      notes_pathpp,
                                    int*        severityp);				// XD48FWNOTESEV_*
// Obtain PX1500 firmware release notes from firmware file (wchar_t)
int _ExtractFirmwareNotesWXD48 (const wchar_t* fw_pathnamep,
                                    wchar_t**      notes_pathpp,
                                    int*           severityp);			// XD48FWNOTESEV_*

// --- Console application helper functions --- //

#include <stdio.h>

// -- Character-type agnostic code should use DumpLibErrorXD48 macro
// Dump library error description to given file or stream (char)
int _DumpLibErrorAXD48 (int        res,
	                        const char* pPreamble, 
                            HXD48       hBrd        _XD48_DEF(XD48_INVALID_HANDLE),
                            FILE*       filp        _XD48_DEF(stderr));
// Dump library error description to standard file or stream (wchar_t)
int _DumpLibErrorWXD48 (int            res,
	                        const wchar_t* pPreamble, 
                            HXD48          hBrd      _XD48_DEF(XD48_INVALID_HANDLE),
                            FILE*          filp      _XD48_DEF(stderr));

#if defined(__linux__) && !defined(XD48PP_NO_LINUX_CONSOLE_HELP_FUNCS)

// Equivalent of old DOS getch function
int getch_XD48();
// Equivalent of old DOS kbhit function
int kbhit_XD48();

#endif

// --- Miscellaneous functions --- //

///@defgroup __XD48VERID_					XD48VERID_ : GetItemVersionXD48 Version IDs
///@see GetItemVersionXD48
///@{
#define XD48VERID_HARDWARE                  0			///< Current device hardware revision
#define XD48VERID_FIRMWARE                  1			///< Current device firmware package version; overall version of firmware
#define XD48VERID_DRIVER                    2			///< Current kernel-mode device driver version
#define XD48VERID_LIBRARY                   3			///< Current user-mode library version
#define XD48VERID_PRODUCT_SOFTWARE          4			///< Version of the current PXDAC4800 software installation
#define XD48VERID_SYS1_FIRMWARE             5			///< Current version of the underlying SYS1 device firmware
#define XD48VERID_SYS2_FIRMWARE             6			///< Current version of the underlying SYS2 device firmware
#define XD48VERID_PREV_SYS1_FIRMWARE        7			///< Previous version of the underlying SYS1 device firmware
#define XD48VERID_PREV_SYS2_FIRMWARE        8			///< Previous version of the underlying SYS2 device firmware
#define XD48VERID__COUNT                    9			// Invalid setting
///@}

///@defgroup __XD48VERF_					XD48VERF_ : GetVersionTextXD48 Flags
///@see _GetVersionTextWXD48
///@{
#define XD48VERF_NO_PREREL                  0x00000001	///< Do not include pre-release information
#define XD48VERF_NO_SUBMIN                  0x00000006	///< Do not include sub-minor info; implies XD48VERF_NO_PACKAGE
#define XD48VERF_NO_PACKAGE                 0x00000004	///< Do not include package info
#define XD48VERF_NO_CUSTOM                  0x00000008	///< Do not include custom enumeration info
#define XD48VERF_COMPACT_VER                0x00000010	///< Compact version string if possible (XX.YY.00.00 -> XX.YY)
#define XD48VERF_ZERO_PAD_SINGLE_DIGIT_VER  0x00000020	///< Use 0 padding for one digit version numbers (1.1 -> 1.01)
#define XD48VERF_ALLOW_ALIASES				0x00000040	///< Allow function to return aliases for known versions
///@}

// Obtain the version number of the given item
int GetItemVersionXD48 (HXD48 hBrd, int ver_id, unsigned long long* verp);

// Obtains a string describing the version of an item (char)
int _GetVersionTextAXD48 (HXD48 hBrd, int ver_id, char** bufpp, int flags);
// Obtains a string describing the version of an item (wchar_t)
int _GetVersionTextWXD48 (HXD48 hBrd, int ver_id, wchar_t** bufpp, int flags);

// Set user-defined data value associated with given handle
int SetUserDataXD48 (HXD48 hBrd, void* data);
// Get user-defined data value associated with given handle
int GetUserDataXD48 (HXD48 hBrd, void** datap);

#define _XD48SO_DRIVER_STATS_V1   64
#ifndef _XD48S_DRIVER_STATS_STRUCT_DEFINED
#define _XD48S_DRIVER_STATS_STRUCT_DEFINED
/// Device driver statistics; @see GetDriverStatsXD48
typedef struct _XD48_DRIVER_STATS_tag
{
    unsigned int		struct_size;        ///< IN: Structure size
    int					nConnections;       ///< Active connection count
    unsigned int		isr_cnt;            ///< Total ISR invocations
	unsigned int		dcm_reset_cnt;      ///< DCM reset operation count

    unsigned int		dmar_finished_cnt;  ///< DMA transfers finished (reads)
    unsigned int		dmar_started_cnt;   ///< DMA transfers started  (reads)
    unsigned int		dmaw_finished_cnt;  ///< DMA transfers finished (writes)
    unsigned int		dmaw_started_cnt;   ///< DMA transfers started  (writes)

    unsigned int		pb_started_cnt;     ///< Playbacks started
    unsigned int		pb_finished_cnt;    ///< Playbacks completed
	unsigned int		samp_comp_int_cnt;	///< Samples Complete interrupt count
	unsigned int		reserved2;

    unsigned long long  dmar_bytes;		    ///< Total bytes read by DMA
	unsigned long long  dmaw_bytes;		    ///< Total bytes wrote by DMA

} XD48S_DRIVER_STATS;
#endif

// Obtain PXDAC4800 driver/device statistics
int GetDriverStatsXD48 (HXD48 hBrd, XD48S_DRIVER_STATS* statsp, int bReset _XD48_DEF(0));

// Read an element from the PXDAC4800 configuration EEPROM
int ReadConfigEepromXD48 (HXD48 hBrd, int element_idx, unsigned short* eeprom_datap);
// Write an element from the PXDAC4800 configuration EEPROM
int WriteConfigEepromXD48 (HXD48 hBrd, int element_idx, unsigned short eeprom_data);

// Run an integrity check on configuration EEPROM data
int ValidateConfigEepromXD48 (HXD48 hBrd);

///@defgroup __XD48ETF_						XD48ETF_ : GetErrorTextXD48 flags
///@see _GetErrorTextWXD48
///@{
#define XD48ETF_IGNORE_SYSERROR             0x00000001	///< Disregard system error information
#define XD48ETF_NO_SYSERROR_TEXT            0x00000002	///< Do not generate system error code text
#define XD48ETF_FORCE_SYSERROR              0x00000004	///< Display system error information even if it may not be relevant
///@}

// -- Character-type agnostic code should use GetErrorTextXD48 macro
// Obtains a string describing the given library error code (char)
int _GetErrorTextAXD48 (int res, char** bufpp, int flags, HXD48 hBrd _XD48_DEF(NULL));
// Obtains a string describing the given library error code (wchar_t)
int _GetErrorTextWXD48 (int res, wchar_t** bufpp, int flags, HXD48 hBrd _XD48_DEF(NULL));

///@defgroup __XD48FWTYPE_					XD48FWTYPE_ : PXDAC4800 Firmware Types
///@see CheckFirmwareVerXD48
///@{
#define XD48FWTYPE_SYS1                     0			///< SYS1 FPGA firmware
#define XD48FWTYPE_SYS2                     1			///< SYS2 FPGA firmware
#define XD48FWTYPE_PACKAGE                  2			///< Generic firmware package; firmware version that end users see
#define XD48FWTYPE__COUNT                   3
///@}

/* Deprecated Flags --Fg
///@defgroup __XD48VCT_						XD48VCT_ : PXDAC4800 version constraint types
///@see CheckFirmwareVerXD48
///@{
#define XD48VCT_GTOE                        0			///< Greater than or equal to (>=)
#define XD48VCT_LTOE                        1			///< Less than or equal to (<=)
#define XD48VCT_GT                          2			///< Greater than (>)
#define XD48VCT_LT                          3			///< Less than (<)
#define XD48VCT_E                           4			///< Equal to (==)
#define XD48VCT_NE                          5			///< Not equal to (!=)
#define XD48VCT__COUNT                      6
///@}
*/
// Ensures that desired firmware matches desired constraint
/*int CheckFirmwareVerXD48 (HXD48        hBrd, 
	                          unsigned int fw_ver, 
                              int          fw_type    _XD48_DEF(XD48FWTYPE_SYS1),	// XD48FWTYPE_*
                              int          constraint _XD48_DEF(XD48VCT_GTOE));		// XD48VCT_*
*/
// Free memory allocated by this library
// NOTE: Do not call this for DMA buffers; use FreeDmaBufferXD48 instead
int FreeMemoryXD48 (void* p);
//internal usage only
ULONG getDmaTlpSizeXD48 (HXD48 hBrd);