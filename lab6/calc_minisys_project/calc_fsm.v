`timescale 1ns / 1ps

module calc_fsm #(
    parameter CHAR_GAP = 20'd200_000
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        rx_valid,
    input  wire [7:0]  rx_data,
    output reg         tx_valid,
    output reg  [7:0]  tx_data,
    output reg  [31:0] disp_buf,
    output reg  [7:0]  disp_en
);

    localparam S_OP1  = 3'd0;
    localparam S_OP2  = 3'd1;
    localparam S_CALC = 3'd2;
    localparam S_BCD  = 3'd3;
    localparam S_TX   = 3'd4;

    localparam OP_ADD = 2'd0;
    localparam OP_SUB = 2'd1;
    localparam OP_MUL = 2'd2;
    localparam OP_DIV = 2'd3;

    reg [2:0]  state;
    reg [2:0]  next_state;

    reg [6:0]  op1;
    reg [6:0]  op2;
    reg [1:0]  op1_cnt;
    reg [1:0]  op2_cnt;
    reg [1:0]  op_code;
    reg        is_neg;

    reg [29:0] bcd_shift;
    reg [3:0]  bcd_cnt;

    reg [7:0]  tx_c0;
    reg [7:0]  tx_c1;
    reg [7:0]  tx_c2;
    reg [7:0]  tx_c3;
    reg [7:0]  tx_c4;
    reg [7:0]  tx_c5;
    reg [2:0]  tx_len;
    reg [2:0]  tx_idx;
    reg [19:0] gap_cnt;

    wire is_digit = (rx_data >= 8'h30) && (rx_data <= 8'h39);
    wire is_op    = (rx_data == 8'h2B) || (rx_data == 8'h2D) || (rx_data == 8'h2A) || (rx_data == 8'h2F);
    wire is_eq    = (rx_data == 8'h3D);

    wire [3:0] bcd_nib0 = (bcd_shift[17:14] >= 4'd5) ? (bcd_shift[17:14] + 4'd3) : bcd_shift[17:14];
    wire [3:0] bcd_nib1 = (bcd_shift[21:18] >= 4'd5) ? (bcd_shift[21:18] + 4'd3) : bcd_shift[21:18];
    wire [3:0] bcd_nib2 = (bcd_shift[25:22] >= 4'd5) ? (bcd_shift[25:22] + 4'd3) : bcd_shift[25:22];
    wire [2:0] bcd_nib3 = (bcd_shift[29:26] >= 4'd5) ? (bcd_shift[28:26] + 3'd3) : bcd_shift[28:26];
    wire [29:0] bcd_next = {bcd_nib3, bcd_nib2, bcd_nib1, bcd_nib0, bcd_shift[13:0], 1'b0};

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_OP1;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            S_OP1: begin
                if (rx_valid && (op1_cnt != 2'd0) && is_op)
                    next_state = S_OP2;
                else
                    next_state = S_OP1;
            end
            S_OP2: begin
                if (rx_valid && (op2_cnt != 2'd0) && is_eq)
                    next_state = S_CALC;
                else
                    next_state = S_OP2;
            end
            S_CALC: begin
                next_state = S_BCD;
            end
            S_BCD: begin
                if (bcd_cnt == 4'd13)
                    next_state = S_TX;
                else
                    next_state = S_BCD;
            end
            S_TX: begin
                if ((gap_cnt >= CHAR_GAP - 20'd1) && (tx_idx >= tx_len - 3'd1))
                    next_state = S_OP1;
                else
                    next_state = S_TX;
            end
            default: next_state = S_OP1;
        endcase
    end

    always @(*) begin
        case (tx_idx)
            3'd0: tx_data = tx_c0;
            3'd1: tx_data = tx_c1;
            3'd2: tx_data = tx_c2;
            3'd3: tx_data = tx_c3;
            3'd4: tx_data = tx_c4;
            3'd5: tx_data = tx_c5;
            default: tx_data = 8'h00;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            op1       <= 7'd0;
        end else begin
            case (state)
                S_OP1: begin
                    if (rx_valid) begin
                        if (is_digit) begin
                            if (op1_cnt == 2'd0) begin
                                op1      <= {3'd0, rx_data[3:0]};
                            end else if (op1_cnt == 2'd1) begin
                                op1      <= {op1[3:0], 3'd0} + {2'd0, op1[3:0], 1'b0} + {3'd0, rx_data[3:0]};
                            end
                        end
                    end
                end
                S_TX: begin
                    if (gap_cnt == 20'd0) begin end else if (gap_cnt >= CHAR_GAP - 20'd1) begin
                        if (tx_idx >= tx_len - 3'd1) begin
                            op1     <= 7'd0;
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            op2       <= 7'd0;
        end else begin
            case (state)
                S_OP2: begin
                    if (rx_valid && is_digit) begin
                        if (op2_cnt == 2'd0) begin
                            op2      <= {3'd0, rx_data[3:0]};
                        end else if (op2_cnt == 2'd1) begin
                            op2      <= {op2[3:0], 3'd0} + {2'd0, op2[3:0], 1'b0} + {3'd0, rx_data[3:0]};
                        end
                    end
                end
                S_TX: begin
                    if (gap_cnt == 20'd0) begin end else if (gap_cnt >= CHAR_GAP - 20'd1) begin
                        if (tx_idx >= tx_len - 3'd1) begin
                            op2     <= 7'd0;
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            op1_cnt   <= 2'd0;
        end else begin
            case (state)
                S_OP1: begin
                    if (rx_valid) begin
                        if (is_digit) begin
                            if (op1_cnt == 2'd0) begin
                                op1_cnt  <= 2'd1;
                            end else if (op1_cnt == 2'd1) begin
                                op1_cnt  <= 2'd2;
                            end
                        end
                    end
                end
                S_TX: begin
                    if (gap_cnt == 20'd0) begin end else if (gap_cnt >= CHAR_GAP - 20'd1) begin
                        if (tx_idx >= tx_len - 3'd1) begin
                            op1_cnt <= 2'd0;
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            op2_cnt   <= 2'd0;
        end else begin
            case (state)
                S_OP2: begin
                    if (rx_valid && is_digit) begin
                        if (op2_cnt == 2'd0) begin
                            op2_cnt  <= 2'd1;
                        end else if (op2_cnt == 2'd1) begin
                            op2_cnt  <= 2'd2;
                        end
                    end
                end
                S_TX: begin
                    if (gap_cnt == 20'd0) begin end else if (gap_cnt >= CHAR_GAP - 20'd1) begin
                        if (tx_idx >= tx_len - 3'd1) begin
                            op2_cnt <= 2'd0;
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            op_code   <= OP_ADD;
        end else begin
            case (state)
                S_OP1: begin
                    if (rx_valid) begin
                        if (is_digit) begin end else if ((op1_cnt != 2'd0) && is_op) begin
                            if (rx_data == 8'h2B) begin
                                op_code <= OP_ADD;
                            end else if (rx_data == 8'h2D) begin
                                op_code <= OP_SUB;
                            end else if (rx_data == 8'h2A) begin
                                op_code <= OP_MUL;
                            end else begin
                                op_code <= OP_DIV;
                            end
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_neg    <= 1'b0;
        end else begin
            case (state)
                S_CALC: begin
                    case (op_code)
                        OP_ADD: begin
                            is_neg    <= 1'b0;
                        end
                        OP_SUB: begin
                            if (op1 >= op2) begin
                                is_neg    <= 1'b0;
                            end else begin
                                is_neg    <= 1'b1;
                            end
                        end
                        OP_MUL: begin
                            is_neg    <= 1'b0;
                        end
                        OP_DIV: begin
                            is_neg <= 1'b0;
                        end
                        default: begin
                            is_neg    <= 1'b0;
                        end
                    endcase
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bcd_shift <= 30'd0;
        end else begin
            case (state)
                S_CALC: begin
                    case (op_code)
                        OP_ADD: begin
                            bcd_shift <= {16'd0, ({7'd0, op1} + {7'd0, op2})};
                        end
                        OP_SUB: begin
                            if (op1 >= op2) begin
                                bcd_shift <= {16'd0, {7'd0, op1 - op2}};
                            end else begin
                                bcd_shift <= {16'd0, {7'd0, op2 - op1}};
                            end
                        end
                        OP_MUL: begin
                            bcd_shift <= {16'd0, ({7'd0, op1} * {7'd0, op2})};
                        end
                        OP_DIV: begin
                            if (op2 == 7'd0) begin
                                bcd_shift <= 30'd0;
                            end else begin
                                bcd_shift <= {16'd0, {7'd0, op1 / op2}};
                            end
                        end
                        default: begin
                            bcd_shift <= 30'd0;
                        end
                    endcase
                end
                S_BCD: begin
                    bcd_shift <= bcd_next;
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bcd_cnt   <= 4'd0;
        end else begin
            case (state)
                S_CALC: begin
                    bcd_cnt <= 4'd0;
                end
                S_BCD: begin
                    if (bcd_cnt == 4'd13) begin end else begin
                        bcd_cnt <= bcd_cnt + 4'd1;
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_c0     <= 8'h00;
            tx_c1     <= 8'h00;
            tx_c2     <= 8'h00;
            tx_c3     <= 8'h00;
            tx_c4     <= 8'h00;
            tx_c5     <= 8'h00;
        end else begin
            case (state)
                S_BCD: begin
                    if (bcd_cnt == 4'd13) begin
                        if (is_neg) begin
                            if (bcd_next[21:18] != 4'd0) begin
                                tx_c0    <= 8'h2D;
                                tx_c1    <= {4'h3, bcd_next[21:18]};
                                tx_c2    <= {4'h3, bcd_next[17:14]};
                                tx_c3    <= 8'h0D;
                                tx_c4    <= 8'h0A;
                                tx_c5    <= 8'h00;
                            end else begin
                                tx_c0    <= 8'h2D;
                                tx_c1    <= {4'h3, bcd_next[17:14]};
                                tx_c2    <= 8'h0D;
                                tx_c3    <= 8'h0A;
                                tx_c4    <= 8'h00;
                                tx_c5    <= 8'h00;
                            end
                        end else begin
                            if (bcd_next[29:26] != 4'd0) begin
                                tx_c0    <= {4'h3, bcd_next[29:26]};
                                tx_c1    <= {4'h3, bcd_next[25:22]};
                                tx_c2    <= {4'h3, bcd_next[21:18]};
                                tx_c3    <= {4'h3, bcd_next[17:14]};
                                tx_c4    <= 8'h0D;
                                tx_c5    <= 8'h0A;
                            end else if (bcd_next[25:22] != 4'd0) begin
                                tx_c0    <= {4'h3, bcd_next[25:22]};
                                tx_c1    <= {4'h3, bcd_next[21:18]};
                                tx_c2    <= {4'h3, bcd_next[17:14]};
                                tx_c3    <= 8'h0D;
                                tx_c4    <= 8'h0A;
                                tx_c5    <= 8'h00;
                            end else if (bcd_next[21:18] != 4'd0) begin
                                tx_c0    <= {4'h3, bcd_next[21:18]};
                                tx_c1    <= {4'h3, bcd_next[17:14]};
                                tx_c2    <= 8'h0D;
                                tx_c3    <= 8'h0A;
                                tx_c4    <= 8'h00;
                                tx_c5    <= 8'h00;
                            end else begin
                                tx_c0    <= {4'h3, bcd_next[17:14]};
                                tx_c1    <= 8'h0D;
                                tx_c2    <= 8'h0A;
                                tx_c3    <= 8'h00;
                                tx_c4    <= 8'h00;
                                tx_c5    <= 8'h00;
                            end
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_len    <= 3'd0;
        end else begin
            case (state)
                S_BCD: begin
                    if (bcd_cnt == 4'd13) begin
                        if (is_neg) begin
                            if (bcd_next[21:18] != 4'd0) begin
                                tx_len   <= 3'd5;
                            end else begin
                                tx_len   <= 3'd4;
                            end
                        end else begin
                            if (bcd_next[29:26] != 4'd0) begin
                                tx_len   <= 3'd6;
                            end else if (bcd_next[25:22] != 4'd0) begin
                                tx_len   <= 3'd5;
                            end else if (bcd_next[21:18] != 4'd0) begin
                                tx_len   <= 3'd4;
                            end else begin
                                tx_len   <= 3'd3;
                            end
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_idx    <= 3'd0;
        end else begin
            case (state)
                S_BCD: begin
                    if (bcd_cnt == 4'd13) begin
                        tx_idx  <= 3'd0;
                    end
                end
                S_TX: begin
                    if (gap_cnt == 20'd0) begin end else if (gap_cnt >= CHAR_GAP - 20'd1) begin
                        if (tx_idx >= tx_len - 3'd1) begin
                            tx_idx  <= 3'd0;
                        end else begin
                            tx_idx <= tx_idx + 3'd1;
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            gap_cnt   <= 20'd0;
        end else begin
            case (state)
                S_BCD: begin
                    if (bcd_cnt == 4'd13) begin
                        gap_cnt <= 20'd0;
                    end
                end
                S_TX: begin
                    if (gap_cnt == 20'd0) begin
                        gap_cnt  <= gap_cnt + 20'd1;
                    end else if (gap_cnt >= CHAR_GAP - 20'd1) begin
                        gap_cnt <= 20'd0;
                    end else begin
                        gap_cnt <= gap_cnt + 20'd1;
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_valid  <= 1'b0;
        end else begin
            tx_valid <= 1'b0;
            case (state)
                S_OP1: begin end
                S_OP2: begin end
                S_CALC: begin end
                S_BCD: begin end
                S_TX: begin
                    if (gap_cnt == 20'd0) begin
                        tx_valid <= 1'b1;
                    end
                end
                default: begin
                    tx_valid <= 1'b0;
                end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            disp_buf  <= 32'd0;
            disp_en   <= 8'b0000_0000;
        end else begin
            case (state)
                S_OP1: begin
                    if (rx_valid) begin
                        if (is_digit) begin
                            if (op1_cnt == 2'd0) begin
                                disp_buf <= {28'd0, rx_data[3:0]};
                                disp_en  <= 8'b0000_0001;
                            end else if (op1_cnt == 2'd1) begin
                                disp_buf <= {24'd0, disp_buf[3:0], rx_data[3:0]};
                                disp_en  <= 8'b0000_0011;
                            end
                        end
                    end
                end
                S_OP2: begin
                    if (rx_valid && is_digit) begin
                        if (op2_cnt == 2'd0) begin
                            disp_buf <= {28'd0, rx_data[3:0]};
                            disp_en  <= 8'b0000_0001;
                        end else if (op2_cnt == 2'd1) begin
                            disp_buf <= {24'd0, disp_buf[3:0], rx_data[3:0]};
                            disp_en  <= 8'b0000_0011;
                        end
                    end
                end
                S_BCD: begin
                    if (bcd_cnt == 4'd13) begin
                        if (is_neg) begin
                            if (bcd_next[21:18] != 4'd0) begin
                                disp_buf <= {20'd0, 4'hA, bcd_next[21:18], bcd_next[17:14]};
                                disp_en  <= 8'b0000_0111;
                            end else begin
                                disp_buf <= {24'd0, 4'hA, bcd_next[17:14]};
                                disp_en  <= 8'b0000_0011;
                            end
                        end else begin
                            if (bcd_next[29:26] != 4'd0) begin
                                disp_buf <= {16'd0, bcd_next[29:26], bcd_next[25:22], bcd_next[21:18], bcd_next[17:14]};
                                disp_en  <= 8'b0000_1111;
                            end else if (bcd_next[25:22] != 4'd0) begin
                                disp_buf <= {20'd0, bcd_next[25:22], bcd_next[21:18], bcd_next[17:14]};
                                disp_en  <= 8'b0000_0111;
                            end else if (bcd_next[21:18] != 4'd0) begin
                                disp_buf <= {24'd0, bcd_next[21:18], bcd_next[17:14]};
                                disp_en  <= 8'b0000_0011;
                            end else begin
                                disp_buf <= {28'd0, bcd_next[17:14]};
                                disp_en  <= 8'b0000_0001;
                            end
                        end
                    end
                end
                default: begin end
            endcase
        end
    end

endmodule
