module queue (
    input  clk, rst, apply,
    input  [7:0] in,
    input  [2:0] op,
    output [7:0] first, second, tail,
    output empty,
    output reg valid
);
    reg [79:0] queue;               // 10 элементов в очереди
    reg [3:0] capacity;             // Емкость очереди 

    assign first = queue[7:0];   //"Срез" первых 8 бит - первый элемент
    assign second = queue[15:8]; //"Срез" следующих 8 бит - второй элемент
    assign tail = capacity > 0 ? queue[(capacity-1)*8+:8] : queue[7:0];
    assign empty = capacity > 0 ? 0 : 1;    // Если емкость больше 0, то не пусто

    always @(posedge clk, posedge rst) begin
            if (rst) begin
                capacity <= 0;
                queue <= 0;
                valid <= 1;
            end
            else begin
                if (apply) begin            // Пользователь требует применить операцию
                    case (op)
                       3'd0: begin          // Добавляем число, если элементов меньше 10
                           if (capacity < 10) begin
                               queue[capacity*8+:8] <= in;                      
                               capacity <= capacity + 4'd1;
                           end
                           else valid = 0;
                       end
                       3'd1:begin
                           if (capacity > 0) begin
                               queue <= queue >> 8;                      
                               capacity <= capacity - 4'd1;
                           end
                           else valid = 0;
                       end
                       3'd2, 3'd3, 3'd4, 3'd5, 3'd6: begin
                           if (capacity < 2) valid = 0;
                           else begin
                               queue <= queue >> 16;                          //Очищаем от 2х первых чисел
                               queue[(capacity-2)*8+:8] <= in;                // Подставляем получившийся ответ (сразу работает для многих операций)                        
                               capacity <= capacity - 4'd1;
                           end
                       end
                       default: valid = 0;                                   // Некорректный код операции
                    endcase
                end
            end
    end

endmodule
