
UART发送模块常见错误与仿真报错对照¶
本页给出uart_send模块实现中的几个典型错误、testbench的对应报错信息以及上板现象，用于仿真不通过时的排查参考，也可用于课上"改错练习"：先看报错信息和波形定位问题，再对照本页验证结论。
所有报错信息均摘自testbench实际运行输出。
参考实现¶
以下实现能通过全部仿真用例，且上板工作正常：
module uart_send(
    input  wire       clk,
    input  wire       rst,
    input  wire       valid,
    input  wire [7:0] data,
    output reg        dout
);
    localparam BIT_CYC = 10416;                    // 每位10416个时钟周期
    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0]  state;
    reg [13:0] cnt;                                // 位内计数器
    reg [2:0]  bit_idx;                            // 当前数据位序号
    reg [7:0]  data_reg;                           // valid有效时锁存的数据

    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            dout     <= 1'b1;                      // 空闲电平为高
            cnt      <= 14'd0;
            bit_idx  <= 3'd0;
            data_reg <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    dout <= 1'b1;
                    if (valid) begin
                        data_reg <= data;          // 锁存数据
                        dout     <= 1'b0;          // 起始位
                        cnt      <= 14'd0;
                        state    <= START;
                    end
                end
                START: begin
                    if (cnt == BIT_CYC - 1) begin
                        cnt     <= 14'd0;
                        bit_idx <= 3'd0;
                        dout    <= data_reg[0];    // LSB在前
                        state   <= DATA;
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                DATA: begin
                    if (cnt == BIT_CYC - 1) begin
                        cnt <= 14'd0;
                        if (bit_idx == 3'd7) begin
                            dout  <= 1'b1;         // 停止位
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 3'd1;
                            dout    <= data_reg[bit_idx + 3'd1];
                        end
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                STOP: begin
                    if (cnt == BIT_CYC - 1) begin
                        cnt   <= 14'd0;
                        state <= IDLE;
                    end else begin
                        cnt <= cnt + 14'd1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

要点：

valid有效的当拍锁存data并直接输出起始位；
每位持续0 ~ BIT_CYC-1共10416个时钟周期；
数据位LSB在前；
复位和IDLE状态都驱动dout为1。

错误1：波特率计数值差1¶
localparam BIT_CYC = 10415;   // 10416.67截断时习惯性少取1

Error (test 1): bit-width check failed, 9 bits measured 937350.000000 ns (104150.00 ns per bit), expected 104160.000000 ns per bit
Test 1: bit-width check FAIL
Test 2: data=a5 PASS
...
1 errors detected in 10 tests!

只有Test 1（位宽校验）报错，其余用例逐位采样全部正常。上板时串口助手一般仍能收到正确的字符（串口本身容忍一定的波特率误差），但仿真过不了——这就是"上板正常，仿真过不了"的典型原因。
错误2：数据位MSB先发¶
dout <= data_reg[7];                 // START结束时从最高位开始
dout <= data_reg[6 - bit_idx];       // DATA状态降序取位

Error (test 6) at time 5886520 ns, bit 2: expected 0, got 1
Test 6: data=6c FAIL
Test 7: data=85 FAIL
Test 8: data=ce FAIL
Test 9: data=5e FAIL
Test 10: data=54 FAIL
20 errors detected in 10 tests!

UART约定数据位LSB在前。注意：testbench的固定测试数据A5、3C、FF、00、5A都是位回文（正反读相同），MSB先发的错误在固定用例（Test 2~5）下**检测不出来**，全靠随机数据用例（Test 6~10）暴露。
错误3：没有锁存data¶
// IDLE状态: 少了 data_reg <= data;
dout <= data[bit_idx + 3'd1];        // DATA状态直接采样输入data

Error (test 4) at time 3490420 ns, bit 1: expected 1, got 0
Test 4: data=ff FAIL
（只有test 4失败，共8个错误）

test 4是FF用例，testbench在该用例的valid撤销后立刻改变data，只有这个用例失败。valid是单周期脉冲，模块必须在valid有效时把data锁存下来；如果对输入数据做实时采样，valid撤销后数据变化就会发出错误内容。
错误4：复位时没有给dout赋初值¶
if (rst) begin
    state <= IDLE;
    // 漏了 dout <= 1'b1; 且IDLE状态也不驱动dout

Error (test 1): line is not idle high before transmission, dout=x
Test 1: bit-width check FAIL
1 errors detected in 10 tests!

仿真中dout在首次发送前是x态。上板时Xilinx的未复位寄存器上电默认为0，上电后发送线一直为低，串口助手会收到一串0x00或提示帧错误。
错误5：空闲电平极性反了¶
IDLE: begin
    dout <= 1'b0;    // 错: 空闲电平应为高

Error (test 1): line is not idle high before transmission, dout=0
Test 1: bit-width check FAIL
Error (test 2): line is not idle high before transmission, dout=0
Error (test 2): line did not return to idle high after frame, dout=0
（共28个错误）

UART空闲电平为高，起始位才是低电平。
错误6：起始位只维持1个时钟周期¶
START: begin
    if (cnt == 14'd0) begin          // 错: 应为 BIT_CYC-1

Error (test 1): bit-width check failed, 9 bits measured 833290.000000 ns (92587.78 ns per bit), expected 104160.000000 ns per bit
Error (test 2) at time 990170 ns, bit 0: expected 0, got 1
Test 2: data=a5 FAIL
（共44个错误）

把起始位当成"维持一拍的通知信号"是常见误解。起始位是数据帧的一部分，和其余各位一样，每个位（起始位、8个数据位、停止位）都要维持10416个时钟周期。
