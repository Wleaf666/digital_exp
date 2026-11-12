`timescale 1ns / 1ps

module tx_ctrl #(
    parameter GROUP_C0 = 8'h30,
    parameter GROUP_C1 = 8'h31,
    parameter CHAR_GAP = 20'd200_000
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       s2_pulse,
    output reg        tx_valid,
    output reg  [7:0] tx_data,
    output reg  [3:0] tx_cnt_tens,
    output reg  [3:0] tx_cnt_ones
);

    reg        sending;
    reg [3:0]  char_idx;
    reg [19:0] gap_cnt;

    always @(*) begin
        case (char_idx)
            4'd0:  tx_data = GROUP_C0;
            4'd1:  tx_data = GROUP_C1;
            4'd2:  tx_data = 8'h2B;
            4'd3:  tx_data = 8'h32;
            4'd4:  tx_data = 8'h30;
            4'd5:  tx_data = 8'h32;
            4'd6:  tx_data = 8'h35;
            4'd7:  tx_data = 8'h33;
            4'd8:  tx_data = 8'h31;
            4'd9:  tx_data = 8'h31;
            4'd10: tx_data = 8'h33;
            4'd11: tx_data = 8'h30;
            4'd12: tx_data = 8'h38;
            default: tx_data = 8'h00;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sending     <= 1'b0;
            char_idx    <= 4'd0;
            gap_cnt     <= 20'd0;
            tx_valid    <= 1'b0;
            tx_cnt_tens <= 4'd0;
            tx_cnt_ones <= 4'd0;
        end else begin
            tx_valid <= 1'b0;
            if (!sending) begin
                if (s2_pulse) begin
                    sending  <= 1'b1;
                    char_idx <= 4'd0;
                    gap_cnt  <= 20'd0;
                end
            end else begin
                if (gap_cnt == 20'd0) begin
                    tx_valid <= 1'b1;
                    gap_cnt  <= gap_cnt + 20'd1;
                    if (tx_cnt_ones == 4'd9) begin
                        tx_cnt_ones <= 4'd0;
                        tx_cnt_tens <= (tx_cnt_tens == 4'd9) ? 4'd0 : (tx_cnt_tens + 4'd1);
                    end else begin
                        tx_cnt_ones <= tx_cnt_ones + 4'd1;
                    end
                end else if (gap_cnt >= CHAR_GAP - 1'b1) begin
                    gap_cnt <= 20'd0;
                    if (char_idx == 4'd12) begin
                        sending  <= 1'b0;
                        char_idx <= 4'd0;
                    end else begin
                        char_idx <= char_idx + 4'd1;
                    end
                end else begin
                    gap_cnt <= gap_cnt + 20'd1;
                end
            end
        end
    end

endmodule
