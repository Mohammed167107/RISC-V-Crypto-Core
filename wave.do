onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /p_tb/uut/clk
add wave -noupdate -radix hexadecimal /p_tb/uut/rst
add wave -noupdate -radix hexadecimal /p_tb/uut/pc
add wave -noupdate -radix hexadecimal /p_tb/uut/pc_out
add wave -noupdate -radix hexadecimal /p_tb/uut/pc_plus
add wave -noupdate -radix hexadecimal /p_tb/uut/instruction
add wave -noupdate -radix hexadecimal /p_tb/uut/rs1_data
add wave -noupdate -radix hexadecimal /p_tb/uut/rs2_data
add wave -noupdate -radix hexadecimal /p_tb/uut/op2
add wave -noupdate -radix hexadecimal /p_tb/uut/imm_ext
add wave -noupdate -radix hexadecimal /p_tb/uut/rd_data
add wave -noupdate -radix hexadecimal /p_tb/uut/alu_result
add wave -noupdate -radix hexadecimal /p_tb/uut/mem_data_out
add wave -noupdate -radix hexadecimal /p_tb/uut/imm_ext_j
add wave -noupdate -radix hexadecimal /p_tb/uut/imm_ext_b
add wave -noupdate -radix hexadecimal /p_tb/uut/bj_imm
add wave -noupdate -radix hexadecimal /p_tb/uut/pc_plus_bj
add wave -noupdate -radix hexadecimal /p_tb/uut/bj_mux_out
add wave -noupdate -radix hexadecimal /p_tb/uut/jalr_add
add wave -noupdate -radix hexadecimal /p_tb/uut/address_data
add wave -noupdate -radix hexadecimal /p_tb/uut/rg_file/file
add wave -noupdate -radix hexadecimal /p_tb/uut/d_mem/memory
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {231 ps}
