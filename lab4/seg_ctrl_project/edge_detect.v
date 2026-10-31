`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 实验课程: 数字逻辑设计 - 实验4: 数码管控制器
// 模块名称: edge_detect
// 功能描述: 基于两级寄存器级联（打两拍）的同步边沿检测器
//
// 硬件原理说明（指导书方式二）:
//   - signal 由外部按键异步输入，经第一级寄存器输出为 sig_r0（消除亚稳态）；
//   - sig_r0 紧接着送入第二级级联寄存器，输出为 sig_r1（延迟一个时钟周期）；
//   - 组合逻辑判断：当 sig_r0 为高且 sig_r1 为低时，说明输入信号发生了 0 -> 1 跳变；
//   - 输出 pos_edge 产生持续恰好 1 个时钟周期的单脉冲；
//   - RTL 视图中将清晰呈现这两个级联串联的触发器单元，便于报告红框标记。
//////////////////////////////////////////////////////////////////////////////////

module edge_detect (
    input  wire clk,      // 100MHz 时钟
    input  wire rst,      // 异步复位信号，高电平有效
    input  wire signal,   // 待检测输入信号
    output wire pos_edge  // 上升沿单脉冲输出（高电平有效，持续 1 拍）
);

// 两级寄存器级联定义
reg sig_r0;
reg sig_r1;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sig_r0 <= 1'b0;
        sig_r1 <= 1'b0;
    end else begin
        sig_r0 <= signal;  // 第一级采样寄存器
        sig_r1 <= sig_r0;   // 第二级级联延迟寄存器
    end
end

// 当当前周期为高、上一周期为低时，判定为上升沿
assign pos_edge = sig_r0 & (~sig_r1);

endmodule
