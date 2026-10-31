`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 实验课程: 数字逻辑设计 - 实验4: 数码管控制器
// 模块名称: seg_ctrl_top
// 功能描述: 数码管控制器顶层系统模块
//
// 系统架构与功能集成:
//   1. 模式选择 (sw0):
//      - sw0 = 1'b1 (拨码开关上拨): 模式 2.1 - 8 位数码管固定显示学号后 8 位 "25311308"
//      - sw0 = 1'b0 (拨码开关下拨): 模式 2.2 - 8 位数码管指定内容多功能动态显示:
//          * DK7-DK6 : 学号后两位 "08"
//          * DK5-DK4 : 按键 S3 无消抖计数 (00~99 两位十进制，持续按住只计一次)
//          * DK3-DK2 : 按键 S3 消抖后计数 (00~99 两位十进制，持续按住只计一次)
//          * DK1-DK0 : 0.1s 间隔的 0~20 循环计数器，按键 S2 控制启停 (消抖控制)
//   2. 异步全局复位 (rst / S1 按键):
//      - 按下 S1 (高有效)，全系统所有计数器、时序触发器与标志位复位清零
//   3. 模块化封装与层次化调用:
//      - 包含两级寄存器级联边沿检测模块 (edge_detect)
//      - 包含硬件计时按键消抖模块 (btn_debounce)
//      - 包含 8 位七段数码管动态扫描显示核心控制器 (led_ctrl_unit)
//////////////////////////////////////////////////////////////////////////////////

module seg_ctrl_top #(
    parameter SCAN_CNT_MAX     = 24'd100_000,  // 数码管扫描分频周期 (1ms @ 100MHz)
    parameter DEBOUNCE_CNT_MAX = 20'd1_000_000, // 按键消抖滤除时间 (10ms @ 100MHz)
    parameter TIMER_CNT_MAX    = 24'd10_000_000 // 0.1s 计数器时钟分频周期 (100MHz / 10Hz)
) (
    input  wire       clk,        // 100MHz 板载晶振输入 (Minisys Y18)
    input  wire       rst,        // 异步复位按键 S1 (Minisys R1)
    input  wire       sw0,        // 模式切换拨码开关 SW0 (Minisys W4)
    input  wire       btn_s2,     // 启停控制按键 S2 (Minisys P1)
    input  wire       btn_s3,     // 计数测试按键 S3 (Minisys P5)
    output wire [7:0] led_en,     // 8 位数码管位选信号 (A7~A0，低电平使能)
    output wire [7:0] led_cx      // 8 位数码管段选信号 (CA~DP，低电平点亮)
);

// =============================================================================
// 一、按键 S3 处理：无消抖边沿计数 vs 消抖边沿计数 (DK5-DK4 vs DK3-DK2)
// =============================================================================

// 1. 无消抖通路：直接打两拍检测上升沿
wire s3_raw_pulse;
edge_detect u_edge_s3_raw (
    .clk     (clk),
    .rst     (rst),
    .signal  (btn_s3),
    .pos_edge(s3_raw_pulse)
);

// 2. 消抖通路：先经 10ms 滤波，再打两拍检测上升沿
wire s3_clean;
btn_debounce #(
    .DEBOUNCE_CNT_MAX(DEBOUNCE_CNT_MAX)
) u_deb_s3 (
    .clk      (clk),
    .rst      (rst),
    .btn_in   (btn_s3),
    .btn_clean(s3_clean)
);

wire s3_deb_pulse;
edge_detect u_edge_s3_deb (
    .clk     (clk),
    .rst     (rst),
    .signal  (s3_clean),
    .pos_edge(s3_deb_pulse)
);

// 3. 无消抖 2 位十进制计数器 (00 ~ 99) -> DK5-DK4
reg [3:0] raw_s3_tens;
reg [3:0] raw_s3_ones;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        raw_s3_tens <= 4'd0;
        raw_s3_ones <= 4'd0;
    end else if (s3_raw_pulse) begin
        if (raw_s3_ones == 4'd9) begin
            raw_s3_ones <= 4'd0;
            raw_s3_tens <= (raw_s3_tens == 4'd9) ? 4'd0 : (raw_s3_tens + 4'd1);
        end else begin
            raw_s3_ones <= raw_s3_ones + 4'd1;
        end
    end
end

// 4. 消抖后 2 位十进制计数器 (00 ~ 99) -> DK3-DK2
reg [3:0] deb_s3_tens;
reg [3:0] deb_s3_ones;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        deb_s3_tens <= 4'd0;
        deb_s3_ones <= 4'd0;
    end else if (s3_deb_pulse) begin
        if (deb_s3_ones == 4'd9) begin
            deb_s3_ones <= 4'd0;
            deb_s3_tens <= (deb_s3_tens == 4'd9) ? 4'd0 : (deb_s3_tens + 4'd1);
        end else begin
            deb_s3_ones <= deb_s3_ones + 4'd1;
        end
    end
end

// =============================================================================
// 二、按键 S2 消抖启停控制与 0.1s 模 21 十进制计数器 (DK1-DK0)
// =============================================================================

// 1. 按键 S2 消抖与边沿脉冲产生
wire s2_clean;
btn_debounce #(
    .DEBOUNCE_CNT_MAX(DEBOUNCE_CNT_MAX)
) u_deb_s2 (
    .clk      (clk),
    .rst      (rst),
    .btn_in   (btn_s2),
    .btn_clean(s2_clean)
);

wire s2_pulse;
edge_detect u_edge_s2 (
    .clk     (clk),
    .rst     (rst),
    .signal  (s2_clean),
    .pos_edge(s2_pulse)
);

// 2. 运行/暂停标志位 (复位后默认直接开始计数，按一次暂停，再按继续)
reg running;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        running <= 1'b1;
    end else if (s2_pulse) begin
        running <= ~running;
    end
end

// 3. 0.1s 定时计数器分频脉冲产生
reg [23:0] timer_cnt;
wire       tick_01s;
assign tick_01s = (timer_cnt >= TIMER_CNT_MAX - 1'b1);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        timer_cnt <= 24'd0;
    end else if (running) begin
        if (tick_01s) begin
            timer_cnt <= 24'd0;
        end else begin
            timer_cnt <= timer_cnt + 24'd1;
        end
    end
end

// 4. 0 ~ 20 十进制计数器 (DK1-DK0)
reg [3:0] timer_tens;
reg [3:0] timer_ones;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        timer_tens <= 4'd0;
        timer_ones <= 4'd0;
    end else if (running && tick_01s) begin
        if (timer_tens == 4'd2 && timer_ones == 4'd0) begin
            // 计数到 20 后重新从 0 开始
            timer_tens <= 4'd0;
            timer_ones <= 4'd0;
        end else if (timer_ones == 4'd9) begin
            timer_ones <= 4'd0;
            timer_tens <= timer_tens + 4'd1;
        end else begin
            timer_ones <= timer_ones + 4'd1;
        end
    end
end

// =============================================================================
// 三、显示数据多路复用与数码管核心驱动
// =============================================================================

// 模式 2.1: 学号后 8 位 "25311308" (DK7 -> 2, DK6 -> 5, ..., DK0 -> 8)
wire [31:0] display_mode1 = 32'h2531_1308;

// 模式 2.2: {学号后两位(08), 无消抖S3计数(DK5-4), 消抖S3计数(DK3-2), 0~20计时(DK1-0)}
wire [31:0] display_mode2 = {
    4'h0, 4'h8,               // DK7-DK6: 学号后两位 08
    raw_s3_tens, raw_s3_ones, // DK5-DK4: S3 无消抖计数
    deb_s3_tens, deb_s3_ones, // DK3-DK2: S3 消抖后计数
    timer_tens, timer_ones    // DK1-DK0: 0~20 计时器
};

// 拨码开关 SW0 控制模式选择
wire [31:0] current_display;
assign current_display = (sw0 == 1'b1) ? display_mode1 : display_mode2;

// 实例化数码管动态显示单元
led_ctrl_unit #(
    .SCAN_CNT_MAX(SCAN_CNT_MAX)
) u_led_ctrl_unit (
    .clk    (clk),
    .rst    (rst),
    .display(current_display),
    .led_en (led_en),
    .led_cx (led_cx)
);

endmodule
