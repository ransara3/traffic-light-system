module down_counter #(parameter N)
(
    input  logic clk,
    input  logic rstn,
    input  logic en_in,

    output logic en_out,
    output logic [$clog2(N)-1:0] count
);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        count  <= N - 1;
        en_out <= 1'b0;
    end
    else if (en_in) begin
        if (count == 0) begin
            count  <= N - 1;
            en_out <= 1'b1;
        end
        else begin
            count  <= count - 1'b1;
            en_out <= 1'b0;
        end
    end
    else begin
        en_out <= 1'b0;
    end
end

endmodule
