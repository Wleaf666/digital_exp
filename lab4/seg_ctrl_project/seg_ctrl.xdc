# ==============================================================================
# Minisys 开发板物理管脚约束文件 (实验4: 数码管控制器 seg_ctrl_top)
# FPGA 芯片型号: Xilinx Artix-7 xc7a100tfgg484-1
# 电平标准: LVCMOS33
# ==============================================================================

# 1. 100MHz 板载晶振系统主时钟输入
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports clk]

# 2. 异步全局复位信号 rst (轻触按键 S1，按下输入高电平 1)
set_property -dict { PACKAGE_PIN R1  IOSTANDARD LVCMOS33 } [get_ports rst]

# 3. 显示模式切换控制信号 sw0 (拨码开关 SW0，0: 模式2.2指定内容, 1: 模式2.1学号后8位)
set_property -dict { PACKAGE_PIN W4  IOSTANDARD LVCMOS33 } [get_ports sw0]

# 4. 0.1s 定时计数器启停控制按键 btn_s2 (轻触按键 S2，点按一次暂停，再按继续)
set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports btn_s2]

# 5. 按键计数测试按键 btn_s3 (轻触按键 S3，每按一次触发计数)
set_property -dict { PACKAGE_PIN P5  IOSTANDARD LVCMOS33 } [get_ports btn_s3]

# 6. 数码管位选信号 led_en[7:0] (共阳极低电平使能，A18连接最左边 DK7，依次类推)
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports {led_en[7]}]
set_property -dict { PACKAGE_PIN A20 IOSTANDARD LVCMOS33 } [get_ports {led_en[6]}]
set_property -dict { PACKAGE_PIN B20 IOSTANDARD LVCMOS33 } [get_ports {led_en[5]}]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports {led_en[4]}]
set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports {led_en[3]}]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports {led_en[2]}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {led_en[1]}]
set_property -dict { PACKAGE_PIN C19 IOSTANDARD LVCMOS33 } [get_ports {led_en[0]}]

# 7. 数码管段选信号 led_cx[7:0] = {CA, CB, CC, CD, CE, CF, CG, DP} (低电平点亮)
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports {led_cx[7]}]
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 } [get_ports {led_cx[6]}]
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports {led_cx[5]}]
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports {led_cx[4]}]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 } [get_ports {led_cx[3]}]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports {led_cx[2]}]
set_property -dict { PACKAGE_PIN C15 IOSTANDARD LVCMOS33 } [get_ports {led_cx[1]}]
set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 } [get_ports {led_cx[0]}]

# ==============================================================================
# 备用参考: EGO1 开发板数码管管脚约束 (若使用 EGO1 平台可参考对应修改)
# ==============================================================================
# set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports clk]
# set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports rst]     # S1 / PB1
# set_property -dict { PACKAGE_PIN R1  IOSTANDARD LVCMOS33 } [get_ports sw0]     # SW0
# set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports btn_s2]  # S2 / PB2
# set_property -dict { PACKAGE_PIN V1  IOSTANDARD LVCMOS33 } [get_ports btn_s3]  # S3 / PB3
# 位选引脚: G2(DK7), C2(DK6), C1(DK5), H1(DK4), G1(DK3), F1(DK2), E1(DK1), G6(DK0)
