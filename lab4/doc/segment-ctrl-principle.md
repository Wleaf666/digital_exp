
实验原理
1. 数码管显示原理¶
1.1 数码管连接方式¶

Minisys和EGO1开发板的数码管区别
两者基本原理一样，二极管的连接方式有不同，此处原理以Minisys开发板为例做介绍。
Minisys：共阳极数码管，位选信号和段选信号都是低电平有效。
EGO1：段选、位选信号均为高电平有效。

下图是Minisys开发板上7段数码管单个数码管的组成，8个数码管分成2组，每组4个。以最右侧的为例，单个数码管有7个段及小数点，每个段是一个LED灯，LED灯的阳极接到一起形成共阳极即Common anode，LED灯的阴极接到段控制信号CA、CB、CC、…、CG、DP，其中，CA是A段的阴极，CB是B段的阴极，以此类推。8个数码管相同段的段选信号接在一起，比如8个数码管的A段都接到了CA信号。

每一个数码管上方都有一个使能信号也叫位选信号，控制整个数码管的开关，比如A0信号控制最右侧的数码管。A0通过一个反相器接到数码管共阳极上，当A0为0的时候，整个数码管打开，显示才会受到CA…CG这几个信号的驱动，如果CA为0，A段LED管导通点亮。

1.2 数码管字符编码¶
下图列出了数码管显示0到F时点亮的段。比如显示数字0的时候，除了中间的CG段外其他的段都被点亮了，而数字1只点亮了CB段和CC段。

每个待显示字符的编码计算方法如下：表格第一列是待显示的字符，CA-DP是段信号，最后一列是段信号组合{CA,CB,...,DP}得到的十六进制编码。以Minisys显示字符0和 1为例：字符0只有CG和DP段不亮，对应的段信号为1，其他段信号是0；字符1只有CB和CC段亮，对应段信号是0，其他段是1。其他字符的段信号取值需自行补充完成。编码表的顺序可以自行调整，可以是DP，CG在高位。
// 七段数码管显示编码表（段选低电平有效）
// 字符 | CA | CB | CC | CD | CE | CF | CG | DP | 十六进制
// -----|----|----|----|----|----|----|----|----|--------
//   0  |  0 |  0 |  0 |  0 |  0 |  0 |  1 |  1 | 8'h03
//   1  |  1 |  0 |  0 |  1 |  1 |  1 |  1 |  1 | 8'h9F
//   2  |  0 |  0 |  1 |  0 |  0 |  1 |  0 |  1 | 8'h25


Note
Ego1段选编码表可以在Minisys的基础上按位取反得到，也可以实现的时候直接用按位取反操作符~

可以先用以下代码对编码进行测试：使能信号为0的对应的4个数码管显示字符1，另外四个不显示。调整led_cx的值可依次验证编码。
module led_ctrl_unit (
    output [7:0]  led_en,   // 位选信号
    output [7:0]  led_cx    // 段选信号
);
  assign led_en = 8'b00001111;   // EGO1注意按位取反
  assign led_cx = 8'h9F;         
endmodule

约束文件注意led_cx[7:0]和CA-CG、DP的对应顺序。Minisys开发板数码管约束参考：
# 段选约束 led_cx[7:0] = LED_{CA, CB, ..., DP}
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN F15 } [get_ports led_cx[7]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN F13 } [get_ports led_cx[6]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN F14 } [get_ports led_cx[5]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN F16 } [get_ports led_cx[4]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN E17 } [get_ports led_cx[3]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN C14 } [get_ports led_cx[2]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN C15 } [get_ports led_cx[1]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN E13 } [get_ports led_cx[0]]
# 位选约束，A18连接的最左边的数码管，依次类推
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN A18 } [get_ports led_en[7]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN A20 } [get_ports led_en[6]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN B20 } [get_ports led_en[5]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN E18 } [get_ports led_en[4]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN F18 } [get_ports led_en[3]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN D19 } [get_ports led_en[2]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN E19 } [get_ports led_en[1]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN C19 } [get_ports led_en[0]]

