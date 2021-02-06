all: start

start: test.vcd
	gtkwave test.vcd

test.vcd: a.out
	./a.out

a.out: test.v main.v control_path.v data_path.v
	iverilog test.v main.v control_path.v data_path.v
