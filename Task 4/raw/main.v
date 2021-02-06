// Новые точки объявлять перед экземплярами под соответствующим комментарием. Комментарий не стирать.
// Назначать новые порты в экземплярах - в конце всех назначений под соответствующим комментарием. Комментарий не стирать.
// НЕ ЗАБУДЬТЕ поставить запятую после ".rst(rst)", если добавляете новые порты.
module main(x, y, s, b, on, start, regime, active, clk, rst);
  input [7:0] x;
  input [1:0] on;
  input start;
  input clk, rst;
  output [7:0] y;
  output [2:0] s;
  output b, active;
  output [1:0] regime;
  
  wire [1:0] y_select_next, s_step;
  wire y_en, s_en, y_store_x, s_add, s_zero;
  
  /* ОБЪЯВЛЕНИЯ ТОЧЕК */
  
  data_path _data_path(
    // данные
    .x(x),
    .y(y),
    .s(s),
    .b(b),
    // исходное управление
    .y_select_next(y_select_next),
    .s_step(s_step),
    .y_en(y_en),
    .s_en(s_en),
    .y_store_x(y_store_x),
    .s_add(s_add),
    .s_zero(s_zero),
    // такт и сброс
    .clk(clk),
    .rst(rst)
    /* ДОБАВЛЕННЫЕ ПОРТЫ */
  );
  control_path _control_path(
    // подключения к портам схемы
    .on(on),
    .start(start),
    .regime(regime),
    .active(active),
    // подключения к портам операционного автомата
    .y_select_next(y_select_next),
    .s_step(s_step),
    .y_en(y_en),
    .s_en(s_en),
    .y_store_x(y_store_x),
    .s_add(s_add),
    .s_zero(s_zero),
    // такт и сброс
    .clk(clk),
    .rst(rst)
    /* ДОБАВЛЕННЫЕ ПОРТЫ */
  );
endmodule
