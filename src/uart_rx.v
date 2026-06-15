//UART receiver module
//4 state FSM IDLE, START, DATA, STOP
//Samples output by Tx at 16x baud rate to reconstruct byte and set rx_done when complete
//IDLE: waits for start bit (0) on rx_serial
//START: detects start bit (0) and waits 8 ticks (half a bit period) to sample in the middle of the start bit
//DATA: samples each data bit every 16 ticks, shifting them into a register
//STOP: after receiving 8 data bits, waits 16 ticks for the stop bit, then sets rx_done and goes back to IDLE

module uart_rx (
    input clk,
    input rst,
    input tick,
    input wire rx_serial,
    output reg [7:0] rx_data,
    output reg rx_done
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state;
    reg [2:0] bit_idx;
    reg [3:0] tick_count;
    reg [7:0] rx_shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            bit_idx <= 3'd0;
            tick_count <= 4'd0;
            rx_shift <= 8'd0;
            rx_data <= 8'd0;
            rx_done <= 0;
        end else begin
            rx_done <= 0;
            case (state)
                IDLE: begin
                    tick_count <= 4'd0;
                    bit_idx <= 3'd0;
                    if (rx_serial == 0) state <= START;
                end
                START: begin
                    if (tick) begin
                        if (tick_count == 4'd7) begin
                            tick_count <= 4'd0;
                            if (rx_serial == 0) state <= DATA;
                            else state <= IDLE;
                        end else tick_count <= tick_count + 1;
                    end
                end
                DATA: begin
                    if (tick) begin
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            rx_shift[bit_idx] <= rx_serial;
                            if (bit_idx == 3'd7) state <= STOP;
                            else bit_idx <= bit_idx + 1;
                        end else tick_count <= tick_count + 1;
                    end
                end
                STOP: begin
                    if (tick) begin
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            rx_data <= rx_shift;
                            rx_done <= 1;
                            state <= IDLE;
                        end else tick_count <= tick_count + 1;
                    end
                end
            endcase
        end
    end
endmodule