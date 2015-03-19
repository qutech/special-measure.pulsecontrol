typedef unsigned long* HXD48;

typedef unsigned short U16;

typedef unsigned int size_type;

#define EXPORT __declspec(dllexport)

#ifdef __cplusplus
extern "C" {
#endif

	EXPORT int initializeU16(HXD48 handle, unsigned int total_memory, unsigned int chunk_size);

	EXPORT void writeU16(unsigned int position, unsigned int length, U16* data);

	EXPORT void writeRAW(unsigned int position, unsigned int length, void* data);

	EXPORT int synchronize(bool async);

	EXPORT int free_memory();

	EXPORT void setLogFile(const char* path);

	EXPORT int getMode();

#ifdef __cplusplus
}
#endif