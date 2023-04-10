`timescale 1ns/1ps

module clk_gen(
    input  [2:0]    speed       ,
    input           gtx_clk     , //used only in GMII mode
    output reg      rx_clk      ,
    output reg      tx_clk      , //used only in MII mode
    output reg      clk_125M    ,
    output reg      clk_reg     ,
    output reg      clk_user    
);

reg clk_2_5M;
reg clk_25M;

always begin
    #200 clk_2_5M = 0;
    #200 clk_2_5M = 1;
end

always begin
    #20 clk_25M = 0;
    #20 clk_25M = 1;
end

always begin
    #4 clk_125M = 0;
    #4 clk_125M = 1;
end

always begin // 100M
    #5 clk_user = 0;
    #5 clk_user = 1;
end

always begin // 50M
    #10 clk_reg = 0;
    #10 clk_reg = 1;
end

assign tx_clk = speed[2] ? gtx_clk : speed[1] ? clk_25M : speed[0] ? clk_2_5M : 0;
assign rx_clk = speed[2] ? gtx_clk : speed[1] ? clk_25M : speed[0] ? clk_2_5M : 0;

endmodule
