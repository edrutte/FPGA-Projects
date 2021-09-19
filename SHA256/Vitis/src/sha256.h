/*******************************************************************
* SHA-256 Interface
* Created 9/3/2021 By Evan Ruttenberg
*******************************************************************/

#ifndef SMARTC_SHA256_H
#define SMARTC_SHA256_H
#define NullChunk (Chunk_t) { .Chunk = {0, 0, 0, 0, 0, 0, 0, 0,\
											 0, 0, 0, 0, 0, 0, 0, 0,\
											 0, 0, 0, 0, 0, 0, 0, 0,\
											 0, 0, 0, 0, 0, 0, 0, 0,\
											 0, 0, 0, 0, 0, 0, 0, 0,\
											 0, 0, 0, 0, 0, 0, 0, 0,\
											 0, 0, 0, 0, 0, 0, 0, 0,\
											 0, 0, 0, 0, 0, 0, 0, 0}}



typedef struct {
	uint8_t Chunk[64];
} Chunk_t;


//typedef struct {
//	uint32_t NumChunks;
//	uint32_t OverflowChunk;
//} ChunkNum_t;

//typedef struct {
//	Chunk_t Chunks[16384];
//	ChunkNum_t ChunkNums;
//} ChunkArray_t;

//typedef struct {
//  char *Message;
//  uint32_t Len;
//} Input_t;

typedef struct __attribute__ ((__scalar_storage_order__ ("big-endian")))  {
	uint32_t Schedule[64];
} Schedule_t;

typedef struct {
	int32_t Hash[8];
} Hash_t;

static inline uint32_t rotr32 (uint32_t n, unsigned int c) {
    const unsigned int mask = (8*sizeof(n) - 1);
    c &= mask;
    return (n>>c) | (n<<( (-c)&mask ));
}

static const Chunk_t D16[16] = {NullChunk, NullChunk, NullChunk, NullChunk,
									  NullChunk, NullChunk, NullChunk, NullChunk,
									  NullChunk, NullChunk, NullChunk, NullChunk,
									  NullChunk, NullChunk, NullChunk, NullChunk};



//ChunkNum_t getNumChunks(uint32_t Len);
//uint32_t ntohl(uint32_t netlong);
Hash_t sha256main(Chunk_t Chunks[16], uint8_t Len);
Hash_t sha256chunk(const Chunk_t D, Hash_t LastHash);
Schedule_t scheduleHash(const Chunk_t D, Schedule_t Schedule);
Hash_t hashCompress(Schedule_t Schedule, Hash_t LastHash);
//void preProcess(char *Message, uint32_t Len, Chunk_t ca[16384], ChunkNum_t ChunkNums);
Schedule_t schedule(const Chunk_t Chunk, Schedule_t Schedule);

#endif //SMARTC_SHA256_H
