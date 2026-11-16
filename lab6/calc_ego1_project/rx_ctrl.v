`timescale 1ns / 1ps

module rx_ctrl (
    input  wire        clk,
    input  wire        rst,
    input  wire        rx_valid,
    input  wire [7:0]  rx_data,
    output reg  [23:0] rx_buf,
    output reg  [5:0]  rx_en_mask
);

    reg [3:0] hex_val;
    reg       is_valid_hex;
    reg [2:0] rx_count;

    always @(*) begin
        if (rx_data >= 8'h30 && rx_data <= 8'h39) begin
            hex_val      = rx_data[3:0];
            is_valid_hex = 1'b1;
        end else if (rx_data >= 8'h41 && rx_data <= 8'h46) begin
            hex_val      = rx_data[3:0] + 4'd9;
            is_valid_hex = 1'b1;
        end else if (rx_data >= 8'h61 && rx_data <= 8'h66) begin
            hex_val      = rx_data[3:0] + 4'd9;
            is_valid_hex = 1'b1;
        end else begin
            hex_val      = 4'h0;
            is_valid_hex = 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_buf   <= 24'h000000;
        end else if (rx_valid && is_valid_hex) begin
            rx_buf <= {rx_buf[19:0], hex_val};
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_count <= 3'd0;
        end else if (rx_valid && is_valid_hex) begin
            if (rx_count < 3'd6) begin
                rx_count <= rx_count + 3'd1;
            end
        end
    end

    always @(*) begin
        case (rx_count)
            3'd0: rx_en_mask = 6'b000000;
            3'd1: rx_en_mask = 6'b000001;
            3'd2: rx_en_mask = 6'b000011;
            3'd3: rx_en_mask = 6'b000111;
            3'd4: rx_en_mask = 6'b001111;
            3'd5: rx_en_mask = 6'b011111;
            3'd6: rx_en_mask = 6'b111111;
            default: rx_en_mask = 6'b111111;
        endcase
    end

endmodule
