package rrv64_core_vec_param_pkg
//============================================
// Zve32f vector extensions
//============================================
// Extension    Minimum_VLEN    Supported_EEW   FP32    FP64
// Zve32f       32              8, 16, 32       Y       N

////////////////
// Parameters //
////////////////

// Width of integer register in bits
//parameter  XLEN        = RRV64_XLEN;
// The maximum size in bits of a vector element that any operation can produce or consume
parameter  ELEN        = 32;
// The number of bits in a single vector register
parameter  VLEN        = 512;
// Vector register length in bytes
parameter  VLENB       = VLEN / 8;
// The maximum number of elements that can be operated on with a single vector instruction
parameter  VLMAX       = VLEN; // SEW = EW8, LMUL = 8. VL = 8 * VLEN / 8 = VLEN

// The number of bits to calculate in a single vector function unit 
parameter  VFULEN          = 256;
// The number of vector function unit, exclude VLSU
parameter  VFU_NUM         = 2;
// The number of vector process unit, include VLSU
parameter  VPU_NUM         = 3;
// The number of vector score board entries
parameter  VSB_ENT_NUM     = 16;
parameter  VSB_ENT_ADDR_W  = $clog2(VSB_ENT_NUM);

// The maximum number of elements within a uop
parameter  UVLMAX                       = VFULEN / 8;
// The number of uvrf. uvrf_idx = {     vrf_idx[4:0], partial_idx[0]}
parameter  UVRF_NUM                     = VLEN / VFULEN * 32;


parameter  VEC_ISSUEQ_NUM               = 3;    // Vector issue queue number
parameter  ISSUEW_UVRF_RD_PORT_NUM      = 8;    // The number of issueq rd uvrf ports
parameter  UVRF_RD_PORT_NUM             = 6;    // The number of actual rd uvrf ports 
parameter  UVDRQ_UVRF_WR_PORT_NUM       = VEC_ISSUEQ_NUM;
parameter  UVRF_WR_PORT_NUM             = 3;

parameter  UVDRQ_VLS_FWD_NUM            = 8;
parameter  UVDRQ_VFU_FWD_NUM            = 8;  // TBD
parameter  UVRF_FWD_NUM                 = UVDRQ_VLS_FWD_NUM + VFU_NUM*UVDRQ_VFU_FWD_NUM;

parameter  VDQ_DISP_NUM                 = 2;    // VDQ output maximum uop number to vector issuew
parameter  ISSUEW_RD_UVRF_NUM           = 8;

parameter  VLS_UVDRQ_ENT_NUM            = 8;    // Vector load uvd result queue entry depth
parameter  VLS_UVDRQ_WR_NUM             = 8;    // uvd number of vector load unit write back 

parameter  ROB_VSB_WKUP_NUM             = 1; 

parameter  RRV64_VDQ_IPRF_RD_PORT_NUM   = 2;
parameter  RRV64_VDQ_FPRF_RD_PORT_NUM   = 1;

parameter  RRV64_VFPU_BYPASS            = 1;

parameter  VFULEN_BYTE_NUM              = VFULEN/8;
parameter  VLS_UVDRQ_FILED_SHIFT_UNITS_W= VFULEN/8;

parameter VEC_BYPASS_FP = 0;
parameter VEC_COSTDOWN  = 0;

parameter VFU_UVDRQ_ENT_NUM = VLEN * 8 / VFULEN;
//VLSU
parameter RRV64_VLSU_SPLIT_NUM = 4;
parameter RRV64_LSU_VRQ_FIFO_DEPTH = 4;
parameter RRV64_LSU_VLSQ_FIFO_DEPTH = 32;
parameter RRV64_LSU_VRQ_IDX_W   = $clog2(RRV64_LSU_VRQ_FIFO_DEPTH);
parameter RRV64_LSU_VLSQ_IDX_W   = $clog2(RRV64_LSU_VLSQ_FIFO_DEPTH);

parameter RRV64_VLSU_ISSUE_NUM = 1;

parameter RRV64_LSU_L1DC_LD_NUM = RRV64_LSU_BANK_N * RRV64_LSU_IBK_N;

parameter RRV64_LSU_BANKS         = 2;
//parameter RRV64_LSU_CHANNELS      = 8;
parameter RRV64_LSU_ELEMENT_ID_W  = $clog2(UVLMAX);
parameter RRV64_LSU_L1D_DATA_SIZE = 8;//8byte
parameter RRV64_LSU_L1D_DATA_CL_SIZE = 64;//64byte

parameter RRV64_XLEN_BYTE   = RRV64_XLEN/8;
parameter RRV64_XLEN_BYTE_W  = $clog2(RRV64_XLEN_BYTE);

parameter VEC_MACRO_IDX_BIT  = $clog2(RRV64_VEC_ISSUEQ_DEPTH) + 1;

parameter VECTOR_ROB_NUM    = 2;

parameter RRV64_VSRQ_IPRF_RD_NUM    = 3;
parameter RRV64_VSRQ_FPRF_RD_NUM    = 1;

parameter TOKEN_LIST_DEPTH          = 15;
parameter TOKEN_IDX_W               = $clog2(TOKEN_LIST_DEPTH);

// VRF
parameter VRF_RPORT_NUM     = 5;

parameter ISA_VREG_NUM      = 32;
parameter ISA_VREG_WIDTH    = $clog2(ISA_VREG_NUM);

// bank info
parameter PERBANK_ROW_SIZE  = 16;
parameter PERBANK_ROW_WIDTH = $clog2(BANK_ROW_SIZE);
parameter PERBANK_COL_SIZE  = 1;
parameter PERBANK_COL_WIDTH = 1; // $clog2(PERBANK_COL_SIZE);
parameter VRF_PREBANK_RPORT = 2;
parameter VRF_PREBANK_WPORT = 1;

// bank cluster info
parameter BANK_X_SIZE       = VLEN/VFULEN;
parameter BANK_X_WIDTH      = $clog2(BANK_X_SIZE);
parameter BANK_Y_SIZE       = 32/16;
parameter BANK_Y_WIDTH      = $clog2(BANK_Y_SIZE);
parameter VRF_BANK_NUM      = BANK_X_SIZE * BANK_Y_SIZE;
parameter VERG_ADDR_WIDTH   = ISA_VREG_WIDTH + BANK_X_WIDTH;

/* struct */
typedef struct {
    logic   [VRF_RPORT_NUM-1:0]                         vld;
    logic   [VRF_RPORT_NUM-1:0][VERG_ADDR_WIDTH-1:0]    vaddr;
    logic   [VRF_RPORT_NUM-1:0][VSB_ENT_NUM-1:0]        rs_idx;
    logic   [VRF_RPORT_NUM-1:0][1:0]                    rs_field_idx;
} prf_pipereg_t;

typedef struct {
    logic   [VRF_RPORT_NUM-1:0]                    vld;
    logic   [VRF_RPORT_NUM-1:0][VFULEN-1:0]        data;
    logic   [VRF_RPORT_NUM-1:0][VSB_ENT_NUM-1:0]   rs_idx;
    logic   [VRF_RPORT_NUM-1:0][1:0]               rs_field_idx;
} prf_rdata_t;

endpackage 
