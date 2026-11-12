`timescale 1ns / 1ps

module uart_send (
    input  wire       clk,
    input  wire       rst,
    input  wire       valid,
    input  wire [7:0] data,
    output reg        dout
);

    localparam BIT_CYC = 14'd10416;
    localparam IDLE    = 2'b00;
    localparam START   = 2'b01;
    localparam DATA    = 2'b10;
    localparam STOP    = 2'b11;

    reg [1:0]  state;
    reg [1:0]  next_state;
    reg [13:0] cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  data_reg;

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
                if (valid)
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
                if (cnt == BIT_CYC - 1'b1)
                    next_state = IDLE;
                else
                    next_state = STOP;
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dout     <= 1'b1;
            cnt      <= 14'd0;
            bit_idx  <= 3'd0;
            data_reg <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    dout <= 1'b1;
                    cnt  <= 14'd0;
                    bit_idx <= 3'd0;
                    if (valid) begin
                        data_reg <= data;
                        dout     <= 1'b0;
                        cnt      <= 14'd0;
                    end
                end
                START: begin
                    if (cnt == BIT_CYC - 1'b1) begin
                        cnt     <= 14'd0;
                        bit_idx <= 3'd0;
                        dout    <= data_reg[0];
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                DATA: begin
                    if (cnt == BIT_CYC - 1'b1) begin
                        cnt <= 14'd0;
                        if (bit_idx == 3'd7) begin
                            dout <= 1'b1;
                        end else begin
                            bit_idx <= bit_idx + 3'd1;
                            dout    <= data_reg[bit_idx + 3'd1];
                        end
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                STOP: begin
                    if (cnt == BIT_CYC - 1'b1) begin
                        cnt  <= 14'd0;
                        dout <= 1'b1;
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                default: begin
                    dout <= 1'b1;
                    cnt  <= 14'd0;
                end
            endcase
        end
    end

endmodule