EGO1开发板数码管约束参考：2组数码管的段选信号独立。
# 右侧的4个数码管段选约束，led_cx[7:0] = LED0_{CA, CB, ..., DP}
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN D4 } [get_ports led_cx[7]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN E3 } [get_ports led_cx[6]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN D3 } [get_ports led_cx[5]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN F4 } [get_ports led_cx[4]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN F3 } [get_ports led_cx[3]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN E2 } [get_ports led_cx[2]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN D2 } [get_ports led_cx[1]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN H2 } [get_ports led_cx[0]]
# 左侧的4个数码管段选约束，led_cx1[7:0] = LED1_{CA, CB, ..., DP}
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN B4 } [get_ports led_cx1[7]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN A4 } [get_ports led_cx1[6]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN A3 } [get_ports led_cx1[5]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN B1 } [get_ports led_cx1[4]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN A1 } [get_ports led_cx1[3]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN B3 } [get_ports led_cx1[2]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN B2 } [get_ports led_cx1[1]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN D5 } [get_ports led_cx1[0]]
# 位选约束，G2连接的最左边的数码管，依次类推
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN G2 } [get_ports led_en[7]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN C2 } [get_ports led_en[6]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN C1 } [get_ports led_en[5]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN H1 } [get_ports led_en[4]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN G1 } [get_ports led_en[3]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN F1 } [get_ports led_en[2]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN E1 } [get_ports led_en[1]]
set_property -dict { IOSTANDARD LVCMOS33 PACKAGE_PIN G6 } [get_ports led_en[0]]


2. 数码管动态显示时序¶
要让8个数码管显示不同的数字，使能信号（A0-A7）和段信号（CA…CG）需依次被驱动。举个例子，在数码管A0上显示数字3而数码管A1上显示数字9，先把 CA…CG 设置为显示数字3，并拉低A0信号，再把CA…CG设置为显示数字9并拉高A0拉低A1。每次只能打开一个数码管，如果同时打开，数码管显示的内容完全一样，等同于单个数码管。
从现象看8个数码管同时显示，实际数码管是轮询工作，每一时刻只有一个数码管在亮，类似于流水灯的实验，当流动的频率足够快，由于人眼的视觉暂留效应，就看不出闪烁了，每个数码管点亮1-2ms，8个数码管轮流点亮，整屏刷新周期约8-16ms。
故需要很好地控制位使能信号A7-A0，并在对应位选信号有效时，将CA...CG信号切换为待显示的值。下图为数码管动态显示"10210002"的位控制信号led_en和段控制信号led_cx的时序，其中，led_en[7:0]分别接数码管A7-A0信号，led_cx[7:0]分别接数码管{CA,CB,CC,...,DP}。led_en和led_cx的变化周期是1-2ms，即动态扫描频率500-1000Hz。Verilog实现的电路能够实现图示的时序，就能正常控制数码管显示。




本实验功能稍多，同学们在实现的时候，应先做一下功能划分，从基础的功能开始实现，而不要一开始就把所有的功能一股脑写到一个文件，功能越多越容易出错也越难debug。
先把数码管控制器的核心控制逻辑作为一个单独的模块，建议按照以下的接口实现，先能稳定地显示0x01234567或个人学号后8位。以下模块本身不处理显示的数据，只管接收数据。后续实验还会用到数码管，对模块做一个好的封装方便后期的复用。
module led_ctrl_unit (
    input wire rst,
    input wire clk,
    input wire [31:0] display,  // 待显示的8个十六进制字符
    output reg [7:0]  led_en,   // 位选信号
    output reg [7:0]  led_cx    // 段选信号，EGO1段选信号需16位或2组8位
);

endmodule


根据以上接口完成数码管核心控制器的逻辑并测试通过后，再添加其他模块实现按键计数、消抖、十进制计数器，然后在顶层模块例化这些子模块，把实验要求显示的数据接到display。
3. 按键启停和计数：边沿检测¶
同一个按键开关既能启动，又能暂停，不仅要判断按键是否按下，还要记录按键按下代表的状态。不能将button信号作为上升沿触发的敏感信号，
下面这种是很不规范的写法，敏感信号列表中的边沿触发除了时钟和复位信号，不能出现其他信号。而是检测按键信号是否出现上升沿或者下降沿即边沿检测。
always @(posedge button)  // 不规范的写法
begin 

end

