module traffic_light_system(
	input logic clk,
	input logic rstn,
	
	input logic traffic_B,
	input logic timer_done,
	
	output logic red_light_A,
	output logic amber_light_A,
	output logic green_light_A,
	
	output logic red_light_B,
	output logic amber_light_B,
	output logic green_light_B,
	
	output logic amber_timer_en

);

enum logic [1:0] {
	F0,
	F1,
	F2,
	F3
} state,next_state;

always_comb begin
	next_state = state;
	
	red_light_A = 0;
   amber_light_A = 0;
   green_light_A = 0;

   red_light_B = 0;
   amber_light_B = 0;
   green_light_B = 0;

    amber_timer_en = 0;
	if (state == F0) begin
		if (traffic_B == 0) begin
			next_state = F0;
			red_light_A = 0;
			amber_light_A = 0;
			green_light_A = 1;
			red_light_B = 1;
			amber_light_B = 0;
			green_light_B = 0;
			amber_timer_en = 0;
		end
			
		else if (traffic_B == 1) begin
			next_state = F1;
			red_light_A = 0;
			amber_light_A = 1;
			green_light_A = 0;
			red_light_B = 1;
			amber_light_B = 0;
			green_light_B = 0;
			amber_timer_en = 1;
		end
	end
	
	else if (state == F1) begin
		if (timer_done == 0 ) begin
			next_state = F1;
			red_light_A = 0;
			amber_light_A = 1;
			green_light_A = 0;
			red_light_B = 1;
			amber_light_B = 0;
			green_light_B = 0;
			amber_timer_en = 1;
		end
			
		else if (timer_done == 1) begin
			next_state = F2;
			red_light_A = 1;
			amber_light_A = 0;
			green_light_A = 0;
			red_light_B = 0;
			amber_light_B = 0;
			green_light_B = 1;
			amber_timer_en = 0;
		end
	end
	
	else if (state == F2) begin
		if (traffic_B == 1) begin
			next_state = F2;
			red_light_A = 1;
			amber_light_A = 0;
			green_light_A = 0;
			red_light_B = 0;
			amber_light_B = 0;
			green_light_B = 1;
			amber_timer_en = 0;
		end
			
		else if (traffic_B == 0) begin
			next_state = F3;
			red_light_A = 1;
			amber_light_A = 0;
			green_light_A = 0;
			red_light_B = 0;
			amber_light_B = 1;
			green_light_B = 0;
			amber_timer_en = 1;
		end
	end
	
	else if (state == F3) begin
		if (timer_done == 0 ) begin
			next_state = F3;
			red_light_A = 1;
			amber_light_A = 0;
			green_light_A = 0;
			red_light_B = 0;
			amber_light_B = 1;
			green_light_B = 0;
			amber_timer_en = 1;
		end
			
		else if (timer_done == 1 ) begin
			next_state = F0;
			red_light_A = 0;
			amber_light_A = 0;
			green_light_A = 1;
			red_light_B = 1;
			amber_light_B = 0;
			green_light_B = 0;
			amber_timer_en = 0;
		end
	end
end
			

always_ff @(posedge clk) begin
	if (rstn == 0) begin
		state <= F0;
	end
	else begin
		state <= next_state;
	end
end

endmodule


