### 3.2 多路复用器[¶](https://diglogic.p.cs-lab.top/lab1/lab-content/#32)

- 创建工程，工程名为mux；

- **自行编写**并添加设计文件mux.v；

- 添加仿真文件mux_sim.v，代码如下，完成仿真；

  ```
  `timescale 1ns/1ps        
  
  module mux_sim();   
  
      wire en;
      wire mux_sel;
      wire [3:0] input_a;
      wire [3:0] input_b;
      wire [3:0] output_c;
  
      reg [9:0] switch;                                // 中间变量
      assign {en, mux_sel, input_a, input_b} = switch; // 位拼接符{}组合信号
  
      initial    
      begin
          #0 switch = 10'b0_1_0010_0001;   // 2组用例测试：en=0  
          #5 switch = 10'b0_0_0010_0001;
  
          #5 switch = 10'b1_0_0001_0000;   // 4组用例测试：en=1, mux_sel=0，a+b
          #5 switch = 10'b1_0_0001_0001;
          #5 switch = 10'b1_0_1000_0100;
          #5 switch = 10'b1_0_0100_0001;
  
          #5 switch = 10'b1_1_0001_0000;   // 4组用例测试：en=1, mux_sel=1，a-b
          #5 switch = 10'b1_1_0001_0001;
          #5 switch = 10'b1_1_1000_0100;
          #5 switch = 10'b1_1_0100_0001;
          #10 $finish ;                                
      end
  
      mux u_mux (
          .en(en),
          .mux_sel(mux_sel),
          .input_a(input_a),
          .input_b(input_b),
          .output_c(output_c)
      );
  endmodule
  ```

- **自行编写**并添加约束文件，管脚对应关系参考：[外设接口与芯片引脚对应关系表](https://diglogic.p.cs-lab.top/vivado/s4-add-constraints/#4)，并综合实现，生成比特流；

- 将生成的比特流下载到开发板验证，验证步骤参考如下：

  - 测试使能无效：所有拨码开关都往下拨，输入低电平，此时en=0，使能无效，右侧GLD3-0或LD2_3-0四个LED亮。改变输入input_a和input_b，输出不变。
  - 测试a+b：使能对应的开关往上拨en=1，功能选择信号开关往下拨mux_sel=0，SW7-SW0自行调整构造输入数据input_a和input_b，观察GLD3-0或LD2_3-0的情况是否等于input_a + input_b。
  - 测试a-b：使能对应的开关往上拨en=1，功能选择信号开关往上拨mux_sel=1，SW7-SW0自行调整构造输入数据input_a和input_b，观察GLD3-0或LD2_3-0的情况是否等于input_a - input_b。