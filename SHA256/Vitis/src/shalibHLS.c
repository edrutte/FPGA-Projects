/*********************************************************************
* SHA-256 HLS Implementation Library
* Created 9/3/2021 By Evan Ruttenberg
*********************************************************************/
//#define NO_SYNTH

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include "sha256.h"
#include "HK.h"

/*
uint32_t ntohl(uint32_t netlong)
{
    union {
        uint16_t num;
        uint8_t bytes[2];
    } endian_test = { .bytes = { 0x01, 0x00 }};

    if (endian_test.num == 0x0001) {
        netlong = (netlong << 24) | ((netlong & 0xFF00ul) << 8) |
            ((netlong & 0xFF0000ul) >> 8) | (netlong >> 24);
    }

    return netlong;
}
*/
#ifdef NO_SYNTH
ChunkNum_t getNumChunks(uint32_t Len) {
	uint64_t BoolMessLen = Len * 8;
	ChunkNum_t ChunkNums;
	ChunkNums.OverflowChunk = -1;
	ChunkNums.NumChunks = (BoolMessLen / 512) + 1;
	if ((BoolMessLen % 512) >= 448) {
		ChunkNums.NumChunks++;
		ChunkNums.OverflowChunk = ChunkNums.NumChunks - 1;
	    }
	return ChunkNums;
}


void preProcess(char *Message, uint32_t Len, Chunk_t ca[16384], ChunkNum_t ChunkNums) {
	for (uint32_t i = 0; i < ChunkNums.NumChunks; i++) {
        Chunk_t Chunk;
        uint8_t MSize;
        if (i != ChunkNums.OverflowChunk) {
            MSize = (uint8_t) fmin(Len - (64 * i), 64);
        } else {
            MSize = 0;
        }
        if (MSize == 64) {
            memcpy(&(Chunk.Chunk), &(Message[64 * i]), 64);
            memcpy(&(ca[i]), &(Chunk.Chunk), sizeof(Chunk_t));
        } else if (MSize >= 56) {
            memcpy(&(Chunk.Chunk), &(Message[64 * i]), MSize);
            Chunk.Chunk[MSize] = 128;
            for (uint8_t j = MSize + 1; j < 63; j++) {
                Chunk.Chunk[j] = 0;
            }
            memcpy(&(ca[i]), &(Chunk.Chunk), sizeof(Chunk_t));
        } else {
            if (MSize > 0) {
                memcpy(&(Chunk.Chunk), &(Message[64 * i]), MSize);
                Chunk.Chunk[MSize] = 128;
                MSize++;
            }
            for (uint8_t j = MSize; j < 56; j++) {
                Chunk.Chunk[j] = 0;
            }
            for (int8_t j = 0; j < 8; j++) {
                Chunk.Chunk[j + 56] = (uint8_t) (((uint64_t) (Len * 8)) >> (8 * (7 - j)));
            }
            memcpy(&(ca[i]), &(Chunk.Chunk), sizeof(Chunk_t));
        }
    }
}
#endif

Schedule_t schedule(const Chunk_t Chunk, Schedule_t Schedule) {
	memset(&(Schedule.Schedule), 0, 256);
    memcpy(&(Schedule.Schedule), Chunk.Chunk, 64);
    return Schedule;
}

Schedule_t scheduleHash(const Chunk_t D, Schedule_t Schedule) {

    Schedule = schedule(D, Schedule);
    for (uint8_t i = 16; i < 64; i++) {
        uint32_t s0 = rotr32(Schedule.Schedule[i - 15], 7) ^ rotr32(Schedule.Schedule[i - 15], 18) ^ (Schedule.Schedule[i - 15] >> 3);
        uint32_t s1 = rotr32(Schedule.Schedule[i - 2], 17) ^ rotr32(Schedule.Schedule[i - 2], 19) ^ (Schedule.Schedule[i - 2] >> 10);
        uint32_t temp = (Schedule.Schedule[i - 16] + s0 + Schedule.Schedule[i - 7] + s1) & (uint32_t) (pow(2, 32) - 1);
        Schedule.Schedule[i] = temp;
    }
    return Schedule;
}

