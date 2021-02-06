module test();
    reg [7:0] x;
    reg [1:0] on;
    reg start, clk, rst;
    main testing(.clk(clk),.rst(rst),.start(start),.on(on),.x(x));
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);
        #80 $finish;
    end

    initial begin
        rst = 0;
        clk = 1;
        start = 0;
        x = 0;
        on = 0;
    end

    always #1 clk = !clk;
    initial begin
        #2 rst = 1;
        #3 rst = 0;
    end

    initial begin
        // Begin Режим счета
        #6
        on = 2'd2;
        start = 1'd1; // Начинаем
        #11           // 5 раз уменьшаем s ()
        start = 0;    // Переходим в выключенный режим
        on = 2'd0;    // В выключенном режиме пока никуда не идем (если не уберем - снова зайдет в режим)
        // End   Режим счета
        // Begin Режим обновления
        #6
        on = 2'd3;
        x = 8'd64;
        #8
        on = 0;       // В выключенном режиме пока никуда не идем (если не уберем - снова зайдет в режим)
        // End   Режим обновления
        // Begin Режим перечисления
        #6
        on = 2'd1;
        #4
        start = 1'd1; // Начинаем
        #16           // Ждём 4 разряда по 4 такта -> переходим в выключенный режим
        on = 2'd0;    // В выключенном режиме пока никуда не идем (если не уберем - снова зайдет в режим)
        // End   Режим перечисления
    end

endmodule
