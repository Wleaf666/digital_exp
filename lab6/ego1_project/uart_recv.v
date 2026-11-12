`timescale 1ns / 1ps

module uart_recv (
    input  wire       clk,
    input  wire       rst,
    input  wire       din,
    output reg        valid,
    output reg  [7:0] data
);

    localparam BIT_CYC  = 14'd10416;
    localparam HALF_CYC = 14'd5208;
    localparam IDLE     = 2'b00;
    localparam START    = 2'b01;
    localparam DATA     = 2'b10;
    localparam STOP     = 2'b11;

    reg [1:0]  state;
    reg [1:0]  next_state;
    reg        din_r0;
    reg        din_r1;
    reg [13:0] cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  rx_shift;

    wire neg_edge = (~din_r0) & din_r1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            din_r0 <= 1'b1;
            din_r1 <= 1'b1;
        end else begin
            din_r0 <= din;
            din_r1 <= din_r0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (neg_edge)
                    next_state = START;
                else
                    next_state = IDLE;
            end
            START: begin
                if (cnt == BIT_CYC - 1'b1)
                    next_state = DATA;
                else
                    next_state = START;
            end
            DATA: begin
                if (cnt == BIT_CYC - 1'b1 && bit_idx == 3'd7)
                    next_state = STOP;
                else
                    next_state = DATA;
            end
            STOP: begin
                if (cnt == HALF_CYC - 1'b1)
                    next_state = IDLE;
                else
                    next_state = STOP;
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt      <= 14'd0;
            bit_idx  <= 3'd0;
            rx_shift <= 8'h00;
            valid    <= 1'b0;
            data     <= 8'h00;
        end else begin
            valid <= 1'b0;
            case (state)
                IDLE: begin
                    cnt     <= 14'd0;
                    bit_idx <= 3'd0;
                end
                START: begin
                    if (cnt == BIT_CYC - 1'b1) begin
                        cnt     <= 14'd0;
                        bit_idx <= 3'd0;
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                DATA: begin
                    if (cnt == HALF_CYC - 1'b1) begin
                        rx_shift[bit_idx] <= din_r1;
                    end
                    if (cnt == BIT_CYC - 1'b1) begin
                        cnt <= 14'd0;
                        if (bit_idx < 3'd7) begin
                            bit_idx <= bit_idx + 3'd1;
                        end
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                STOP: begin
                    if (cnt == HALF_CYC - 1'b1) begin
                        cnt   <= 14'd0;
                        valid <= 1'b1;
                        data  <= rx_shift;
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                default: begin
                    cnt <= 14'd0;
                end
            endcase
        end
    end

endmodule
