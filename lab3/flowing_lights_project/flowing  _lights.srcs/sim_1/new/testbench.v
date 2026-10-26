`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name : tb_flowing_lights
// Description : flowing_lights 仿真
//   仿真顺序：复位 -> 频率切换(500Hz档->10Hz档) -> 模式切换(单灯->双灯)
//   方向切换不体现，dir_ctrl 全程固定 0
//   分频参数调小：CNT_500HZ=6 (cnt 完整覆盖 0~6)
//                 CNT_10HZ =11(cnt 完整覆盖 0~11)
//
// 波形显示设置（在仿真工具波形窗口中手动操作）：
//   1) 选中 cnt 信号 -> 右键 -> Radix -> Unsigned Decimal（无符号十进制）
//   2) leds 及其他多位宽信号 -> 保持默认 Radix（不展开、不逐位显示）
//
// 截图建议（按阶段，注释里写清对应关系）：
//   图1 复位阶段      : rst 高->低，leds 复位为 8'h01
//   图2 频率切换阶段  : freq_ctrl 0->1，cnt 先 0~6 循环，再 0~11 循环
//   图3 模式切换阶段  : model_set 0->1，leds 由单灯变双灯并流动
//////////////////////////////////////////////////////////////////////////////////

module tb_flowing_lights;

    // ---------------- 激励信号 ----------------
    reg        clk;
    reg        rst;
    reg        freq_ctrl;
    reg        dir_ctrl;
    reg        model_set;

    // ---------------- 输出信号 ----------------
    wire [7:0] leds;

    // ---------------- 例化 DUT（调小分频参数） ----------------
    flowing_lights #(
        .CNT_500HZ(24'd6),     // cnt 完整覆盖 0~6
        .CNT_10HZ (24'd11)     // cnt 完整覆盖 0~11
    ) u_dut (
        .clk      (clk),
        .rst      (rst),
        .freq_ctrl(freq_ctrl),
        .dir_ctrl (dir_ctrl),
        .model_set(model_set),
        .leds     (leds)
    );

    // ---------------- 时钟 100MHz（周期 10ns） ----------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------- 阶段时间参数 ----------------
    // 一个 500Hz 周期 = (6+1)*10ns = 70ns，走 2 个完整循环 ~ 140ns
    // 一个 10Hz  周期 = (11+1)*10ns = 120ns，走 2 个完整循环 ~ 240ns
    localparam T_RST   = 30;    // 复位持续
    localparam T_F500  = 160;   // 500Hz 档观察时间（>2 个周期）
    localparam T_F10   = 260;   // 10Hz  档观察时间（>2 个周期）
    localparam T_MODEL = 400;   // 模式切换后观察时间

    // ---------------- 主激励 ----------------
    initial begin
        // 初始值
        rst       = 1'b1;
        freq_ctrl = 1'b0;      // 500Hz 档
        dir_ctrl  = 1'b0;      // 方向固定，不切换
        model_set = 1'b0;      // 单灯模式

        // ========== 阶段 1：复位 ==========
        $display("[%0t] === 阶段1：复位开始 (图1) ===", $time);
        #T_RST;
        rst = 1'b0;
        $display("[%0t] === 复位释放，leds 应为 8'h01 ===", $time);

        // ========== 阶段 2：频率切换 500Hz -> 10Hz ==========
        // 先在 500Hz 档观察 cnt 0~6
        $display("[%0t] === 阶段2a：500Hz 档，观察 cnt 0~6 (图2) ===", $time);
        #T_F500;

        freq_ctrl = 1'b1;      // 切到 10Hz 档
        $display("[%0t] === 阶段2b：切换到 10Hz 档，观察 cnt 0~11 (图2) ===", $time);
        #T_F10;

        // ========== 阶段 3：模式切换 单灯 -> 双灯 ==========
        model_set = 1'b1;
        $display("[%0t] === 阶段3：模式切换 单灯->双灯 (图3) ===", $time);
        #T_MODEL;

        $display("[%0t] === 仿真结束 ===", $time);
        $stop;
    end

    // ---------------- 可选：十进制打印 cnt 便于日志核对 ----------------
    // 仅用于日志，不产生波形展开；clk 上升沿打印，避免重复
    always @(posedge clk) begin
        if(!rst)
            $display("[%0t] cnt=%0d (Unsigned Decimal)  freq_ctrl=%b  model_set=%b  leds=%b",
                     $time, cnt, freq_ctrl, model_set, leds);
    end

    // 引用 DUT 内部 cnt（层次化访问，仅用于打印）
    wire [23:0] cnt = u_dut.cnt;

endmodule