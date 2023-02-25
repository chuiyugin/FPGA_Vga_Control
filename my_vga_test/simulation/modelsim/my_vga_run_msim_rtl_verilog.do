transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {d:/altera/13.1/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {d:/altera/13.1/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {d:/altera/13.1/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {d:/altera/13.1/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {d:/altera/13.1/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/cycloneive_ver
vmap cycloneive_ver ./verilog_libs/cycloneive_ver
vlog -vlog01compat -work cycloneive_ver {d:/altera/13.1/quartus/eda/sim_lib/cycloneive_atoms.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src {E:/Quartus_FPGA_learning/my_vga_test/src/data_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/wrfifo.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/sdram_top.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/sdram_para.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/sdram_fifo_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/sdram_controller.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/rdfifo.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sd_ctrl_top {E:/Quartus_FPGA_learning/my_vga_test/src/sd_ctrl_top/sd_write.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sd_ctrl_top {E:/Quartus_FPGA_learning/my_vga_test/src/sd_ctrl_top/sd_read.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sd_ctrl_top {E:/Quartus_FPGA_learning/my_vga_test/src/sd_ctrl_top/sd_init.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sd_ctrl_top {E:/Quartus_FPGA_learning/my_vga_test/src/sd_ctrl_top/sd_ctrl_top.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src {E:/Quartus_FPGA_learning/my_vga_test/src/key_filter.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src {E:/Quartus_FPGA_learning/my_vga_test/src/vga_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src {E:/Quartus_FPGA_learning/my_vga_test/src/uart_rx.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src {E:/Quartus_FPGA_learning/my_vga_test/src/my_vga.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/ip_core/rom_pic {E:/Quartus_FPGA_learning/my_vga_test/ip_core/rom_pic/rom_pic.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src {E:/Quartus_FPGA_learning/my_vga_test/src/vga_pic.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/ip_core/clk_gen {E:/Quartus_FPGA_learning/my_vga_test/ip_core/clk_gen/clk_gen.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/db {E:/Quartus_FPGA_learning/my_vga_test/db/clk_gen_altpll.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/sdram_data.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/sdram_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/src/sdram {E:/Quartus_FPGA_learning/my_vga_test/src/sdram/sdram_cmd.v}

vlog -vlog01compat -work work +incdir+E:/Quartus_FPGA_learning/my_vga_test/sim {E:/Quartus_FPGA_learning/my_vga_test/sim/tb_my_vga.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_my_vga

add wave *
view structure
view signals
run 1 us
