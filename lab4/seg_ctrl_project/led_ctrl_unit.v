`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 实验课程: 数字逻辑设计 - 实验4: 数码管控制器
// 模块名称: led_ctrl_unit
// 功能描述: 8 位七段数码管动态扫描显示核心控制器
//
// 接口说明:
//   - clk         : 100MHz 系统主时钟输入
//   - rst         : 异步全局复位信号，高电平有效
//   - display     : 32 位待显示数据（共 8 个 4 位十六进制字符）
//                   display[31:28] -> DK7 (最左侧数码管)
//                   display[27:24] -> DK6
//                   display[23:20] -> DK5
//                   display[19:16] -> DK4
//                   display[15:12] -> DK3
//                   display[11:8]  -> DK2
//                   display[7:4]   -> DK1
//                   display[3:0]   -> DK0 (最右侧数码管)
//   - led_en[7:0] : 8 位数码管位选使能信号（Minisys 共阳极低电平有效）
//   - led_cx[7:0] : 8 位段选信号 {CA, CB, CC, CD, CE, CF, CG, DP}（低电平点亮）
//
// 参数说明:
//   - SCAN_CNT_MAX : 每个数码管点亮持续的时钟周期数
//                    上板实际默认 100_000 周期 (1ms @ 100MHz)
//                    仿真时可由上层 testbench 传参调小至 10 周期以缩短仿真时间
//////////////////////////////////////////////////////////////////////////////////

module led_ctrl_unit #(
    parameter SCAN_CNT_MAX = 24'd100_000 // 默认 1ms 刷新一拍
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] display,
    output reg  [7:0]  led_en,
    output reg  [7:0]  led_cx
);

// -----------------------------------------------------------------------------
// 1. 动态扫描分频计数器与当前选中数码管索引
// -----------------------------------------------------------------------------
reg [23:0] scan_cnt;
reg [2:0]  digit_idx; // 0 ~ 7 分别对应 DK0 ~ DK7

always @(posedge clk or posedge rst) begin
    if (rst) begin
        scan_cnt  <= 24'd0;
        digit_idx <= 3'd0;
    end else if (scan_cnt >= SCAN_CNT_MAX - 1'b1) begin
        scan_cnt  <= 24'd0;
        digit_idx <= digit_idx + 3'd1;
    end else begin
        scan_cnt <= scan_cnt + 24'd1;
    end
end

// -----------------------------------------------------------------------------
// 2. 提取当前数码管待显示的 4 位十六进制数值
// -----------------------------------------------------------------------------
reg [3:0] hex_num;

always @(*) begin
    case (digit_idx)
        3'd0: begin
            led_en  = 8'b1111_1110; // 选通最右侧 DK0 (A0)
            hex_num = display[3:0];
        end
        3'd1: begin
            led_en  = 8'b1111_1101; // 选通 DK1 (A1)
            hex_num = display[7:4];
        end
        3'd2: begin
            led_en  = 8'b1111_1011; // 选通 DK2 (A2)
            hex_num = display[11:8];
        end
        3'd3: begin
            led_en  = 8'b1111_0111; // 选通 DK3 (A3)
            hex_num = display[15:12];
        end
        3'd4: begin
            led_en  = 8'b1110_1111; // 选通 DK4 (A4)
            hex_num = display[19:16];
        end
        3'd5: begin
            led_en  = 8'b1101_1111; // 选通 DK5 (A5)
            hex_num = display[23:20];
        end
        3'd6: begin
            led_en  = 8'b1011_1111; // 选通 DK6 (A6)
            hex_num = display[27:24];
        end
        3'd7: begin
            led_en  = 8'b0111_1111; // 选通最左侧 DK7 (A7)
            hex_num = display[31:28];
        end
        default: begin
            led_en  = 8'b1111_1111;
            hex_num = 4'h0;
        end
    endcase
end

// -----------------------------------------------------------------------------
// 3. 7 段数码管字符段选译码（Minisys 共阳极，低电平有效点亮，顺序为 {CA,CB,CC,CD,CE,CF,CG,DP}）
// -----------------------------------------------------------------------------
always @(*) begin
    case (hex_num)
        4'h0: led_cx = 8'h03; // 8'b0000_0011 (CA~CF亮, CG灭, DP灭)
        4'h1: led_cx = 8'h9F; // 8'b1001_1111 (CB,CC亮)
        4'h2: led_cx = 8'h25; // 8'b0010_0101
        4'h3: led_cx = 8'h0D; // 8'b0000_1101
        4'h4: led_cx = 8'h99; // 8'b1001_1001
        4'h5: led_cx = 8'h49; // 8'b0100_1001
        4'h6: led_cx = 8'h41; // 8'b0100_0001
        4'h7: led_cx = 8'h1F; // 8'b0001_1111
        4'h8: led_cx = 8'h01; // 8'b0000_0001
        4'h9: led_cx = 8'h09; // 8'b0000_1001
        4'hA: led_cx = 8'h11; // 8'b0001_0001
        4'hB: led_cx = 8'hC1; // 8'b1100_0001 (显示小写 b)
        4'hC: led_cx = 8'h63; // 8'b0110_0011
        4'hD: led_cx = 8'h85; // 8'b1000_0101 (显示小写 d)
        4'hE: led_cx = 8'h61; // 8'b0110_0001
        4'hF: led_cx = 8'h71; // 8'b0111_0001
        default: led_cx = 8'hFF; // 全熄灭
    endcase
end

endmodule
