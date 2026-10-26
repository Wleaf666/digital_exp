`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 实验课程: 数字逻辑设计 - 实验3: 计数器
// 模块名称: water_led
// 功能描述: 基于计数器的时间间隔可调、方向可调、模式可调的 8 位流水灯
//
// 接口规范:
//   - clk       : 100MHz 板载时钟输入 (Minisys Y18 / EGO1 P17)
//   - rst       : 异步复位按键 (S1)，高有效，按下时流水灯复位只亮 LED0 (8'b00000001)
//   - freq_ctrl : 频率控制开关 (SW0): 0 对应 0.002s (500Hz), 1 对应 0.1s (10Hz)
//   - dir_ctrl  : 方向控制开关 (SW1): 0 对应循环左移, 1 对应循环右移
//   - mode_sel  : 模式控制开关 (SW7): 0 对应连续单灯流动, 1 对应连续双灯流动
//   - led[7:0]  : 8 位流水灯输出驱动 (对应板载绿色 LED GLD7 ~ GLD0)
//
// 参数化设计:
//   - CNT_500HZ : 500Hz (0.002s) 计数上限 (100MHz 下默认 199_999)
//   - CNT_10HZ  : 10Hz (0.1s) 计数上限 (100MHz 下默认 9_999_999)
//   - 仿真时可通过模块例化传参覆盖为 CNT_500HZ=6, CNT_10HZ=11 快速仿真
//////////////////////////////////////////////////////////////////////////////////

module water_led #(
    parameter CNT_500HZ = 24'd199_999, // 0.002s (500Hz) 对应计数上限: 200,000 - 1
    parameter CNT_10HZ  = 24'd9_999_999  // 0.1s (10Hz) 对应计数上限: 10,000,000 - 1
) (
    input  wire       clk,        // 系统时钟 100MHz
    input  wire       rst,        // 异步复位信号，高电平有效
    input  wire       freq_ctrl,  // 频率选择信号
    input  wire       dir_ctrl,   // 方向选择信号
    input  wire       mode_sel,   // 模式选择信号
    output reg  [7:0] led         // 流水灯输出
);

// -----------------------------------------------------------------------------
// 1. 计数器模块设计（时钟使能脉冲产生）
// -----------------------------------------------------------------------------
// 根据频率选择开关动态设定计数上限
wire [23:0] cnt_max;
assign cnt_max = (freq_ctrl == 1'b0) ? CNT_500HZ : CNT_10HZ;

// 计数器寄存器与计数结束脉冲
reg  [23:0] cnt;
wire        cnt_end;
assign cnt_end = (cnt >= cnt_max);

// 计数器计数逻辑（一个 always 块仅赋值 cnt）
always @(posedge clk or posedge rst) begin
    if (rst) begin
        cnt <= 24'd0;
    end else if (cnt_end) begin
        cnt <= 24'd0;
    end else begin
        cnt <= cnt + 24'd1;
    end
end

// 流水灯移位触发使能脉冲（作为控制信号，杜绝将分频时钟作为异步时钟）
wire shift_tick;
assign shift_tick = cnt_end;

// -----------------------------------------------------------------------------
// 2. 流水灯状态转移与移位控制逻辑
// -----------------------------------------------------------------------------
// 统计当前亮灯数量，用于模式切换时的平滑自愈
wire [3:0] lit_count;
assign lit_count = led[0] + led[1] + led[2] + led[3] + 
                   led[4] + led[5] + led[6] + led[7];

// 流水灯移位寄存器（一个 always 块仅赋值 led）
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // 复位要求：每次按下 S1，流水灯复位只亮 LED0
        led <= 8'b0000_0001;
    end else if (shift_tick) begin
        if (mode_sel == 1'b0) begin
            // -----------------------------------------------------------------
            // 模式 0: 连续单灯流动模式
            // -----------------------------------------------------------------
            if (lit_count != 4'd1) begin
                // 若刚从双灯切换过来，自愈为单灯
                led <= (dir_ctrl == 1'b0) ? 8'b0000_0010 : 8'b1000_0000;
            end else begin
                if (dir_ctrl == 1'b0) begin
                    // 循环左移：低位往高位移动 (LED0 -> LED1 -> ... -> LED7 -> LED0)
                    led <= {led[6:0], led[7]};
                end else begin
                    // 循环右移：高位往低位移动 (LED7 -> LED6 -> ... -> LED0 -> LED7)
                    led <= {led[0], led[7:1]};
                end
            end
        end else begin
            // -----------------------------------------------------------------
            // 模式 1: 连续双灯流动模式
            // -----------------------------------------------------------------
            if (lit_count != 4'd2) begin
                // 若刚从复位（单灯）或异常状态切入，自愈初始化为连续双灯
                led <= (dir_ctrl == 1'b0) ? 8'b0000_0011 : 8'b1000_0001;
            end else begin
                if (dir_ctrl == 1'b0) begin
                    // 循环左移
                    led <= {led[6:0], led[7]};
                end else begin
                    // 循环右移
                    led <= {led[0], led[7:1]};
                end
            end
        end
    end
end

endmodule
