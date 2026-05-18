`timescale 1ms/1us

module tb_traffic_light_top;

    logic        clk;
    logic        rstn;
    logic        traffic_B;

    logic        red_light_A,   amber_light_A,   green_light_A;
    logic        red_light_B,   amber_light_B,   green_light_B;
    logic [3:0]  sec_count;
    logic [3:0]  tenth_count;

    traffic_light_top dut (
        .clk           (clk),
        .rstn          (rstn),
        .traffic_B     (traffic_B),
        .red_light_A   (red_light_A),
        .amber_light_A (amber_light_A),
        .green_light_A (green_light_A),
        .red_light_B   (red_light_B),
        .amber_light_B (amber_light_B),
        .green_light_B (green_light_B),
        .sec_count     (sec_count),
        .tenth_count   (tenth_count)
    );

    initial clk = 0;
    always #50 clk = ~clk;

    task wait_cycles(input int n);
        repeat(n) @(posedge clk);
    endtask

    task check_lights(
        input string  label,
        input logic   exp_rA, exp_aA, exp_gA,
        input logic   exp_rB, exp_aB, exp_gB
    );
        @(posedge clk); #1;
        if ( red_light_A   !== exp_rA ||
             amber_light_A !== exp_aA ||
             green_light_A !== exp_gA ||
             red_light_B   !== exp_rB ||
             amber_light_B !== exp_aB ||
             green_light_B !== exp_gB )
        begin
            $display("FAIL [%0t ms] %s", $time, label);
            $display("      Road A  R=%b A=%b G=%b  (exp R=%b A=%b G=%b)",
                     red_light_A, amber_light_A, green_light_A, exp_rA, exp_aA, exp_gA);
            $display("      Road B  R=%b A=%b G=%b  (exp R=%b A=%b G=%b)",
                     red_light_B, amber_light_B, green_light_B, exp_rB, exp_aB, exp_gB);
        end
        else
            $display("PASS [%0t ms] %s", $time, label);
    endtask

    task wait_for_timer_done;
        wait_cycles(90);
    endtask

    initial begin
        $dumpfile("tb_traffic_light_top.vcd");
        $dumpvars(0, tb_traffic_light_top);

        rstn      = 1'b0;
        traffic_B = 1'b0;

        wait_cycles(3);
        rstn = 1'b1;
        wait_cycles(2);
        check_lights("T1: After reset (F0: green_A, red_B)",
                     0,0,1,  1,0,0);

        traffic_B = 1'b0;
        wait_cycles(5);
        check_lights("T2: No traffic_B, stays F0",
                     0,0,1,  1,0,0);

        traffic_B = 1'b1;
        wait_cycles(2);
        check_lights("T3: traffic_B=1, F1 (amber_A, red_B)",
                     0,1,0,  1,0,0);
        $display("     sec=%0d.%0d (timer running)", sec_count, tenth_count);

        wait_for_timer_done;
        check_lights("T4: Timer done, F2 (red_A, green_B)",
                     1,0,0,  0,0,1);

        traffic_B = 1'b0;
        wait_cycles(2);
        check_lights("T5: traffic_B=0, F3 (red_A, amber_B)",
                     1,0,0,  0,1,0);
        $display("     sec=%0d.%0d (timer running)", sec_count, tenth_count);

        wait_for_timer_done;
        check_lights("T6: Timer done, F0 (green_A, red_B)",
                     0,0,1,  1,0,0);

        traffic_B = 1'b1;
        wait_cycles(2);
        check_lights("T7: Second cycle F1 (amber_A, red_B)",
                     0,1,0,  1,0,0);

        wait_cycles(10);
        $display("---- Simulation complete ----");
        $finish;
    end

    initial begin
        #30000;
        $display("TIMEOUT: simulation exceeded 30 s");
        $finish;
    end

    initial begin
        $monitor("[%0t ms] rA=%b aA=%b gA=%b | rB=%b aB=%b gB=%b | sec=%0d.%0d",
                 $time,
                 red_light_A, amber_light_A, green_light_A,
                 red_light_B, amber_light_B, green_light_B,
                 sec_count, tenth_count);
    end

endmodule
