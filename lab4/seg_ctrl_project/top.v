`timescale 1ns / 1ps

module top #(
    parameter SCAN_CNT_MAX     = 32'd100_000,
    parameter DEBOUNCE_CNT_MAX = 32'd1_000_000,
    parameter TIMER_0_1S_MAX   = 32'd10_000_000
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       sw0,
    input  wire       btn_s2,
    input  wire       btn_s3,
    output wire [7:0] led_en,
    output wire [7:0] led_cx,
    output wire [7:0] led_cx1
);

    wire s3_raw_pulse;

    edge_detect u_edge_s3_raw (
        .clk      (clk),
        .rst      (rst),
        .signal   (btn_s3),
        .pos_edge (s3_raw_pulse)
    );

    reg [3:0] cnt_raw_tens;
    reg [3:0] cnt_raw_units;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_raw_tens  <= 4'd0;
            cnt_raw_units <= 4'd0;
        end else if (s3_raw_pulse) begin
            if (cnt_raw_units == 4'd9) begin
                cnt_raw_units <= 4'd0;
                if (cnt_raw_tens == 4'd9) begin
                    cnt_raw_tens <= 4'd0;
                end else begin
                    cnt_raw_tens <= cnt_raw_tens + 4'd1;
                end
            end else begin
                cnt_raw_units <= cnt_raw_units + 4'd1;
            end
        end
    end

    wire s3_clean;
    wire s3_deb_pulse;

    debounce #(
        .CNT_MAX (DEBOUNCE_CNT_MAX)
    ) u_debounce_s3 (
        .clk     (clk),
        .rst     (rst),
        .btn_in  (btn_s3),
        .btn_out (s3_clean)
    );

    edge_detect u_edge_s3_deb (
        .clk      (clk),
        .rst      (rst),
        .signal   (s3_clean),
        .pos_edge (s3_deb_pulse)
    );

    reg [3:0] cnt_deb_tens;
    reg [3:0] cnt_deb_units;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_deb_tens  <= 4'd0;
            cnt_deb_units <= 4'd0;
        end else if (s3_deb_pulse) begin
            if (cnt_deb_units == 4'd9) begin
                cnt_deb_units <= 4'd0;
                if (cnt_deb_tens == 4'd9) begin
                    cnt_deb_tens <= 4'd0;
                end else begin
                    cnt_deb_tens <= cnt_deb_tens + 4'd1;
                end
            end else begin
                cnt_deb_units <= cnt_deb_units + 4'd1;
            end
        end
    end

    wire s2_clean;
    wire s2_pulse;

    debounce #(
        .CNT_MAX (DEBOUNCE_CNT_MAX)
    ) u_debounce_s2 (
        .clk     (clk),
        .rst     (rst),
        .btn_in  (btn_s2),
        .btn_out (s2_clean)
    );

    edge_detect u_edge_s2 (
        .clk      (clk),
        .rst      (rst),
        .signal   (s2_clean),
        .pos_edge (s2_pulse)
    );

    reg run_flag;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            run_flag <= 1'b1;
        end else if (s2_pulse) begin
            run_flag <= ~run_flag;
        end
    end

    reg [31:0] timer_0_1s_cnt;
    reg        timer_0_1s_tick;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_0_1s_cnt  <= 32'd0;
            timer_0_1s_tick <= 1'b0;
        end else if (run_flag) begin
            if (timer_0_1s_cnt >= TIMER_0_1S_MAX - 32'd1) begin
                timer_0_1s_cnt  <= 32'd0;
                timer_0_1s_tick <= 1'b1;
            end else begin
                timer_0_1s_cnt  <= timer_0_1s_cnt + 32'd1;
                timer_0_1s_tick <= 1'b0;
            end
        end else begin
            timer_0_1s_tick <= 1'b0;
        end
    end

    reg [3:0] cnt_20_tens;
    reg [3:0] cnt_20_units;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_20_tens  <= 4'd0;
            cnt_20_units <= 4'd0;
        end else if (timer_0_1s_tick) begin
            if (cnt_20_tens == 4'd2 && cnt_20_units == 4'd0) begin
                cnt_20_tens  <= 4'd0;
                cnt_20_units <= 4'd0;
            end else if (cnt_20_units == 4'd9) begin
                cnt_20_units <= 4'd0;
                cnt_20_tens  <= cnt_20_tens + 4'd1;
            end else begin
                cnt_20_units <= cnt_20_units + 4'd1;
            end
        end
    end

    wire [31:0] display_mode_2_1 = 32'h2531_1308;
    wire [31:0] display_mode_2_2 = {
        8'h08,
        cnt_raw_tens,
        cnt_raw_units,
        cnt_deb_tens,
        cnt_deb_units,
        cnt_20_tens,
        cnt_20_units
    };

    wire [31:0] display_data = (sw0 == 1'b1) ? display_mode_2_1 : display_mode_2_2;

    led_ctrl_unit #(
        .SCAN_CNT_MAX (SCAN_CNT_MAX)
    ) u_led_ctrl_unit (
        .clk     (clk),
        .rst     (rst),
        .display (display_data),
        .led_en  (led_en),
        .led_cx  (led_cx),
        .led_cx1 (led_cx1)
    );

endmodule
