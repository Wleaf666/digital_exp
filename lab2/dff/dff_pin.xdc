# ==============================================================================
# Minisys 开发板物理管脚约束文件 (D 触发器实验: dff)
# FPGA 芯片型号: Xilinx Artix-7 xc7a100tfgg484-1
# 电平标准: LVCMOS33
# ==============================================================================

# 100MHz 板载晶振时钟信号输入 (Y18)
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports clk]

# 异步复位信号 clr (按键开关 S1，按下输入为高电平 1)
set_property -dict {PACKAGE_PIN R1  IOSTANDARD LVCMOS33} [get_ports clr]

# 同步使能信号 en (拨码开关 SW7，向上拨为高电平 1)
set_property -dict {PACKAGE_PIN U6  IOSTANDARD LVCMOS33} [get_ports en]

# 数据输入信号 d (拨码开关 SW0，向上拨为高电平 1)
set_property -dict {PACKAGE_PIN W4  IOSTANDARD LVCMOS33} [get_ports d]

# 数据输出信号 q (右侧第0位绿色 LED 灯 GLD0，高电平点亮)
set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33} [get_ports q]

# ==============================================================================
# 备用参考: EGO1 开发板管脚约束 (若使用 EGO1 平台，请取消下方注释并注释上方约束)
# ==============================================================================
# set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports clk]
# set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports clr] # S1/PB1
# set_property -dict {PACKAGE_PIN P5  IOSTANDARD LVCMOS33} [get_ports en]  # SW7
# set_property -dict {PACKAGE_PIN R1  IOSTANDARD LVCMOS33} [get_ports d]   # SW0
# set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports q]   # LD2_0
