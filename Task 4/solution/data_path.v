// Новые порты и точки объявлять в начале модуля под соответствующим комментарием. Комментарий не стирать.
// Имена новых портов записать вместо соответствующего комментария в начале объявления модуля.
// Новые подсхемы дописывать в конце модуля под соответствующим комментарием. Комментарий не стирать.
module data_path(x, y, s, b, y_select_next, s_step, y_en, s_en, y_store_x, s_add, s_zero, clk, rst, it_end /* , ... (ИМЕНА НОВЫХ УПРАВЛЯЮЩИХ ПОРТОВ */);
  input [7:0] x;
  input [1:0] y_select_next, s_step;
  input clk, rst, y_en, s_en, y_store_x, s_add, s_zero;
  output reg [7:0] y;
  output reg [2:0] s;
  output b;
  
  /* ОБЪЯВЛЕНИЯ НОВЫХ УПРАВЛЯЮЩИХ ПОРТОВ И НОВЫХ ВНУТРЕННИХ ТОЧЕК */
  
  output it_end;

  reg [7:0] y_next;
  wire [7:0] y_in;
  wire [2:0] s_in, s_base;
  
  // регистр для y
  always @(posedge clk, posedge rst)
    if(rst) y <= 0;
    else if(y_en) y <= y_in;
  
  // регистр для s
  always @(posedge clk, posedge rst)
    if(rst) s <= 0;
    else if(s_en) s <= s_in;
  
  // селектор для b
  assign b = y[s];
  
  // ближний мультиплексор на входе регистра y
  assign y_in = y_store_x ? x : y_next;
  
  // дальний мультиплексор на входе регистра y
  always @*
  begin
    y_next = 1'bx;
    case(y_select_next)
    2'd0 : y_next = y;
    2'd1 : y_next = y + 1;
    2'd2 : y_next = y + s;
    2'd3 : y_next = y - s;
    endcase
  end
  
  // мультиплексор на входе s
  assign s_in = s_add ? s_base + s_step : s_base - s_step;
  
  // мультиплексор, выбирающий первое слагаемое для нового значения s
  assign s_base = s_zero ? 0 : s;
  
  /* РЕАЛИЗАЦИЯ ПОДСХЕМ ДЛЯ ПРЕОБРАЗОВАНИЯ ДАННЫХ В УПРАВЛЕНИЕ */
  
  // При итерации по четным разрядам дошли до конца
  assign it_end = s == 3'd6;

endmodule