按键计数同样需要用到边沿检测。若按键被按下，则输入信号由低电平变化到高电平，产生一个上升沿。对于按键按下的次数统计，只要记录上升沿个数即可。将边沿检测后的输出信号作为计数器计数的控制信号，当检测到边沿时，计数条件成立，计数器变量+1即可实现边沿计数。
那要怎么实现信号的边沿检测？边沿检测将输入信号的高低电平变化转化为脉冲信号，有上升沿检测、下降沿检测以及双边沿检测。根据是否与时钟同步，分为同步检测与异步检测，实验仅考虑同步检测。对于同步检测，通过比较输入信号在相邻两个时钟周期内的电平，从而判断是否发生了电平变化。
如下图所示，位置1的时候，输入信号为低电平，在下一个时钟上升沿，输入信号为高电平，输入信号有上升沿变化。同样分别对比位置3和4的信号，可以检测到信号的下降沿。如果信号变化太快，在一个时钟周期内就完成变化，确实会检测不到。实验当中，时钟频率是100MHz远高于按键按下的频率，不会丢失检测。




怎么得到信号在相邻两个时钟周期的值？寄存器的存储功能可以帮助实现，且有多种方式。

方式一：只用一个寄存器，如下图所示，寄存器的输出是上一个时钟周期的值，恰好延迟一个时钟周期，再与signal当前的值做对比判断是上升沿还是下降沿。最终的输出直接与输入有关，可以检测到不足一个时钟周期的跳变，输入信号有跳变也能立即检测到，但也容易带来毛刺不稳定。



对应的信号时序如下：sig_r0比signal延迟一个时钟周期，signal有上升沿可以立即检测出。无论signal的高电平持续多长，pos_edge都只有一个时钟周期。

对应的verilog实现如下：
module edge_detect(
    input             clk,
    input             rst,
    input             signal,  
    output            pos_edge
);

reg sig_r0;

always @(posedge clk)
begin
    if(rst) sig_r0 <= 1'b0;
    else    sig_r0 <= signal;
end

assign pos_edge = ~sig_r0 & signal;



方式二：两个寄存器级联，signal经一个寄存器输出得到sig_r0，sig_r0再经一个寄存器输出得到sig_r1，两个寄存器的输出信号也是隔了一个时钟周期。最终两个寄存器输出sig_r0和sig_r1进行逻辑操作。比起方式一输出更稳定，但响应没有方式一快，信号signal有边沿跳变1个时钟周期后才能检测到。



上面用寄存器传输信号的方式也叫打拍，不改变信号的变化过程，仅对信号延迟一个时钟周期，用一个寄存器是对信号打一拍，用两个寄存器是打两拍。级联的寄存器越多，越可以减少亚稳态发生的概率，提升系统的稳定性，但也消耗了更多电路资源。因为signal直接由按键输入引脚而来，很可能落在时钟上升沿的过程，导致出现亚稳态。
请根据方式二两个寄存器级联的电路结构实现边沿检测，进一步完成按键计数和按键启停。

4. 按键消抖¶

Minisys开发板按键开关电路连接如下

对于实验中用的按键开关和拨码开关，属于机械部件，往往存在抖动，导致输入的信号有很多干扰，如下图所示。如果直接对输入进行计数，一次按键，将会触发多次计数，大家可以先尝试无消抖的计数。



对于按键输入，往往会进行消抖处理。通常利用前后抖动时长5-15ms，中间稳态时长20ms以上（稳态时长跟按键按下的时间长短有关）这两个特征进行处理。Verilog进行按键消抖常见有以下方法，实验不做限制，只要实现稳定计数即可。

延时法，判断前后抖动的时长。设置一个计数器，检测到按键产生的边沿信号（上升沿或下降沿）时开始计数，计数满10ms再将按键输入赋值给输出，中间抖动产生的边沿信号计数器不清零。
计数器法，判断稳态信号的时长。设置一个计数器，检测到按键边沿时开始计数，过程中每检测到边沿，计数器清零重新开始计数，即找到最后一次抖动的时间再正式开启计数，计数满10ms-20ms再将按键输入赋值给输出，抖动信号因时间过短会直接过滤掉。类似延时法但更准确。
移位寄存器法，过滤掉持续时间小于N个时钟周期的抖动。将按键信号接入到N个级联的寄存器，通过寄存器保存按键历史状态，将N个寄存器输出相与作为最终的输出，实现简单但不够准确，效果与级联的寄存器数量有关。
状态机法，支持IDLE、PRESS_WAIT、PRESS_CONFIRM、RELEASE_WAIT等状态，适合做短按/长按识别。


