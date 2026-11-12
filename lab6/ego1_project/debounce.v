`timescale 1ns / 1ps

module debounce #(
    parameter CNT_MAX = 32'd1_000_000
)(
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output wire btn_out
);

    reg btn_r0;
    reg btn_r1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_r0 <= 1'b0;
            btn_r1 <= 1'b0;
        end else begin
            btn_r0 <= btn_in;
            btn_r1 <= btn_r0;
        end
    end

    reg [31:0] cnt;
    reg        btn_prev;
    reg        btn_clean;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt       <= 32'd0;
            btn_prev  <= 1'b0;
            btn_clean <= 1'b0;
        end else begin
            if (btn_r1 != btn_prev) begin

                btn_prev <= btn_r1;
                cnt      <= 32'd0;
            end else if (cnt < CNT_MAX) begin

                cnt <= cnt + 32'd1;
            end else begin

                btn_clean <= btn_prev;
            end
        end
    end

    assign btn_out = btn_clean;

endmodule
