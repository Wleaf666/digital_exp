`timescale 1ns / 1ps

module led_ctrl_unit #(
    parameter SCAN_CNT_MAX = 32'd100_000
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        calc_mode,
    input  wire [31:0] display,
    input  wire [7:0]  digit_en,
    output reg  [7:0]  led_en,
    output reg  [7:0]  led_cx
);

    reg [31:0] scan_cnt;
    reg [2:0]  scan_sel;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_cnt <= 32'd0;
        end else if (scan_cnt >= SCAN_CNT_MAX - 32'd1) begin
            scan_cnt <= 32'd0;
        end else begin
            scan_cnt <= scan_cnt + 32'd1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_sel <= 3'd0;
        end else if (scan_cnt >= SCAN_CNT_MAX - 32'd1) begin
            scan_sel <= scan_sel + 3'd1;
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

    reg cur_en;
    always @(*) begin
        case (scan_sel)
            3'd0: cur_en = digit_en[7];
            3'd1: cur_en = digit_en[6];
            3'd2: cur_en = digit_en[5];
            3'd3: cur_en = digit_en[4];
            3'd4: cur_en = digit_en[3];
            3'd5: cur_en = digit_en[2];
            3'd6: cur_en = digit_en[1];
            3'd7: cur_en = digit_en[0];
            default: cur_en = 1'b0;
        endcase
    end

    always @(*) begin
        if (!cur_en) begin
            led_en = 8'b1111_1111;
        end else begin
            case (scan_sel)
                3'd0: led_en = 8'b0111_1111;
                3'd1: led_en = 8'b1011_1111;
                3'd2: led_en = 8'b1101_1111;
                3'd3: led_en = 8'b1110_1111;
                3'd4: led_en = 8'b1111_0111;
                3'd5: led_en = 8'b1111_1011;
                3'd6: led_en = 8'b1111_1101;
                3'd7: led_en = 8'b1111_1110;
                default: led_en = 8'b1111_1111;
            endcase
        end
    end

    always @(*) begin
        if (!cur_en) begin
            led_cx = 8'hFF;
        end else begin
            case (cur_hex)
                4'h0: led_cx = 8'h03;
                4'h1: led_cx = 8'h9F;
                4'h2: led_cx = 8'h25;
                4'h3: led_cx = 8'h0D;
                4'h4: led_cx = 8'h99;
                4'h5: led_cx = 8'h49;
                4'h6: led_cx = 8'h41;
                4'h7: led_cx = 8'h1F;
                4'h8: led_cx = 8'h01;
                4'h9: led_cx = 8'h09;
                4'hA: led_cx = calc_mode ? 8'hFD : 8'h11;
                4'hB: led_cx = 8'hC1;
                4'hC: led_cx = 8'h63;
                4'hD: led_cx = 8'h85;
                4'hE: led_cx = 8'h61;
                4'hF: led_cx = 8'h71;
                default: led_cx = 8'hFF;
            endcase
        end
    end

endmodule
