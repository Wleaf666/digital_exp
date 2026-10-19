# ==============================================================================
# Minisys 开发板物理管脚约束文件 (8位×8深度 寄存器文件实验: reg8file)
# FPGA 芯片型号: Xilinx Artix-7 xc7a100tfgg484-1
# 电平标准: LVCMOS33
# ==============================================================================

# 1. 100MHz 板载晶振时钟信号输入 (Y18)
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports clk]

# 2. 异步全局复位信号 clr (按键开关 S1，按下输入为高电平 1)
set_property -dict {PACKAGE_PIN R1  IOSTANDARD LVCMOS33} [get_ports clr]

# 3. 同步写使能信号 en (最左侧拨码开关 SW23，向上拨为高电平 1)
set_property -dict {PACKAGE_PIN Y9  IOSTANDARD LVCMOS33} [get_ports en]

# 4. 写寄存器编号选择 wsel[2:0] (拨码开关 SW20, SW19, SW18)
set_property -dict {PACKAGE_PIN Y8  IOSTANDARD LVCMOS33} [get_ports wsel[2]]
set_property -dict {PACKAGE_PIN AB8 IOSTANDARD LVCMOS33} [get_ports wsel[1]]
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS33} [get_ports wsel[0]]

# 5. 读寄存器编号选择 rsel[2:0] (拨码开关 SW17, SW16, SW15)
set_property -dict {PACKAGE_PIN V8  IOSTANDARD LVCMOS33} [get_ports rsel[2]]
set_property -dict {PACKAGE_PIN V9  IOSTANDARD LVCMOS33} [get_ports rsel[1]]
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS33} [get_ports rsel[0]]

# 6. 待写入数据输入 d[7:0] (拨码开关 SW7 ~ SW0)
set_property -dict {PACKAGE_PIN U6  IOSTANDARD LVCMOS33} [get_ports d[7]]
set_property -dict {PACKAGE_PIN W5  IOSTANDARD LVCMOS33} [get_ports d[6]]
set_property -dict {PACKAGE_PIN W6  IOSTANDARD LVCMOS33} [get_ports d[5]]
set_property -dict {PACKAGE_PIN U5  IOSTANDARD LVCMOS33} [get_ports d[4]]
set_property -dict {PACKAGE_PIN T5  IOSTANDARD LVCMOS33} [get_ports d[3]]
set_property -dict {PACKAGE_PIN T4  IOSTANDARD LVCMOS33} [get_ports d[2]]
set_property -dict {PACKAGE_PIN R4  IOSTANDARD LVCMOS33} [get_ports d[1]]
set_property -dict {PACKAGE_PIN W4  IOSTANDARD LVCMOS33} [get_ports d[0]]

# 7. 读出数据显示输出 q[7:0] (右侧 8 个绿色 LED 灯 GLD7 ~ GLD0，高电平点亮)
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS33} [get_ports q[7]]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports q[6]]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS33} [get_ports q[5]]
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33} [get_ports q[4]]
set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVCMOS33} [get_ports q[3]]
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports q[2]]
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33} [get_ports q[1]]
set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33} [get_ports q[0]]

# ==============================================================================
# 备用参考: EGO1 开发板管脚约束 (若使用 EGO1 平台，请取消下方注释并注释上方约束)
# ==============================================================================
# set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports clk]
# set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports clr]      # S1/PB1
# set_property -dict {PACKAGE_PIN P5  IOSTANDARD LVCMOS33} [get_ports en]       # SW7
# set_property -dict {PACKAGE_PIN P4  IOSTANDARD LVCMOS33} [get_ports wsel[2]]  # SW6
# set_property -dict {PACKAGE_PIN P3  IOSTANDARD LVCMOS33} [get_ports wsel[1]]  # SW5
# set_property -dict {PACKAGE_PIN P2  IOSTANDARD LVCMOS33} [get_ports wsel[0]]  # SW4
# set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports rsel[2]]  # SW3
# set_property -dict {PACKAGE_PIN M4  IOSTANDARD LVCMOS33} [get_ports rsel[1]]  # SW2
# set_property -dict {PACKAGE_PIN N4  IOSTANDARD LVCMOS33} [get_ports rsel[0]]  # SW1
# set_property -dict {PACKAGE_PIN T5  IOSTANDARD LVCMOS33} [get_ports d[0]]     # DIP SW0
# set_property -dict {PACKAGE_PIN T3  IOSTANDARD LVCMOS33} [get_ports d[1]]     # DIP SW1
# set_property -dict {PACKAGE_PIN R3  IOSTANDARD LVCMOS33} [get_ports d[2]]     # DIP SW2
# set_property -dict {PACKAGE_PIN V4  IOSTANDARD LVCMOS33} [get_ports d[3]]     # DIP SW3
# set_property -dict {PACKAGE_PIN V5  IOSTANDARD LVCMOS33} [get_ports d[4]]     # DIP SW4
# set_property -dict {PACKAGE_PIN V2  IOSTANDARD LVCMOS33} [get_ports d[5]]     # DIP SW5
# set_property -dict {PACKAGE_PIN U2  IOSTANDARD LVCMOS33} [get_ports d[6]]     # DIP SW6
# set_property -dict {PACKAGE_PIN U3  IOSTANDARD LVCMOS33} [get_ports d[7]]     # DIP SW7
# set_property -dict {PACKAGE_PIN F6  IOSTANDARD LVCMOS33} [get_ports q[7]]     # LD2_7
# set_property -dict {PACKAGE_PIN G4  IOSTANDARD LVCMOS33} [get_ports q[6]]     # LD2_6
# set_property -dict {PACKAGE_PIN G3  IOSTANDARD LVCMOS33} [get_ports q[5]]     # LD2_5
# set_property -dict {PACKAGE_PIN J4  IOSTANDARD LVCMOS33} [get_ports q[4]]     # LD2_4
# set_property -dict {PACKAGE_PIN H4  IOSTANDARD LVCMOS33} [get_ports q[3]]     # LD2_3
# set_property -dict {PACKAGE_PIN J3  IOSTANDARD LVCMOS33} [get_ports q[2]]     # LD2_2
# set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33} [get_ports q[1]]     # LD2_1
# set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports q[0]]     # LD2_0
