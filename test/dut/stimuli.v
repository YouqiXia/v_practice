module tx_trans;
    reg [TX_WIDTH-1:0] times;

    initial begin
        $display("tx init");
    end

    task init_tx;
        times = 0;
    endtask

    function tx_action;
        times = times + 1;
        $display("tx %d: tx successfully", times);
    endfunction

endmodule
