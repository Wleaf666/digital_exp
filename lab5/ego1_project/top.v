`timescale 1ns / 1ps

module top (
    input  wire clk,
    input  wire rst,
    output wire uart_tx
);

    localparam CHAR_GAP = 26'd200_000;
    localparam STR_GAP  = 26'd25_000_000;

    reg [25:0] timer_cnt;
    reg [3:0]  char_idx;
    reg        valid;
    reg [7:0]  data;

    wire [25:0] current_gap = (char_idx == 4'd14) ? STR_GAP : CHAR_GAP;

    always @(*) begin
        case (char_idx)
            4'd0:  data = 8'h68;
            4'd1:  data = 8'h69;
            4'd2:  data = 8'h74;
            4'd3:  data = 8'h73;
            4'd4:  data = 8'h7A;
            4'd5:  data = 8'h32;
            4'd6:  data = 8'h30;
            4'd7:  data = 8'h32;
            4'd8:  data = 8'h35;
            4'd9:  data = 8'h33;
            4'd10: data = 8'h31;
            4'd11: data = 8'h31;
            4'd12: data = 8'h33;
            4'd13: data = 8'h30;
            4'd14: data = 8'h38;
            default: data = 8'h00;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_cnt <= 26'd0;
            char_idx  <= 4'd0;
            valid     <= 1'b0;
        end else begin
            if (timer_cnt == 26'd0) begin
                valid     <= 1'b1;
                timer_cnt <= timer_cnt + 26'd1;
            end else if (timer_cnt == current_gap - 1'b1) begin
                valid     <= 1'b0;
                timer_cnt <= 26'd0;
                if (char_idx == 4'd14) begin
                    char_idx <= 4'd0;
                end else begin
                    char_idx <= char_idx + 4'd1;
                end
            end else begin
                valid     <= 1'b0;
                timer_cnt <= timer_cnt + 26'd1;
            end
        end
    end

    uart_send u_uart_send (
        .clk  (clk),
        .rst  (rst),
        .valid(valid),
        .data (data),
        .dout (uart_tx)
    );

endmodule
