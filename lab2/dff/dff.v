`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 实验课程: 数字逻辑设计 - 实验2: 触发器与寄存器文件
// 模块名称: dff
// 功能描述: 具有异步复位、同步使能的 1 位 D 触发器
// 设计规范:
//   - 异步复位 (clr): 高电平有效，优先级最高，直接清零输出 q
//   - 同步使能 (en): 高电平有效，在时钟上升沿且非复位时将输入 d 写入 q
//   - 时钟 (clk): 上升沿有效 (posedge clk)
//////////////////////////////////////////////////////////////////////////////////

module dff (
    input  wire clk,  // 100MHz 时钟信号
    input  wire clr,  // 异步复位信号，高电平有效
    input  wire en,   // 同步使能信号，高电平有效
    input  wire d,    // 数据输入
    output reg  q     // 数据输出
);

always @(posedge clk or posedge clr) begin
    if (clr) begin
        q <= 1'b0;
    end
    else if (en) begin
        q <= d;
    end
    // else 保持当前 q 不变
end

endmodule
