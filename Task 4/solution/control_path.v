// Имена новых управляющих портов добавить после соответствующего комментария в первой строке объявления модуля.
// Сами объявления дописывать под соответствующим комментарием после имеющихся объявлений портов. Комментарий не стирать.
// Реализацию управляющего автомата дописывать под соответствующим комментарием в конце модуля. Комментарий не стирать.
// По необходимости можно раскомментировать ключевые слова "reg" в объявлениях портов.
module control_path(on, start, regime, active, y_select_next, s_step, y_en, s_en, y_store_x, s_add, s_zero, clk, rst, it_end /* , ... (ИМЕНА НОВЫХ УПРАВЛЯЮЩИХ ПОРТОВ */);
  input [1:0] on;
  input start, clk, rst;
  output reg [1:0] regime;
  output reg active;
  output reg [1:0] y_select_next; // 4 действия над y (+0, +1, +s, -s)
  output reg [1:0] s_step;        // Шаг для изменения s
  output /* reg */ y_en;          // Можно или нет записывать в y
  output /* reg */ s_en;          // Можно или нет записывать в s
  output /* reg */ y_store_x;     // Первое действие в режиме обновления
  output /* reg */ s_add;         // Флаг для шага изменения s
  output /* reg */ s_zero;        // Приравниваем s к нулю

  /* ОБЪЯВЛЕНИЯ НОВЫХ УПРАВЛЯЮЩИХ ПОРТОВ */
  localparam S_OFF = 2'd0, S_ENU = 2'd1, S_CNT = 2'd2, S_UPD = 2'd3; // Имена режимов
  localparam ACT_1 = 2'd3, ACT_2 = 2'd2, ACT_3 = 2'd1, ACT_4 = 2'd0; // Действия режима счета
  input it_end;
  
  reg [1:0] regime_next;          // Изменяем regime
  reg [1:0] timer;                // Такты для режима перечисления
  reg [1:0] actions;              // Текущее действие
  reg active_next;                // Изменяем активность схемы
  
  /* КОД УПРАВЛЯЮЩЕГО АВТОМАТА */
  always @(posedge clk, posedge rst) begin
    if (rst) begin 
        regime <= S_OFF;     // После сброса схема находится в выключенном режиме
        active <= 0;         // После сброса схема деактивируется
        end
    else if (clk) begin
        regime <= regime_next;
        active <= active_next;
        end
  end

  always @(posedge clk, posedge rst) begin     // Режим перечисления, такты
    if (rst) timer <= 2'd3;                    // Будем ждать 4 такта
    else if(timer == 0) timer <= 2'd3;         // Закончили выдавать одно 4 такта - выдаем следующее 4 такта
    else if(active) timer <= timer - 2'd1;     // Схема активна - уменьшаем такты
    else timer <= timer;                       // Схема деактивирована - пока ничего не делаем с тактами
  end

  always @(posedge clk, posedge rst) begin     // Режим обновления, порядок выполнения действий
    if (rst) actions <= ACT_1;                 // Будем выполнять 4 действия
    else if (actions == ACT_4) actions <= ACT_1;   // Закончили цикл действий
    else if (regime == S_UPD) actions <= actions - 2'd1;    // Берем следующее действие
    else actions <= actions;
  end

  always @(*) begin
    case(regime)
      S_OFF: case(on)                                       // Схема изменяет режим в зависимости от прочитанного значения on
            S_OFF: regime_next = S_OFF;
            S_ENU: regime_next = S_ENU;
            S_CNT: regime_next = S_CNT;
            S_UPD: regime_next = S_UPD;
            default: regime_next = S_OFF;
         endcase
      S_ENU: if (it_end && timer == 0) regime_next = S_OFF; // Дошли до конца, нужно перейти в выкл режим
            else regime_next = S_ENU;
      S_CNT: if (start == 0) regime_next = S_OFF;           // Если start(t) = 0, то схема переходит в выключенный режим
            else regime_next = S_CNT;
      S_UPD: if (actions == ACT_4) regime_next = S_OFF;     // Если выполнили все действия - идем в выключенный режим
            else regime_next = S_UPD;
      default regime_next = S_OFF;
    endcase
  end

  always @(*) begin
    if (s_zero) active_next = 1'd1;                         // Активируем схему в режиме перечисления, но переходим в другой режим
    else if (it_end && timer == 0) active_next = 1'd0;      // Дошли до конца, нужно изменить s на 0 и перейти в выкл режим
    else active_next = active;
  end

  always @(*) begin
    case(regime)
      S_ENU: if (active) s_step = 2'd2;                     // Режим перечисления, шагаем по четным на увеличение
            else s_step = 2'd0;                             // Не изменяем s
      S_CNT: s_step = 2'd1;                                 // Режим счета, вычитаем 1
      S_UPD: s_step = 2'd1;                                 // Режим обновления, прибавляем 1 один раз
      default: s_step = 2'd0;
    endcase
  end

  always @(*) begin
    case(regime)
      S_CNT: y_select_next = 2'd1;                          // +1
      S_UPD: if (actions == ACT_2) y_select_next = 2'd3;    // -s
            else y_select_next = 2'd0;                      // =
      default: y_select_next = 2'd0;                        // =
    endcase
  end

  assign y_store_x = (regime == S_UPD) && (actions == ACT_1);// Первое действие в режиме обновления

  assign s_zero = (regime == S_ENU) &&                       // Режим перечисления
                  (active == 0) &&                           // Уже доитерировалась
                  start;                                     // И ранее схема была активирована

  assign s_add = (regime == S_ENU) ||                        // Режим перечисления, шагаем вправо на 2
                 (regime == S_UPD);                          // Режим обновления, прибавляем 1

  assign s_en = (regime == S_ENU && active == 0 && start) || // Режим перечисления, нужно изменить s на 0 после всех тактов
                (timer == 0) ||                              // Режим перечисления, нужно изменить s для след четн разряд b
                (regime == S_CNT) ||                         // Режим счета, всё время s-=1
                (actions == ACT_3);                          // Режим обновления, 3е действие (+1)

  assign y_en = (regime == S_CNT && it_end) ||               // Если шаг назад было 6, то на следующем будет 5 и R8+=1 
                (regime == S_UPD && actions == ACT_2) ||     // "В регистре R8 сохраняется значение x"
                (regime == S_UPD && actions == ACT_1);       // "Из значения в R8 вычитается значение s"
endmodule
