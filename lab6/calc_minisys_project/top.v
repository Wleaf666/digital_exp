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
    input  wire       sw0,
    input  wire       btn_s2,
    input  wire       uart_rx,
    output wire       uart_tx,
    output wire [7:0] led_en,
    output wire [7:0] led_cx
);

    wire        rx_valid;
    wire [7:0]  rx_data;

    wire        base_rx_valid;
    wire        base_s2_pulse;
    wire [23:0] rx_buf;
    wire [5:0]  rx_en_mask;

    wire        s2_clean;
    wire        s2_pulse;
    wire        base_tx_valid;
    wire [7:0]  base_tx_data;
    wire [3:0]  tx_cnt_tens;
    wire [3:0]  tx_cnt_ones;

    wire        calc_rx_valid;
    wire        calc_tx_valid;
    wire [7:0]  calc_tx_data;
    wire [31:0] calc_disp;
    wire [7:0]  calc_en;

    wire        tx_valid;
    wire [7:0]  tx_data;
    wire [31:0] display;
    wire [7:0]  digit_en;

    uart_recv u_uart_recv (
        .clk  (clk),
        .rst  (rst),
        .din  (uart_rx),
        .valid(rx_valid),
        .data (rx_data)
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

    mode_mux u_mode_mux (
        .sw0          (sw0),
        .rx_valid     (rx_valid),
        .s2_pulse     (s2_pulse),
        .base_tx_valid(base_tx_valid),
        .base_tx_data (base_tx_data),
        .base_disp    ({tx_cnt_tens, tx_cnt_ones, rx_buf}),
        .base_en      ({2'b11, rx_en_mask}),
        .calc_tx_valid(calc_tx_valid),
        .calc_tx_data (calc_tx_data),
        .calc_disp    (calc_disp),
        .calc_en      (calc_en),
        .base_rx_valid(base_rx_valid),
        .base_s2_pulse(base_s2_pulse),
        .calc_rx_valid(calc_rx_valid),
        .tx_valid     (tx_valid),
        .tx_data      (tx_data),
        .display      (display),
        .digit_en     (digit_en)
    );

    rx_ctrl u_rx_ctrl (
        .clk       (clk),
        .rst       (rst),
        .rx_valid  (base_rx_valid),
        .rx_data   (rx_data),
        .rx_buf    (rx_buf),
        .rx_en_mask(rx_en_mask)
    );

    tx_ctrl #(
        .GROUP_C0(GROUP_C0),
        .GROUP_C1(GROUP_C1),
        .CHAR_GAP(CHAR_GAP)
    ) u_tx_ctrl (
        .clk        (clk),
        .rst        (rst),
        .s2_pulse   (base_s2_pulse),
        .tx_valid   (base_tx_valid),
        .tx_data    (base_tx_data),
        .tx_cnt_tens(tx_cnt_tens),
        .tx_cnt_ones(tx_cnt_ones)
    );

    calc_fsm #(
        .CHAR_GAP(CHAR_GAP)
    ) u_calc_fsm (
        .clk     (clk),
        .rst     (rst),
        .rx_valid(calc_rx_valid),
        .rx_data (rx_data),
        .tx_valid(calc_tx_valid),
        .tx_data (calc_tx_data),
        .disp_buf(calc_disp),
        .disp_en (calc_en)
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
        .clk      (clk),
        .rst      (rst),
        .calc_mode(sw0),
        .display  (display),
        .digit_en (digit_en),
        .led_en   (led_en),
        .led_cx   (led_cx)
    );

endmodule
