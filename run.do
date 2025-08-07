vlib work
vsim -voptargs="+acc" work.SPI_Wrapper_tb 
add wave *
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/clk
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/CHECK_READ
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/counter
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/current
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/IDLE
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/MISO
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/MOSI
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/next
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/parallel_data
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/READ_ADD
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/READ_DATA
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/rst_n
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/rx_data
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/rx_valid
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/SS_n
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/start_tx
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/tx_bit_cnt
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/tx_data
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/tx_shift_reg
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/tx_valid
add wave -position end  sim:/SPI_Wrapper_tb/uut/SPI/WRITE
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/ADDR_SIZE
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/address
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/clk
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/data
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/din
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/dout
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/mem
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/MEM_DEPTH
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/MEM_WIDTH
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/rst_n
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/rx_valid
add wave -position end  sim:/SPI_Wrapper_tb/uut/RAM/tx_valid
run -all
#quit -sim

