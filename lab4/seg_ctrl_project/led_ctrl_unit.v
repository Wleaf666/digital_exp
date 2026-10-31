`timescale 1ns / 1ps

module led_ctrl_unit #(
    parameter SCAN_CNT_MAX = 32'd100_000
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] display,
    output reg  [7:0]  led_en,
    output reg  [7:0]  led_cx,
    output reg  [7:0]  led_cx1
);

    reg [31:0] scan_cnt;
    reg [2:0]  scan_sel;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_cnt <= 32'd0;
            scan_sel <= 3'd0;
        end else if (scan_cnt >= SCAN_CNT_MAX - 32'd1) begin
            scan_cnt <= 32'd0;
            scan_sel <= scan_sel + 3'd1;
        end else begin
            scan_cnt <= scan_cnt + 32'd1;
        end
    end

    reg [3:0] cur_hex;

    always @(*) begin
        case (scan_sel)
            3'd0: cur_hex = display[31:28];
            3'd1: cur_hex = display[27:24];
            3'd2: cur_hex = display[23:20];
            3'd3: cur_hex = display[19:16];
            3'd4: cur_hex = display[15:12];
            3'd5: cur_hex = display[11:8];
            3'd6: cur_hex = display[7:4];
            3'd7: cur_hex = display[3:0];
            default: cur_hex = 4'd0;
        endcase
    end

    always @(*) begin
        case (scan_sel)
            3'd0: led_en = 8'b1000_0000;
            3'd1: led_en = 8'b0100_0000;
            3'd2: led_en = 8'b0010_0000;
            3'd3: led_en = 8'b0001_0000;
            3'd4: led_en = 8'b0000_1000;
            3'd5: led_en = 8'b0000_0100;
            3'd6: led_en = 8'b0000_0010;
            3'd7: led_en = 8'b0000_0001;
            default: led_en = 8'b0000_0000;
        endcase
    end

    reg [7:0] seg_data;

    always @(*) begin
        case (cur_hex)
            4'h0: seg_data = 8'b1111_1100;
            4'h1: seg_data = 8'b0110_0000;
            4'h2: seg_data = 8'b1101_1010;
            4'h3: seg_data = 8'b1111_0010;
            4'h4: seg_data = 8'b0110_0110;
            4'h5: seg_data = 8'b1011_0110;
            4'h6: seg_data = 8'b1011_1110;
            4'h7: seg_data = 8'b1110_0000;
            4'h8: seg_data = 8'b1111_1110;
            4'h9: seg_data = 8'b1111_0110;
            4'hA: seg_data = 8'b1110_1110;
            4'hB: seg_data = 8'b0011_1110;
            4'hC: seg_data = 8'b1001_1100;
            4'hD: seg_data = 8'b0111_1010;
            4'hE: seg_data = 8'b1001_1110;
            4'hF: seg_data = 8'b1000_1110;
            default: seg_data = 8'b0000_0000;
        endcase
    end

    always @(*) begin
        led_cx  = seg_data;
        led_cx1 = seg_data;
    end

endmodule
