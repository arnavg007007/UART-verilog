//UART transmitter module
//4 state fsm IDLE, START, DATA, STOP
// IDLE: wait for tx_start, then load data and go to START
// START: send start bit (0) for 1 tick, then go to DATA
// DATA: send data bits, then go to STOP
// STOP: send stop bit (1) for 1 tick, then go to IDLE and assert tx_done
module uart_tx(
    input wire clk,
    input wire rst,
    input wire tick,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx_serial,
    output reg tx_done
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3; 
    reg [1:0] state;
    reg [2:0] bit_idx;
    reg [3:0] tick_count;
    reg [7:0] data_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_serial <= 1;
            tx_done <= 0;
            tick_count <= 4'd0;
            bit_idx <= 3'd0;
            data_reg <= 8'd0;
        end else begin
            tx_done <= 0;
            case (state)
                IDLE: begin
                    tx_serial <= 1;
                    tick_count <= 4'd0;
                    bit_idx <= 3'd0;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        state <= START;
                    end
                end
                START: begin
                    tx_serial <= 0;
                    if (tick) begin
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            state <= DATA;
                        end else tick_count <= tick_count + 1;
                    end
                end
                DATA: begin
                    tx_serial <= data_reg[bit_idx];
                    if (tick) begin
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            if (bit_idx == 3'd7) state <= STOP;
                            else bit_idx <= bit_idx + 1;
                        end else tick_count <= tick_count + 1;
                    end
                end

                STOP: begin
                    tx_serial <= 1;
                    if (tick) begin
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            state <= IDLE;
                            tx_done <= 1;
                        end else tick_count <= tick_count + 1;
                    end
                end
            endcase
        end
    end
endmodule
    