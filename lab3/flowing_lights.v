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
wire        en          = cnt_end;   // Ƶʹܣÿλֻһ

// ͳƵǰĵ0~84 λ㹻
wire [3:0] led_counts = leds[0] + leds[1] + leds[2] + leds[3]
                      + leds[4] + leds[5] + leds[6] + leds[7];

//------------------------------------------------------------------
// ƵƵ current_cnt 㣬 en ʹ
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
// ˮ
//------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if(rst)
        leds <= 8'h01;
    else if(en) begin
        if(model_set == 1'b0) begin                 // ---------- ģʽ ----------
            if(led_counts != 4'd1)
                leds <= 8'h01;                      // 쳣λΪ
            else if(dir_ctrl == 1'b0)
                leds <= {leds[0],  leds[7:1]};      // ѭ 1 λ
            else
                leds <= {leds[6:0], leds[7]};       // ѭ 1 λ
        end
        else begin                                  // ---------- ˫ģʽ ----------
            if(led_counts != 4'd2)
                leds <= 8'h03;                      // 쳣λΪ˫
            else if(dir_ctrl == 1'b0)
                leds <= {leds[1:0], leds[7:2]};     // ѭ 2 λ
            else
                leds <= {leds[5:0], leds[7:6]};     // ѭ 2 λ
        end
    end
end

endmodule

