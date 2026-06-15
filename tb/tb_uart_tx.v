//test bench to test uart_tx module independently

`timescale 1ns/1ps

module tb_uart_tx;

    reg clk, rst, tx_start;
    reg [7:0] tx_data;
    wire tx_serial, tx_done, tick;

    baud_gen #(
        .CLK_FREQ(1600),
        .BAUD_RATE(10)
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

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/dump_tx.vcd");
        $dumpvars(0, tb_uart_tx);
        rst = 1;
        tx_start = 0;
        tx_data = 8'h0;
        #30 rst = 0;
        #20 tx_start = 1;
        tx_data = 8'h55; 
        #10 tx_start = 0;
        #20000 $finish;
    end

    initial begin
        $monitor("t=%0t | serial=%b | done=%b", $time, tx_serial, tx_done);
    end
endmodule