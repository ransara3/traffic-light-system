
module down_counter_timer
(
    input  logic       clk,
    input  logic       amber_timer_en,

    output logic [3:0] sec_count,     
    output logic [3:0] tenth_count,   
    output logic       timer_done
);


    logic phase_1_active;      

    logic [2:0] tenth_p0_raw;  
    logic [3:0] tenth_p1_raw;  
    logic       tenth_p0_done; 
    logic [2:0] sec_raw;       

    
    always_ff @(posedge clk or negedge amber_timer_en) begin
        if (!amber_timer_en)
            phase_1_active <= 1'b0;
        else if (tenth_p0_done)      
            phase_1_active <= 1'b1;
    end

   
    down_counter #(.N(6)) cnt_tenth_p0
    (
        .clk    (clk),
        .rstn   (amber_timer_en),
        .en_in  (amber_timer_en && !phase_1_active),  
        .en_out (tenth_p0_done),
        .count  (tenth_p0_raw)
    );

 
    down_counter #(.N(10)) cnt_tenth_p1
    (
        .clk    (clk),
        .rstn   (amber_timer_en),
        .en_in  (amber_timer_en && phase_1_active),   
        .en_out (sec_tick),
        .count  (tenth_p1_raw)
    );

   
    down_counter #(.N(8)) cnt_sec
    (
        .clk    (clk),
        .rstn   (amber_timer_en),
        .en_in  (sec_tick),
        .en_out (timer_done),
        .count  (sec_raw)
    );


    assign sec_count   = {1'b0, sec_raw};
    assign tenth_count = phase_1_active ? tenth_p1_raw : {1'b0, tenth_p0_raw};

endmodule
