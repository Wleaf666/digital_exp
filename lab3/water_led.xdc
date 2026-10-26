# ==============================================================================
# Minisys 开发板物理管脚约束文件 (实验3: 计数器与可调流水灯 water_led)
# FPGA 芯片型号: Xilinx Artix-7 xc7a100tfgg484-1
# 电平标准: LVCMOS33
# ==============================================================================

# 1. 100MHz 板载晶振时钟信号输入 (Y18)
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports clk]

# 2. 异步复位信号 rst (按键开关 S1，按下输入为高电平 1)
set_property -dict {PACKAGE_PIN R1  IOSTANDARD LVCMOS33} [get_ports rst]

# 3. 频率控制信号 freq_ctrl (拨码开关 SW0，0: 0.002s / 500Hz, 1: 0.1s / 10Hz)
set_property -dict {PACKAGE_PIN W4  IOSTANDARD LVCMOS33} [get_ports freq_ctrl]

# 4. 方向控制信号 dir_ctrl (拨码开关 SW1，0: 循环左移, 1: 循环右移)
set_property -dict {PACKAGE_PIN R4  IOSTANDARD LVCMOS33} [get_ports dir_ctrl]

# 5. 模式选择信号 mode_sel (拨码开关 SW7，0: 连续单灯流动, 1: 连续双灯流动)
set_property -dict {PACKAGE_PIN U6  IOSTANDARD LVCMOS33} [get_ports mode_sel]

# 6. 8 位流水灯输出信号 led[7:0] (右侧 8 个绿色 LED 灯 GLD7 ~ GLD0，高电平点亮)
set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33} [get_ports led[0]]
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33} [get_ports led[1]]
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports led[2]]
set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVCMOS33} [get_ports led[3]]
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33} [get_ports led[4]]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS33} [get_ports led[5]]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports led[6]]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS33} [get_ports led[7]]

# ==============================================================================
# 备用参考: EGO1 开发板管脚约束 (若使用 EGO1 平台，请取消下方注释并注释上方约束)
# ==============================================================================
# set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports clk]
# set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports rst]        # S1 / PB1
# set_property -dict {PACKAGE_PIN R1  IOSTANDARD LVCMOS33} [get_ports freq_ctrl]  # SW0
# set_property -dict {PACKAGE_PIN N4  IOSTANDARD LVCMOS33} [get_ports dir_ctrl]   # SW1
# set_property -dict {PACKAGE_PIN P5  IOSTANDARD LVCMOS33} [get_ports mode_sel]   # SW7
# set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports led[0]]     # LD2_0
# set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33} [get_ports led[1]]     # LD2_1
# set_property -dict {PACKAGE_PIN J3  IOSTANDARD LVCMOS33} [get_ports led[2]]     # LD2_2
# set_property -dict {PACKAGE_PIN H4  IOSTANDARD LVCMOS33} [get_ports led[3]]     # LD2_3
# set_property -dict {PACKAGE_PIN J4  IOSTANDARD LVCMOS33} [get_ports led[4]]     # LD2_4
# set_property -dict {PACKAGE_PIN G3  IOSTANDARD LVCMOS33} [get_ports led[5]]     # LD2_5
# set_property -dict {PACKAGE_PIN G4  IOSTANDARD LVCMOS33} [get_ports led[6]]     # LD2_6
# set_property -dict {PACKAGE_PIN F6  IOSTANDARD LVCMOS33} [get_ports led[7]]     # LD2_7
