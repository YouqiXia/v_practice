module regfile_bank #(
    parameter ROW       = 16;
    parameter ROW_WIDTH = $clog2(ROW);
    parameter WIDTH     = 256;
)(
    input   logic [ROW_WIDTH-1:0]   raddr1,
    input   logic [ROW_WIDTH-1:0]   raddr2,
    input   logic                   wen,
    input   logic [ROW_WIDTH-1:0]   waddr,
    input   logic [WIDTH-1:0]       wdata,
    output  logic [WIDTH-1:0]       rdata1,
    output  logic [WIDTH-1:0]       rdata2
);

reg [WIDTH-1:0] regfile[ROW-1:0];

always@(posedge clk) begin
    if (wen) begin
        regfile[waddr] = wdata;
    end
end

assign rdata1 = regfile[raddr1];
assign rdata2 = regfile[raddr2];

endmodule