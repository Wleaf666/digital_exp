# 实验1：Vivado使用与组合电路

本实验为哈尔滨工业大学（深圳）《数字逻辑设计》课程的第一次实验，重点掌握基于 Xilinx Vivado 的数字系统设计流程，包括工程创建、Verilog HDL 组合逻辑设计、Testbench 仿真验证、XDC 物理引脚约束编写、逻辑综合实现、比特流生成以及在 Minisys FPGA 开发板上的硬件测试。

---

## 一、实验目的

1. 熟悉 Xilinx Vivado 集成开发环境的设计流程与基本操作（添加设计源文件、仿真激励、物理约束、逻辑综合、实现与比特流下载）；
2. 掌握使用 Verilog HDL 行为级描述组合逻辑电路的基本语法与规范；
3. 学习编写 Testbench 仿真测试激励，掌握 Vivado Simulator (XSim) 观察与分析仿真波形的方法；
4. 学习 XDC 物理约束文件的编写，掌握 FPGA 芯片管脚与开发板外设（拨码开关、LED 等）的电气映射；
5. 掌握在 Minisys (Artix-7) 实验板上下载比特流并进行硬件测试验证的方法。

---

## 二、实验内容与逻辑设计

### 2.1 任务一：3-8 译码器 (decoder_38)
- **功能说明**：实现类似 74HC138 芯片功能的 3-8 译码器。包含 3 位使能信号 `en[2:0]` 与 3 位输入数据 `data_in[2:0]`。
- **使能逻辑**：当且仅当 `en == 3'b100` 时使能有效；使能无效时，输出 `data_out[7:0]` 强制为高电平 `8'hFF`。
- **真值表（使能有效 en = 3'b100 时）**：

