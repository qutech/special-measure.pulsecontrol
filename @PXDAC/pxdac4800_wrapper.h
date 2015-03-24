#ifndef PXDAC4800WRAPPER
#define PXDAC4800WRAPPER

#define AWGAPI

typedef unsigned long* HXD48;
typedef struct _XD48S_CYCLE_CALC_CTX_tag
{
	unsigned int struct_size;
	unsigned int flags; // XD48CYCLECALCF_*
	unsigned int max_samples; // 0,Default: Maximal
	unsigned int align_override; // 0,Default: 64 bytes
	double dDacDataRateMHz; // 0,Default: Board's current
	// -- Used when finding closest match
	double dSearchAlignMHz; // 0, Default: ~100KHz
	double dSearchDeltaMHz; // 0, Default: 128KHz
	double dMaxDeviationMHz; // 0, Default: No max
	double dClosestPPC; // out: Closest points-per-cycle
	double dClosestMHz; // out: Output frequency for match
} XD48S_CYCLE_CALC_CTX;

char* GetErrorMessXD48(int res, char* bufp, int flags, HXD48 hBrd);

int GetMaxByteCountForActiveChanMaskXD48 (HXD48 hBrd, int chan_mask, unsigned int* pmax_bytes);

int AllocateDmaBufferXD48 (HXD48 hBrd, unsigned int bytes, void** bufpp);

int GetDeviceCountXD48();

int ConnectToDeviceXD48(HXD48* phDev, unsigned int brdNum);
int DisconnectFromDeviceXD48 (HXD48 hBrd);

int GetSerialNumberXD48 (HXD48 hBrd, unsigned int* snp);

int SetPowerupDefaultsXD48(HXD48 hBrd);

int SetActiveChannelMaskXD48(HXD48 hBrd, int val);

int FreeDmaBufferXD48 (HXD48 hBrd, void* bufp);

int IsDcXD48 (HXD48 hBrd);

// trigger configuration
int SetTriggerModeXD48(HXD48 hBrd, int val);
int SetExternalTriggerEnableXD48(HXD48 hBrd, int bEnable);


// helper functions
int CalculateCycleCountsXD48(
	HXD48 hBrd,
	double dPtsPerCycle,
	unsigned int* pSampleCount,
	XD48S_CYCLE_CALC_CTX* ctxp );  // = 0 is valid
int InterleaveData16bit2ChanXD48(
	const unsigned short* src_ch1p,
	const unsigned short* src_ch2p,
	unsigned int samps_per_chan,
	unsigned short* dstp);
int InterleaveData16bit4ChanXD48(
	const unsigned short* src_ch1p,
	const unsigned short* src_ch2p,
	const unsigned short* src_ch3p,
	const unsigned short* src_ch4p,
	unsigned int samps_per_chan);


int LoadRamBufXD48(	HXD48 hBrd,
	unsigned int offset_bytes,
	unsigned int length_bytes,
	const void* bufp,
	int bAsynchronous);
int IssueSoftwareTriggerXD48(HXD48 hBrd);


// Channel 1 output voltage; [0, 1023]
int SetOutputVoltageCh1XD48(HXD48 hBrd, int val);
// Channel 1 output voltage; [0, 1023]
int GetOutputVoltageCh1XD48(HXD48 hBrd, int bFromCache);

// Channel 2 output voltage; [0, 1023]
int SetOutputVoltageCh2XD48(HXD48 hBrd, int val);
// Channel 2 output voltage; [0, 1023]
int GetOutputVoltageCh2XD48(HXD48 hBrd, int bFromCache);

// Channel 3 output voltage; [0, 1023]
int SetOutputVoltageCh3XD48(HXD48 hBrd, int val);
// Channel 3 output voltage; [0, 1023]
int GetOutputVoltageCh3XD48(HXD48 hBrd, int bFromCache );

// Channel 4 output voltage; [0, 1023]
int SetOutputVoltageCh4XD48(HXD48 hBrd, int val);
// Channel 4 output voltage; [0, 1023]
int GetOutputVoltageCh4XD48(HXD48 hBrd, int bFromCache );

// Obtain peak-to-peak voltage for given output voltage encoding [0, 1023]
int GetOutputVoltageRangeVoltsXD48(int     val,
	double* pPeakToPeakVolts,
	HXD48   hBrd);


#endif
