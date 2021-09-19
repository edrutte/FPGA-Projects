/*******************************************************************
* SHA-256 H and K values
* Created 9/5/2021 By Evan Ruttenberg
*******************************************************************/

#ifndef SMARTC_HK_H
#define SMARTC_HK_H

#define H0 1779033703
#define H1 3144134277
#define H2 1013904242
#define H3 2773480762
#define H4 1359893119
#define H5 2600822924
#define H6 528734635
#define H7 1541459225

#define K0 1116352408   //Thank you python
#define K1 1899447441   //Thank you python
#define K2 3049323471   //Thank you python
#define K3 3921009573   //Thank you python
#define K4 961987163    //Thank you python
#define K5 1508970993   //Thank you python
#define K6 2453635748   //Thank you python
#define K7 2870763221   //Thank you python
#define K8 3624381080   //Thank you python
#define K9 310598401    //Thank you python
#define K10 607225278   //Thank you python
#define K11 1426881987  //Thank you python
#define K12 1925078388  //Thank you python
#define K13 2162078206  //Thank you python
#define K14 2614888103  //Thank you python
#define K15 3248222580  //Thank you python
#define K16 3835390401  //Thank you python
#define K17 4022224774  //Thank you python
#define K18 264347078   //Thank you python
#define K19 604807628   //Thank you python
#define K20 770255983   //Thank you python
#define K21 1249150122  //Thank you python
#define K22 1555081692  //Thank you python
#define K23 1996064986  //Thank you python
#define K24 2554220882  //Thank you python
#define K25 2821834349  //Thank you python
#define K26 2952996808  //Thank you python
#define K27 3210313671  //Thank you python
#define K28 3336571891  //Thank you python
#define K29 3584528711  //Thank you python
#define K30 113926993   //Thank you python
#define K31 338241895   //Thank you python
#define K32 666307205   //Thank you python
#define K33 773529912   //Thank you python
#define K34 1294757372  //Thank you python
#define K35 1396182291  //Thank you python
#define K36 1695183700  //Thank you python
#define K37 1986661051  //Thank you python
#define K38 2177026350  //Thank you python
#define K39 2456956037  //Thank you python
#define K40 2730485921  //Thank you python
#define K41 2820302411  //Thank you python
#define K42 3259730800  //Thank you python
#define K43 3345764771  //Thank you python
#define K44 3516065817  //Thank you python
#define K45 3600352804  //Thank you python
#define K46 4094571909  //Thank you python
#define K47 275423344   //Thank you python
#define K48 430227734   //Thank you python
#define K49 506948616   //Thank you python
#define K50 659060556   //Thank you python
#define K51 883997877   //Thank you python
#define K52 958139571   //Thank you python
#define K53 1322822218  //Thank you python
#define K54 1537002063  //Thank you python
#define K55 1747873779  //Thank you python
#define K56 1955562222  //Thank you python
#define K57 2024104815  //Thank you python
#define K58 2227730452  //Thank you python
#define K59 2361852424  //Thank you python
#define K60 2428436474  //Thank you python
#define K61 2756734187  //Thank you python
#define K62 3204031479  //Thank you python
#define K63 3329325298  //Thank you python

static const uint32_t k[64] = {
        K0, K1, K2, K3, K4,
        K5, K6, K7, K8, K9,
        K10, K11, K12, K13,
        K14, K15, K16, K17,
        K18, K19, K20, K21,
        K22, K23, K24, K25,
        K26, K27, K28, K29,
        K30, K31, K32, K33,
        K34, K35, K36, K37,
        K38, K39, K40, K41,
        K42, K43, K44, K45,
        K46, K47, K48, K49,
        K50, K51, K52, K53,
        K54, K55, K56, K57,
        K58, K59, K60, K61,
        K62, K63
};

#endif //SMARTC_HK_H
