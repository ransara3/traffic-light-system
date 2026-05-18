
module traffic_light_top
(
    input  logic clk,
    input  logic rstn,
    input  logic traffic_B,

    output logic red_light_A,
    output logic amber_light_A,
    output logic green_light_A,

    output logic red_light_B,
    output logic amber_light_B,
    output logic green_light_B,

    output logic [3:0] sec_count,
    output logic [3:0] tenth_count
);

    
    logic amber_timer_en;   
    logic timer_done;       

    
    traffic_light_system u_traffic_light_system (
        .clk            (clk),
        .rstn           (rstn),
        .traffic_B      (traffic_B),
        .timer_done     (timer_done),
        .red_light_A    (red_light_A),
        .amber_light_A  (amber_light_A),
        .green_light_A  (green_light_A),
        .red_light_B    (red_light_B),
        .amber_light_B  (amber_light_B),
        .green_light_B  (green_light_B),
        .amber_timer_en (amber_timer_en)
    );

   
    down_counter_timer u_down_counter_timer (
        .clk            (clk),
        .amber_timer_en (amber_timer_en),
        .sec_count      (sec_count),
        .tenth_count    (tenth_count),
        .timer_done     (timer_done)
    );

endmodule
