`timescale 1ns / 1ps

module mode_mux (
    input  wire        sw0,
    input  wire        rx_valid,
    input  wire        s2_pulse,
    input  wire        base_tx_valid,
    input  wire [7:0]  base_tx_data,
    input  wire [31:0] base_disp,
    input  wire [7:0]  base_en,
    input  wire        calc_tx_valid,
    input  wire [7:0]  calc_tx_data,
    input  wire [31:0] calc_disp,
    input  wire [7:0]  calc_en,
    output wire        base_rx_valid,
    output wire        base_s2_pulse,
    output wire        calc_rx_valid,
    output wire        tx_valid,
    output wire [7:0]  tx_data,
    output wire [31:0] display,
    output wire [7:0]  digit_en
);

    assign base_rx_valid = (!sw0) ? rx_valid : 1'b0;
    assign base_s2_pulse = (!sw0) ? s2_pulse : 1'b0;
    assign calc_rx_valid = sw0    ? rx_valid : 1'b0;

    assign tx_valid = sw0 ? calc_tx_valid : base_tx_valid;
    assign tx_data  = sw0 ? calc_tx_data  : base_tx_data;
    assign display  = sw0 ? calc_disp     : base_disp;
    assign digit_en = sw0 ? calc_en       : base_en;

endmodule
