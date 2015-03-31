#ifndef PXDAC_MEMORY_H
#define PXDAC_MEMORY_H

typedef unsigned long* HXD48;


typedef unsigned short U16;

int initializeU16(HXD48 handle, unsigned int totalnumberofsamples, unsigned int chunk_size);

void writeU16(unsigned int position, unsigned int length, U16* data);
void writeRAW(unsigned int position, unsigned int length, void* data);

int synchronize(bool asynchron_transfer);

int free_memory();

void setLogFile(const char* path);

int getMode();

#endif