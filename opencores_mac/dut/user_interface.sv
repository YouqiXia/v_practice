module user_interface(
    input		    	reset					,
    input		    	clk_user				,
    input               cpu_init_end            ,
                        //user inputerface 
    input		    	rx_mac_ra				,
    output reg          rx_mac_rd				,
    input	    [31:0]	rx_mac_data				,
    input	    [1:0]	rx_mac_be				,
    input		    	rx_mac_pa				,
    input		    	rx_mac_sop				,
    input		    	rx_mac_eop				,
                        //user inputerface 
    input		    	tx_mac_wa	        	,
    output reg          tx_mac_wr	        	,
    output reg	[31:0]	tx_mac_data	        	,
    output reg  [1:0]	tx_mac_be				,//big endian
    output reg  		tx_mac_sop	        	,
    output reg  		tx_mac_eop				
);

parameter RX_BUF_WIDTH = 1024;

// rx signal
logic end_display;
logic rx_ctrl_en;
logic [RX_BUF_WIDTH-1:0] rx_buff;
// tx signal
logic tx_ctrl_en;
logic [2048-1:0]    user_packet_stream;
logic [2048/8-1:0]  user_packet_size;
logic [63:0]        tx_mac_ptr;

initial begin
    rx_ctrl_en  = 0;
    tx_ctrl_en  = 0;
end

task rx_ctrl;
    @(posedge clk_user);
    rx_ctrl_en = 1;

    @(posedge clk_user);
    rx_ctrl_en = 0;

endtask

task tx_ctrl(
    input [2048-1:0]    packet_stream,
    input [63:0]        packet_size
);
    @(posedge clk_user);
    tx_ctrl_en = 1;
    user_packet_stream  = packet_stream;
    user_packet_size    = packet_size;    
    tx_mac_ptr          = 0;

    @(posedge clk_user);
    tx_ctrl_en = 0;

endtask

// rx mac rd switch
always @(posedge clk_user) begin
    if (reset) begin
        rx_mac_rd <= 0;
    end else if (end_display) begin
        rx_mac_rd <= 0;
    end if (rx_ctrl_en) begin
        rx_mac_rd <= 1;
    end
end

// rx FSM
typedef enum logic [1:0] {
    RX_IDLE,
    RX_WORK
} rx_state_t;

rx_state_t rx_state, rx_next_state;

always @(posedge clk_user) begin
    if (reset) begin
        rx_state <= RX_IDLE;
    end else begin
        rx_state <= rx_next_state;
    end
end

always_comb begin
    rx_next_state = rx_state;
    end_display   = 0;
    case (rx_state)
        RX_IDLE: begin
            if (rx_mac_pa & rx_mac_sop) begin
                rx_next_state = RX_WORK;
            end
        end
        RX_WORK: begin
            if (rx_mac_pa & rx_mac_eop) begin
                rx_next_state = RX_IDLE;
                end_display   = 1;
            end
        end
        default: rx_next_state = RX_IDLE;
    endcase
end

always @(posedge clk_user) begin
    if (rx_state == RX_IDLE) begin
        rx_buff <= 0;
    end if (rx_mac_pa & ((rx_state == RX_WORK) | (rx_next_state == RX_WORK))) begin
        rx_buff <= {rx_buff[RX_BUF_WIDTH-1-32:0], rx_mac_data};
    end
end

always @(posedge clk_user) begin
    if (end_display) begin
        @(posedge clk_user);
        $display("rx_buff = %x", rx_buff);
    end
end

// tx FSM
typedef enum logic [1:0] {
    TX_IDLE,
    TX_WORK
} tx_state_t;

tx_state_t tx_state, tx_next_state;

always @(posedge clk_user) begin
    if (reset) begin
        tx_state <= TX_IDLE;
    end else begin
        tx_state <= tx_next_state;
    end
end

always_comb begin
    tx_next_state = tx_state;
    case (tx_state)
        TX_IDLE: begin
            if (tx_ctrl_en) begin
                tx_next_state = TX_WORK;
            end
        end
        TX_WORK: begin
            if (tx_mac_eop & tx_mac_wr & tx_mac_wa) begin
                tx_next_state = TX_IDLE;
            end
        end
        default: tx_next_state = TX_IDLE;
    endcase
end
 
always @(posedge clk_user) begin
    if (reset) begin
        tx_mac_ptr      <= 0;
    end if (tx_mac_wa & tx_mac_wr) begin
        tx_mac_ptr      <= tx_mac_ptr + 4;
    end
end

always_comb begin
    if (tx_state == TX_IDLE) begin
        tx_mac_wr	    = 0;
        tx_mac_data	    = 0;
        tx_mac_be	    = 0;
        tx_mac_sop	    = 0;
        tx_mac_eop	    = 0;
    end else if (tx_state == TX_WORK) begin
        tx_mac_wr       = 1;
        tx_mac_data	    = user_packet_stream[((user_packet_size-tx_mac_ptr)*8-1)-:32];
        tx_mac_be	    = (tx_mac_ptr == user_packet_size - 4) ? 1 : 0;
        tx_mac_sop	    = (tx_mac_ptr == 0) ? 1 : 0;
        tx_mac_eop	    = (tx_mac_ptr == user_packet_size - 4) ? 1 : 0;
    end
end



endmodule