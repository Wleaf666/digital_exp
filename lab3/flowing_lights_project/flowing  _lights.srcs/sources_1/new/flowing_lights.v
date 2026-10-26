`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/26 14:04:02
// Design Name: 
// Module Name: flowing_lights
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flowing_lights
#(
    parameter CNT_500HZ = 24'd199999,   // 100MHz / 500Hz - 1
    parameter CNT_10HZ  = 24'd9999999   // 100MHz / 10Hz  - 1
)
(
    input            clk,
    input            rst,
    input            freq_ctrl,
    input            dir_ctrl,
    input            model_set,
    output reg [7:0] leds
);

reg  [23:0] cnt;
wire [23:0] current_cnt = (freq_ctrl == 1'b0) ? CNT_500HZ : CNT_10HZ;
wire        cnt_end     = (cnt == current_cnt);
wire        en          = cnt_end;   // 分频使能，每个移位周期只拉高一拍

// 统计当前点亮的灯数（0~8，4 位足够）
wire [3:0] led_counts = leds[0] + leds[1] + leds[2] + leds[3]
                      + leds[4] + leds[5] + leds[6] + leds[7];

//------------------------------------------------------------------
// 分频计数器：计到 current_cnt 归零，产生 en 使能
//------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if(rst)
        cnt <= 24'd0;
    else if(cnt_end)
        cnt <= 24'd0;
    else
        cnt <= cnt + 24'd1;
end

//------------------------------------------------------------------
// 流水灯主体
//------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if(rst)
        leds <= 8'h01;
    else if(en) begin
        if(model_set == 1'b0) begin                 // ---------- 单灯模式 ----------
            if(led_counts != 4'd1)
                leds <= 8'h01;                      // 灯数异常，复位为单灯
            else if(dir_ctrl == 1'b0)
                leds <= {leds[0],  leds[7:1]};      // 循环右移 1 位
            else
                leds <= {leds[6:0], leds[7]};       // 循环左移 1 位
        end
        else begin                                  // ---------- 双灯模式 ----------
            if(led_counts != 4'd2)
                leds <= 8'h03;                      // 灯数异常，复位为双灯
            else if(dir_ctrl == 1'b0)
                leds <= {leds[1:0], leds[7:2]};     // 循环右移 2 位
            else
                leds <= {leds[5:0], leds[7:6]};     // 循环左移 2 位
        end
    end
end

endmodule

