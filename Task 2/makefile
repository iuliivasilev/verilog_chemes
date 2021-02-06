all: start

start: main.vcd
	gtkwave main.vcd

main.vcd: a.out
	./a.out

a.out: main.v queue.v test.v
	iverilog main.v queue.v test.v
