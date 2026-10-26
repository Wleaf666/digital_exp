
实验原理
1. 流水灯实现¶
流水灯控制原理如下图，共8个灯，每次只亮1个灯，图中1代表亮灯，0代表不亮。第1s的时候最右边的灯亮，第2s的时候左移到下一个灯，不断移动，到第9s的时候又从最右边的灯开始亮，不断循环。需要间隔为T的流水灯切换控制信号，且间隔T由输入控制。有了间隔为T的流水灯切换控制信号后，还需要生成流水灯显示信号。

第二种模式的示意图如下：

循环移位可以使用拼接符，拼接操作符用大括号{}来表示，用于将多个信号拼接成新的信号，信号间用逗号隔开，例如：
A = 4'b1010 ;
B = 1'b1 ;
Y1= {B, A[3:2], A[0], 4'h3 };  // 结果为Y1='b1_10_0_0011

要实现循环右移的流水灯显示信号，可以使用如下写法，将信号led的最低位移动到最高位，高7位往低位移动1位，不断循环。循环移位也可用其他方式实现，不做限制。
reg [7:0] led;
always @ (posedge clk or posedge rst ) begin
    if(rst) led <= 8'h01;
    else    led <= {led[0], led[7:1]};
end



Warning
不要将计数器分频后的信号作为新的时钟驱动其他模块，而应作为控制信号。分频信号作为新的时钟会使得整个电路有多个时钟，属异步电路。

2. 计数器Verilog实现¶
计数器Verilog实现模板
reg [3:0] cnt;

wire cnt_end = ;   // 结束条件，自行填写 
wire cnt_inc = ;   // 自增条件，自行填写

always @ (posedge clk or posedge rst) begin
    if(rst)          cnt <= 4'h0;       // 复位后计数器清零
    else if(cnt_end) cnt <= 4'h0;       // 计数结束后计数器清零
    else if(cnt_inc) cnt <= cnt + 4'h1; // 累加条件满足时，计数器累加
    else             cnt <= cnt; 
end

以下是一个完整的计数器示例：4bit计数，button有效后启动一轮计数，计数0-9到9停止计数，等待button再次有效重新启动。如果button接的是按键开关，则可以通过按键开关控制计数器的启动。
module counter(
    input wire clk,
    input wire rst,
    input wire button,
    output reg [3:0] cnt
);

reg   cnt_inc;
wire  cnt_end = cnt_inc & (cnt==4'h9);

always @ (posedge clk or posedge rst) begin
    if(rst)          cnt_inc <= 1'b0;          
    else if(button)  cnt_inc <= 1'b1;       
    else if(cnt_end) cnt_inc <= 1'b0;
    else             cnt_inc <= cnt_inc;
end

always @ (posedge clk or posedge rst) begin
    if(rst)          cnt <= 4'h0;          
    else if(cnt_end) cnt <= 4'h0;       
    else if(cnt_inc) cnt <= cnt + 4'h1; 
    else             cnt <= cnt; 
end
endmodule

3. 计数器仿真¶
3.1 仿真时计数值调整¶
从100MHz时钟得到1000Hz、100Hz、20Hz、10Hz等频率，分频系数太大，仿真时间较长，为减少仿真运行时间，通常通过参数例化将对应的计数上限值调小。
上板和仿真用到不同的计数值，如果直接改功能代码，改来改去容易出错，可用参数例化解决。当一个模块被另一个模块引用例化时，高层模块可以对低层模块的参数值进行改写，不用单独为只有参数不同的多个模块再新建文件。
仍以上面的计数器为例，模块定义的时候在输入输出信号前，使用#()和parameter关键词定义参数，参数个数任意，定义的参数可在模块内直接使用。
module counter #(
    parameter CNT_MAX = 9,
    parameter WIDTH   = 4
)
(
    input wire clk,
    input wire rst,
    input wire button,
    output reg [WIDTH - 1:0] cnt
);

reg   cnt_inc;
wire  cnt_end = cnt_inc & (cnt==CNT_MAX);

always @ (posedge clk or posedge rst) begin
    if(rst)          cnt_inc <= 1'b0;          
    else if(button)  cnt_inc <= 1'b1;       
    else if(cnt_end) cnt_inc <= 1'b0;
    else             cnt_inc <= cnt_inc;
end

always @ (posedge clk or posedge rst) begin
    if(rst)          cnt <= {WIDTH{1'b0}};          
    else if(cnt_end) cnt <= {WIDTH{1'b0}};       
    else if(cnt_inc) cnt <= cnt + 1'b1;
    else             cnt <= cnt; 
end
endmodule

例化的时候，将所需要的参数传过去。这样在下板和仿真需要不同的频率，可以不用修改代码而只修改参数。
counter #(10000, 24) u_counter( 
    .clk(clk), 
    .rst(rst), 
    .button(button), 
    .cnt(cnt)
);

3.2 常用仿真按钮¶
如果意外关闭默认波形窗口，则可从主菜单中选择 Window → Waveform（窗口 > 波形）来将其复原。
如下图，在菜单栏下面有一排工具栏，将鼠标放上去会有功能提示，红框中是仿真有关的，常用的是Run For xxms和Relaunch Simulation操作，从左到右的功能分别如下：


Restart（重新启动）：重新从0时刻开始启动现有仿真，需要再点击Run For；
Run All（全部运行）：一直运行仿真到处理完所有event或手动停止仿真；
Run For（运行持续时间）：指定仿真运行时间，后面设定时长数值和单位的两个输入框，每点击一次都在之前的基础上再运行指定时长，直到时间结束或仿真事件结束；
Step（步进）：运行仿真下一行 HDL 源代码为止；
Break（中断）：暂停仿真运行；
Relaunch Simulation（重新启动仿真）：重新编译仿真文件并重新启动仿真，当修改了源代码或者添加了内部信号之后，需要Relaunch。


Restart和Relaunch的区别

Restart：不会重新编译设计，也不会重新加载仿真文件，只会把“仿真时间归零”，重新从 initial/reset 状态开始跑。适合场景：在仿真设置（Simulation Settings）中修改了仿真参数或运行时间，但没有改 HDL 代码，想重新跑一遍波形。
Relaunch：彻底重启仿真进程，重新编译并加载设计再运行。波形窗口会被重置，内部信号需重新添加。使用场景修改了 RTL 或 testbench 源码，需要重新编译+仿真。


3.3 延长仿真时间¶
若计数器值较大，默认的仿真时间不够，输出的led信号看不到变化，需要延长仿真时间。
此处以100MHz分频到10Hz为例做一个说明，将100MHz的频率分频到10Hz，输入时钟需要经历5000_000次上升沿（分频系数的一半），输出才会改变一次。100MHz时钟的周期是10ns，经历5000_000个时钟周期需要50ms（50_000_000ns）之后输出才会变化。而Vivado默认仿真时间是1000ns，显然不够。仿真时可以把计数值或时钟周期调小，以缩短仿真时间。
可以使用Run For功能延长仿真运行时间，如下图所示，先调整好运行时间和单位，再点击Run For，仿真器就会在当前的基础上再运行指定时间长度。

3.4 多位宽信号指定进制显示¶
对于多位宽信号，可以根据需要设置为二进制、十进制、十六进制等不同的进制。


