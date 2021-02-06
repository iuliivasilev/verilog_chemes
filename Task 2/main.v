module main (
    input clk, rst, apply,
    input  [7:0] in,
    input  [2:0] op,
    output [7:0] tail,
    output empty, valid
);
    reg [7:0] inop;             // Результат выполнения операций
    reg  valop;                 // Корректность деления

    wire [7:0] first, second;   // Первый и второй элементы (формируются изнутри очереди)
    wire valq;                  // Корректность очереди

    queue queue_(
        .clk(clk), .rst(rst), .apply(apply), .in(inop), .op(op),
        .first(first), .second(second), .tail(tail), .empty(empty), .valid(valq)
    );


    assign valid = valop & valq;  // корректно если очередь и операция корректны

    always @(posedge clk, posedge rst) begin
        if (rst) valop <= 1;                               // Сброс -> Всё корректно
        else begin
            case (op)
                3'd5,3'd6: if (first == 0 && apply) valop <= 0; // Некорректно: деление на 0
            endcase
        end
    end

    always @(*) begin
        case (op)
            3'd2: inop = first + second; 
            3'd3: inop = first - second;
            3'd4: inop = first * second; 
            3'd5: inop = second / first; 
            3'd6: inop = second % first; 
            default: inop = in;
        endcase
    end
endmodule
