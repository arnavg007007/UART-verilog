//Top level module connecting baud generator, UART Tx and Rx

module uart_top (
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0] tx_data,
    output wire [7:0] rx_data,
    output wire rx_done,
    output wire tx_done,
    output wire tx_serial
);
    wire tick;
    baud_gen #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(9600)
    ) baud (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    uart_tx tx (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_serial(tx_serial),
        .tx_done(tx_done)
    );

    uart_rx rx (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .rx_serial(tx_serial),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );
endmodule