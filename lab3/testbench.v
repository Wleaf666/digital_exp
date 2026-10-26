`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name : tb_flowing_lights
// Description : flowing_lights 
//   ˳򣺸λ -> Ƶл(500Hz->10Hz) -> ģʽл(->˫)
//   л֣dir_ctrl ȫ̶̹ 0
//   ƵСCNT_500HZ=6 (cnt  0~6)
//                 CNT_10HZ =11(cnt  0~11)
//
// ʾãڷ湤߲δֶ
//   1) ѡ cnt ź -> Ҽ -> Radix -> Unsigned Decimal޷ʮƣ
//   2) leds λź -> Ĭ Radixչλʾ
//
// ͼ飨׶ΣעдӦϵ
//   ͼ1 λ׶      : rst ->ͣleds λΪ 8'h01
//   ͼ2 Ƶл׶  : freq_ctrl 0->1cnt  0~6 ѭ 0~11 ѭ
//   ͼ3 ģʽл׶  : model_set 0->1leds ɵƱ˫Ʋ
//////////////////////////////////////////////////////////////////////////////////

module tb_flowing_lights;

    // ---------------- ź ----------------
    reg        clk;
    reg        rst;
    reg        freq_ctrl;
    reg        dir_ctrl;
    reg        model_set;

    // ---------------- ź ----------------
    wire [7:0] leds;

    // ----------------  DUTСƵ ----------------
    flowing_lights #(
        .CNT_500HZ(24'd6),     // cnt  0~6
        .CNT_10HZ (24'd11)     // cnt  0~11
    ) u_dut (
        .clk      (clk),
        .rst      (rst),
        .freq_ctrl(freq_ctrl),
        .dir_ctrl (dir_ctrl),
        .model_set(model_set),
        .leds     (leds)
    );

    // ---------------- ʱ 100MHz 10ns ----------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------- ׶ʱ ----------------
    // һ 500Hz  = (6+1)*10ns = 70ns 2 ѭ ~ 140ns
    // һ 10Hz   = (11+1)*10ns = 120ns 2 ѭ ~ 240ns
    localparam T_RST   = 30;    // λ
    localparam T_F500  = 160;   // 500Hz ۲ʱ䣨>2 ڣ
    localparam T_F10   = 260;   // 10Hz  ۲ʱ䣨>2 ڣ
    localparam T_MODEL = 400;   // ģʽл۲ʱ

    // ----------------  ----------------
    initial begin
        // ʼֵ
        rst       = 1'b1;
        freq_ctrl = 1'b0;      // 500Hz 
        dir_ctrl  = 1'b0;      // ̶л
        model_set = 1'b0;      // ģʽ

        // ========== ׶ 1λ ==========
        $display("[%0t] === ׶1λʼ (ͼ1) ===", $time);
        #T_RST;
        rst = 1'b0;
        $display("[%0t] === λͷţleds ӦΪ 8'h01 ===", $time);

        // ========== ׶ 2Ƶл 500Hz -> 10Hz ==========
        //  500Hz ۲ cnt 0~6
        $display("[%0t] === ׶2a500Hz ۲ cnt 0~6 (ͼ2) ===", $time);
        #T_F500;

        freq_ctrl = 1'b1;      // е 10Hz 
        $display("[%0t] === ׶2bл 10Hz ۲ cnt 0~11 (ͼ2) ===", $time);
        #T_F10;

        // ========== ׶ 3ģʽл  -> ˫ ==========
        model_set = 1'b1;
        $display("[%0t] === ׶3ģʽл ->˫ (ͼ3) ===", $time);
        #T_MODEL;

        $display("[%0t] ===  ===", $time);
        $stop;
    end

    // ---------------- ѡʮƴӡ cnt ־˶ ----------------
    // ־չclk شӡظ
    always @(posedge clk) begin
        if(!rst)
            $display("[%0t] cnt=%0d (Unsigned Decimal)  freq_ctrl=%b  model_set=%b  leds=%b",
                     $time, cnt, freq_ctrl, model_set, leds);
    end

    //  DUT ڲ cntλʣڴӡ
    wire [23:0] cnt = u_dut.cnt;

endmodule