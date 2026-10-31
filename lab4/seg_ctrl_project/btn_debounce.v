`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 实验课程: 数字逻辑设计 - 实验4: 数码管控制器
// 模块名称: btn_debounce
// 功能描述: 基于持续计时滤波的硬件按键消抖模块
//
// 硬件原理说明:
//   - 机械按键在按下与释放时会产生持续 5ms ~ 15ms 的机械抖动；
//   - 本模块监测输入信号 btn_in 与当前输出稳定电平 btn_clean 是否一致；
//   - 若电平发生改变，启动稳定计数器累计计数；
//   - 若在计数满 10ms (1_000_000 个 100MHz 周期) 期间再次发生抖动翻转，计数器清零重新累计；
//   - 仅当输入电平连续稳定保持超过 10ms 时，才更新输出电平 btn_clean，彻底过滤毛刺干扰；
//   - 仿真时可将 DEBOUNCE_CNT_MAX 参数由顶层传参调小，便于快速仿真波形呈现。
//////////////////////////////////////////////////////////////////////////////////

module btn_debounce #(
    parameter DEBOUNCE_CNT_MAX = 20'd1_000_000 // 默认 10ms @ 100MHz
) (
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output reg  btn_clean
);

// 抖动计时计数器
reg [19:0] cnt;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        cnt       <= 20'd0;
        btn_clean <= 1'b0;
    end else begin
        if (btn_in != btn_clean) begin
            // 检测到输入与当前稳定状态不一致，开始/继续累计稳定时间
            if (cnt >= DEBOUNCE_CNT_MAX - 1'b1) begin
                btn_clean <= btn_in; // 连续稳定满 10ms，正式更新电平
                cnt       <= 20'd0;
            end else begin
                cnt <= cnt + 20'd1;
            end
        end else begin
            // 输入与输出状态一致，清零计数器
            cnt <= 20'd0;
        end
    end
end

endmodule