| data_in[2:0] | data_out[7:0] (低电平有效) | 对应点亮 LED (GLD7~GLD0) |
| :---: | :---: | :---: |
| `000` | `11111110` (8'hFE) | GLD0 灭，其余亮 |
| `001` | `11111101` (8'hFD) | GLD1 灭，其余亮 |
| `010` | `11111011` (8'hFB) | GLD2 灭，其余亮 |
| `011` | `11110111` (8'hF7) | GLD3 灭，其余亮 |
| `100` | `11101111` (8'hEF) | GLD4 灭，其余亮 |
| `101` | `11011111` (8'hDF) | GLD5 灭，其余亮 |
| `110` | `10111111` (8'hBF) | GLD6 灭，其余亮 |
| `111` | `01111111` (8'h7F) | GLD7 灭，其余亮 |

---

### 2.2 任务二：带算术运算的可使能多路复用器 (mux)
- **功能说明**：设计一个 2 输入 4 位带使能控制和加减算术功能的多路复用器。
- **接口信号定义**：
  ```verilog
  module mux (
      input  wire       en,          // 1位使能信号，高有效
      input  wire       mux_sel,     // 1位选择信号：0选通加法，1选通减法
      input  wire [3:0] input_a,     // 4位输入操作数a
      input  wire [3:0] input_b,     // 4位输入操作数b
      output reg  [3:0] output_c     // 4位输出结果，驱动LED显示
  );
  ```
- **核心控制真值表**：

| 使能 en | 选择 mux_sel | 操作数 input_a | 操作数 input_b | 输出 output_c | 硬件表现 |
| :---: | :---: | :---: | :---: | :---: | :--- |
| `0` | `x` (0/1) | `xxxx` | `xxxx` | `4'b1111` (4'hF) | 使能无效关断，GLD3~0 全亮 |
| `1` | `0` | `a` | `b` | `input_a + input_b` | 选通加法运算，LED 显示二进制和 |
| `1` | `1` | `a` | `b` | `input_a - input_b` | 选通减法运算，LED 显示二进制差 |

- **行为级设计源码 (`mux.v`)**：
  ```verilog
  `timescale 1ns / 1ps

  module mux (
      input  wire       en,          // 1位使能
      input  wire       mux_sel,     // 1位选择信号
      input  wire [3:0] input_a,     // 4位输入数据a
      input  wire [3:0] input_b,     // 4位输入数据b
      output reg  [3:0] output_c     // 4位输出数据，驱动LED显示
  );

  always @ (*) begin
      if (en == 1'b0) begin
          output_c = 4'b1111;
      end
      else begin
          if (mux_sel == 1'b1) begin
              output_c = input_a - input_b;
          end 
          else begin
              output_c = input_a + input_b;
          end
      end
  end

  endmodule
  ```

---

## 三、引脚分配与物理约束 (pin.xdc)

在 Minisys 开发板（Xilinx Artix-7 `xc7a100tfgg484-1`）上，采用拨码开关输入激励，输出连接至板载绿色 LED：

| 信号端口 | 位宽 | 对应 FPGA 引脚 | 电平标准 | 开发板器件标识 | 功能映射说明 |
| :--- | :---: | :---: | :---: | :--- | :--- |
| `en` | 1 | `Y9` | LVCMOS33 | 拨码开关 SW23 | 模块总使能开关（向上=1有效，向下=0关断） |
| `mux_sel` | 1 | `W9` | LVCMOS33 | 拨码开关 SW22 | 运算选择开关（向上=1减法，向下=0加法） |
| `input_a[3]` | 1 | `T5` | LVCMOS33 | 拨码开关 SW3 | 操作数 a 最高位（Bit 3） |
| `input_a[2]` | 1 | `T4` | LVCMOS33 | 拨码开关 SW2 | 操作数 a 次高位（Bit 2） |
| `input_a[1]` | 1 | `R4` | LVCMOS33 | 拨码开关 SW1 | 操作数 a 次低位（Bit 1） |
| `input_a[0]` | 1 | `W4` | LVCMOS33 | 拨码开关 SW0 | 操作数 a 最低位（Bit 0） |
| `input_b[3]` | 1 | `U6` | LVCMOS33 | 拨码开关 SW7 | 操作数 b 最高位（Bit 3） |
| `input_b[2]` | 1 | `W5` | LVCMOS33 | 拨码开关 SW6 | 操作数 b 次高位（Bit 2） |
| `input_b[1]` | 1 | `W6` | LVCMOS33 | 拨码开关 SW5 | 操作数 b 次低位（Bit 1） |
| `input_b[0]` | 1 | `U5` | LVCMOS33 | 拨码开关 SW4 | 操作数 b 最低位（Bit 0） |
| `output_c[3]` | 1 | `E21` | LVCMOS33 | 发光二极管 GLD3 | 运算结果最高位指示（Bit 3） |
| `output_c[2]` | 1 | `D22` | LVCMOS33 | 发光二极管 GLD2 | 运算结果次高位指示（Bit 2） |
| `output_c[1]` | 1 | `E22` | LVCMOS33 | 发光二极管 GLD1 | 运算结果次低位指示（Bit 1） |
| `output_c[0]` | 1 | `A21` | LVCMOS33 | 发光二极管 GLD0 | 运算结果最低位指示（Bit 0） |

---

## 四、仿真激励与时序波形分析

仿真测试平台 `mux_sim.v` 通过 10 位位拼接变量 `switch = {en, mux_sel, input_a, input_b}` 注入测试激励：

1. **阶段一：使能无效封锁阶段（0 ~ 10 ns）**
   - 0~5 ns：`switch = 10'b0_1_0010_0001`（`en=0`, `mux_sel=1`, $a=2, b=1$）；
   - 5~10 ns：`switch = 10'b0_0_0010_0001`（`en=0`, `mux_sel=0`, $a=2, b=1$）；
   - **分析**：尽管输入与选择信号变化，因 `en=0`，输出强制稳定为 `output_c = 4'hf`（全高电平），验证了使能的最高优先级关断控制。
2. **阶段二：加法运算测试阶段（10 ~ 30 ns，en=1, mux_sel=0）**
   - 10~15 ns：$a=1, b=0 \implies output\_c = 1$；
   - 15~20 ns：$a=1, b=1 \implies output\_c = 2$；
   - 20~25 ns：$a=8, b=4 \implies output\_c = 12$（十六进制 `0xC`）；
   - 25~30 ns：$a=4, b=1 \implies output\_c = 5$；
   - **分析**：加法通道准确选通，输出波形稳定且数值计算完全正确。
3. **阶段三：减法运算测试阶段（30 ~ 50 ns，en=1, mux_sel=1）**
   - 30~35 ns：$a=1, b=0 \implies output\_c = 1$；
   - 35~40 ns：$a=1, b=1 \implies output\_c = 0$；
   - 40~45 ns：$a=8, b=4 \implies output\_c = 4$；
   - 45~50 ns：$a=4, b=1 \implies output\_c = 3$；
   - **分析**：30 ns 时刻切换为减法通路，差值运算与激励严格对应，组合逻辑无毛刺。

---

## 五、硬件上板实测验证步骤与三种工况

将生成的比特流下载至 Minisys 开发板，保持正面向上、拨码开关置于底部：

### 1. 工况一：使能无效测试
- **操作**：将 SW23 (`en`) 拨至下方低电平 `0`，SW22 (`mux_sel`) 拨至下方 `0`，SW3~SW0 拨为 `0001`（$a=1$），SW7~SW4 拨为 `0000`（$b=0$）。
- **现象**：右侧 4 个绿色 LED（GLD3~GLD0）全亮，输出取值为 `4'b1111`（`0xF`）。此时任意拨动 SW7~SW0 改变输入，LED 状态保持全亮不变，验证了关断特性。

### 2. 工况二：加法测试（$a + b$）
- **操作**：SW23 (`en`) 拨至上方高电平 `1`，SW22 (`mux_sel`) 拨至下方低电平 `0`（选通加法）。输入设置 $a = 4'b0001$（SW0 上拨，十进制 1），$b = 4'b1001$（SW7、SW4 上拨，十进制 9）。
- **现象**：预期运算结果 $1 + 9 = 10$（`4'b1010`）。实测板载 LED 状态为 GLD3 亮、GLD2 灭、GLD1 亮、GLD0 灭，输出精确为 `4'b1010`（`0xA`），验证加法功能正常。

### 3. 工况三：减法测试（$a - b$）
- **操作**：SW23 (`en`) 拨至上方高电平 `1`，SW22 (`mux_sel`) 拨至上方高电平 `1`（选通减法）。输入设置 $a = 4'b1001$（SW3、SW0 上拨，十进制 9），$b = 4'b0001$（SW4 上拨，十进制 1）。
- **现象**：预期运算结果 $9 - 1 = 8$（`4'b1000`）。实测板载 LED 仅 GLD3 亮，GLD2~GLD0 熄灭，输出精确为 `4'b1000`（`0x8`），验证减法功能正常。

---

## 六、交付文件与提交规范

按照课程提交要求（打包为 `submission.zip` 提交至 HITSZ Grader 平台）：
- `mux.v`：多路复用器 Verilog 设计代码
- `pin.xdc`：Xilinx Artix-7 物理管脚与电平约束
- `report.pdf`：实验报告 PDF 文档（包含详细测试说明与电路分析）
- `submission.zip`：提交归档压缩包