Hash_t hashCompress(Schedule_t Schedule, Hash_t LastHash) {

	uint32_t a = LastHash.Hash[0];
    uint32_t b = LastHash.Hash[1];
    uint32_t c = LastHash.Hash[2];
    uint32_t d = LastHash.Hash[3];
    uint32_t e = LastHash.Hash[4];
    uint32_t f = LastHash.Hash[5];
    uint32_t g = LastHash.Hash[6];
    uint32_t h = LastHash.Hash[7];
    for (uint8_t i = 0; i < 64; i++) {
        uint32_t S1 = rotr32(e, 6) ^ rotr32(e, 11) ^ rotr32(e, 25);
        uint32_t ch = (e & f) ^ ((~e) & g);
        uint32_t temp1 = (h + S1 + ch + k[i] + Schedule.Schedule[i]) & (uint32_t) (pow(2, 32) - 1);
        uint32_t S0 = rotr32(a, 2) ^ rotr32(a, 13) ^ rotr32(a, 22);
        uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
        uint32_t temp2 = (S0 + maj) & (uint32_t) (pow(2, 32) - 1);
        h = g;
        g = f;
        f = e;
        e = (d + temp1) & (uint32_t) (pow(2, 32) - 1);
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & (uint32_t) (pow(2, 32) - 1);
    }
    return (Hash_t) { .Hash = {a, b, c, d, e, f, g, h}};
}

Hash_t sha256chunk(const Chunk_t D, Hash_t LastHash) {
	#pragma HLS inline off
	static Schedule_t Schedule;
	Schedule = scheduleHash(D, Schedule);
    static Hash_t Compress;
	Compress = hashCompress(Schedule, LastHash);
    LastHash.Hash[0] = (Compress.Hash[0] + LastHash.Hash[0]) & (uint32_t) (pow(2, 32) - 1);
    LastHash.Hash[1] = (Compress.Hash[1] + LastHash.Hash[1]) & (uint32_t) (pow(2, 32) - 1);
    LastHash.Hash[2] = (Compress.Hash[2] + LastHash.Hash[2]) & (uint32_t) (pow(2, 32) - 1);
    LastHash.Hash[3] = (Compress.Hash[3] + LastHash.Hash[3]) & (uint32_t) (pow(2, 32) - 1);
    LastHash.Hash[4] = (Compress.Hash[4] + LastHash.Hash[4]) & (uint32_t) (pow(2, 32) - 1);
    LastHash.Hash[5] = (Compress.Hash[5] + LastHash.Hash[5]) & (uint32_t) (pow(2, 32) - 1);
    LastHash.Hash[6] = (Compress.Hash[6] + LastHash.Hash[6]) & (uint32_t) (pow(2, 32) - 1);
    LastHash.Hash[7] = (Compress.Hash[7] + LastHash.Hash[7]) & (uint32_t) (pow(2, 32) - 1);
    return LastHash;
}



Hash_t sha256main(Chunk_t Chunks[16], uint8_t Len) {
    //ChunkNum_t num = getNumChunks(Len);
	//Chunk_t prep[16384];
    //preProcess(Message, Len, prep, num);

	Hash_t Last;
    Last.Hash[0] = (uint32_t) H0;
    Last.Hash[1] = (uint32_t) H1;
    Last.Hash[2] = (uint32_t) H2;
    Last.Hash[3] = (uint32_t) H3;
    Last.Hash[4] = (uint32_t) H4;
    Last.Hash[5] = (uint32_t) H5;
    Last.Hash[6] = (uint32_t) H6;
    Last.Hash[7] = (uint32_t) H7;
    for (uint8_t i = 0; i < 16; i++) {
    	if (i < Len) {
        	Last = sha256chunk(Chunks[i], Last);
    	}
    }
    return Last;
}
#ifdef NO_SYNTH
	int main(int argc, char* argv[]) {
		ChunkNum_t num = getNumChunks(strlen("hello world"));
		Chunk_t prep[16384];
		preProcess("hello world", (uint32_t) strlen("hello world"), prep, num);
		Hash_t out = sha256main(prep, 1);
		printf("%x%x%x%x%x%x%x%x\n", out.Hash[0], out.Hash[1], out.Hash[2], out.Hash[3], out.Hash[4], out.Hash[5], out.Hash[6], out.Hash[7]);
		return 0;
	}
#endif
