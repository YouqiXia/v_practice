package template_pkg;

parameter CNT_WIDTH = 3;
parameter CNT_END = 5;
parameter PORT_NUM = 2;

typedef struct {
    logic [PORT_NUM-1:0]            vld;
    logic [PORT_NUM-1:0][63:0]      addr;
} info_t;

endpackage