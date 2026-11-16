`timescale 1ns / 1ps

module top #(
    parameter SCAN_CNT_MAX     = 32'd100_000,
    parameter DEBOUNCE_CNT_MAX = 32'd1_000_000,
    parameter CHAR_GAP         = 20'd200_000,
    parameter GROUP_C0         = 8'h30,
    parameter GROUP_C1         = 8'h33
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       btn_s2,
    input  wire       uart_rx,
    output wire       uart_tx,
    output wire [7:0] led_en,
    output wire [7:0] led_cx
);

    wire        rx_valid;
    wire [7:0]  rx_data;
    wire [23:0] rx_buf;
    wire [5:0]  rx_en_mask;

    wire        s2_clean;
    wire        s2_pulse;
    wire        tx_valid;
    wire [7:0]  tx_data;
    wire [3:0]  tx_cnt_tens;
    wire [3:0]  tx_cnt_ones;

    uart_recv u_uart_recv (
        .clk  (clk),
        .rst  (rst),
        .din  (uart_rx),
        .valid(rx_valid),
        .data (rx_data)
    );

    rx_ctrl u_rx_ctrl (
        .clk       (clk),
        .rst       (rst),
        .rx_valid  (rx_valid),
        .rx_data   (rx_data),
        .rx_buf    (rx_buf),
        .rx_en_mask(rx_en_mask)
    );

    debounce #(
        .CNT_MAX(DEBOUNCE_CNT_MAX)
    ) u_debounce_s2 (
        .clk    (clk),
        .rst    (rst),
        .btn_in (btn_s2),
        .btn_out(s2_clean)
    );

    edge_detect u_edge_s2 (
        .clk     (clk),
        .rst     (rst),
        .signal  (s2_clean),
        .pos_edge(s2_pulse)
    );

    tx_ctrl #(
        .GROUP_C0(GROUP_C0),
        .GROUP_C1(GROUP_C1),
        .CHAR_GAP(CHAR_GAP)
    ) u_tx_ctrl (
        .clk        (clk),
        .rst        (rst),
        .s2_pulse   (s2_pulse),
        .tx_valid   (tx_valid),
        .tx_data    (tx_data),
        .tx_cnt_tens(tx_cnt_tens),
        .tx_cnt_ones(tx_cnt_ones)
    );

    uart_send u_uart_send (
        .clk  (clk),
        .rst  (rst),
        .valid(tx_valid),
        .data (tx_data),
        .dout (uart_tx)
    );

    led_ctrl_unit #(
        .SCAN_CNT_MAX(SCAN_CNT_MAX)
    ) u_led_ctrl_unit (
        .clk     (clk),
        .rst     (rst),
        .display ({tx_cnt_tens, tx_cnt_ones, rx_buf}),
        .digit_en({2'b11, rx_en_mask}),
        .led_en  (led_en),
        .led_cx  (led_cx)
    );

endmodule
