`timescale 1ns / 1ps

module testbench;

    reg clk;
    reg rst;
    reg sw0;
    reg btn_s2;
    reg btn_s3;

    wire [7:0] led_en;
    wire [7:0] led_cx;
    wire [7:0] led_cx1;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    top #(
        .SCAN_CNT_MAX    (32'd10),
        .DEBOUNCE_CNT_MAX(32'd5),
        .TIMER_0_1S_MAX  (32'd10)
    ) u_dut (
        .clk    (clk),
        .rst    (rst),
        .sw0    (sw0),
        .btn_s2 (btn_s2),
        .btn_s3 (btn_s3),
        .led_en (led_en),
        .led_cx (led_cx),
        .led_cx1(led_cx1)
    );

    wire [31:0] display_data = u_dut.display_data;
    wire [7:0]  cnt_raw = {u_dut.cnt_raw_tens, u_dut.cnt_raw_units};
    wire [7:0]  cnt_deb = {u_dut.cnt_deb_tens, u_dut.cnt_deb_units};
    wire [7:0]  cnt_20  = {u_dut.cnt_20_tens, u_dut.cnt_20_units};

    wire sig_r0   = u_dut.u_edge_s3_raw.sig_r0;
    wire sig_r1   = u_dut.u_edge_s3_raw.sig_r1;
    wire pos_edge = u_dut.u_edge_s3_raw.pos_edge;

    initial begin
        rst    = 1'b1;
        sw0    = 1'b1;
        btn_s2 = 1'b0;
        btn_s3 = 1'b0;

        #25;
        rst = 1'b0;

        #820;

        sw0 = 1'b0;
        #50;

        btn_s3 = 1'b1; #10;
        btn_s3 = 1'b0; #10;
        btn_s3 = 1'b1; #15;
        btn_s3 = 1'b0; #10;
        btn_s3 = 1'b1; #120;
        btn_s3 = 1'b0; #10;
        btn_s3 = 1'b1; #10;
        btn_s3 = 1'b0; #100;

        btn_s3 = 1'b1; #10;
        btn_s3 = 1'b0; #15;
        btn_s3 = 1'b1; #10;
        btn_s3 = 1'b0; #10;
        btn_s3 = 1'b1; #120;
        btn_s3 = 1'b0; #10;
        btn_s3 = 1'b1; #10;
        btn_s3 = 1'b0; #100;

        #50;
        btn_s2 = 1'b1; #80;
        btn_s2 = 1'b0; #100;

        btn_s2 = 1'b1; #80;
        btn_s2 = 1'b0; #100;

        #100;
        $finish;
    end

endmodule
