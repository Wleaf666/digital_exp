`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 实验课程: 数字逻辑设计 - 实验2: 触发器与寄存器文件
// 模块名称: reg8file
// 功能描述: 8 个 8 位寄存器组成的通用寄存器文件 (Register File / 寄存器堆)
// 端口与控制规范:
//   - clk: 时钟信号 (100MHz)，写操作在上升沿同步触发 (posedge clk)
//   - clr: 异步复位信号，高电平有效，优先级最高，复位时全部 8 个寄存器清零
//   - en: 同步写使能信号，高有效，en=1 时将输入数据 d 写入 wsel 指定的寄存器
//   - wsel[2:0]: 3 位写寄存器地址选择 (0~7)
//   - rsel[2:0]: 3 位读寄存器地址选择 (0~7)
//   - d[7:0]: 8 位待写入数据输入
//   - q[7:0]: 8 位读出数据输出，纯异步组合逻辑输出 (地址改变输出即刻改变)
//////////////////////////////////////////////////////////////////////////////////

module reg8file (
    input  wire       clk,   // 100MHz 时钟信号
    input  wire       clr,   // 异步复位信号，高电平有效
    input  wire       en,    // 同步写使能信号，高电平有效
    input  wire [7:0] d,     // 8 位写入数据输入
    input  wire [2:0] wsel,  // 3 位写寄存器编号选择
    input  wire [2:0] rsel,  // 3 位读寄存器编号选择 (异步读)
    output reg  [7:0] q      // 8 位读出数据输出，驱动 LED 显示
);

// 定义 8 个 8 位的内部寄存器数组
reg [7:0] regfile [7:0];

// 1. 同步写逻辑（带异步复位）
integer i;
always @(posedge clk or posedge clr) begin
    if (clr) begin
        for (i = 0; i < 8; i = i + 1) begin
            regfile[i] <= 8'h00;
        end
    end
    else if (en) begin
        regfile[wsel] <= d;
    end
end

// 2. 异步读逻辑 (纯组合逻辑，读地址改变输出立即可见，无需等待时钟边沿)
always @(*) begin
    q = regfile[rsel];
end

endmodule
