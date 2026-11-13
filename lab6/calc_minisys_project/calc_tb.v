`timescale 1ns / 1ps

module calc_tb;

    reg        clk;
    reg        rst;
    reg        rx_valid;
    reg  [7:0] rx_data;
    wire       tx_valid;
    wire [7:0] tx_data;
    wire [31:0] disp_buf;
    wire [7:0] disp_en;

    calc_fsm #(
        .CHAR_GAP(20'd10)
    ) u_calc_fsm (
        .clk     (clk),
        .rst     (rst),
        .rx_valid(rx_valid),
        .rx_data (rx_data),
        .tx_valid(tx_valid),
        .tx_data (tx_data),
        .disp_buf(disp_buf),
        .disp_en (disp_en)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task send_char;
        input [7:0] ch;
        begin
            @(negedge clk);
            rx_valid = 1'b1;
            rx_data  = ch;
            @(negedge clk);
            rx_valid = 1'b0;
            #30;
        end
    endtask

    initial begin
        rst      = 1'b1;
        rx_valid = 1'b0;
        rx_data  = 8'h00;
        #35;
        rst = 1'b0;
        #20;

        send_char("1");
        send_char("2");
        send_char("+");
        send_char("3");
        send_char("=");
        #1000;

        send_char("3");
        send_char("6");
        send_char("/");
        send_char("1");
        send_char("2");
        send_char("=");
        #1000;

        send_char("3");
        send_char("-");
        send_char("1");
        send_char("2");
        send_char("=");
        #1000;

        send_char("9");
        send_char("9");
        send_char("*");
        send_char("9");
        send_char("9");
        send_char("=");
        #1200;

        $finish;
    end

endmodule
