set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports rst]
set_property -dict {PACKAGE_PIN T4  IOSTANDARD LVCMOS33} [get_ports uart_tx]
