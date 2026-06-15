//TB to test baud generator independently

`timescale 1ns/1ps

module tb_baud_gen;

    reg  clk, rst;
    wire tick;

    baud_gen #(
        .CLK_FREQ(1600),
        .BAUD_RATE(10)
    ) uut (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_baud_gen);
        rst = 1;
        #30  rst = 0;
        #500 $finish;
    end

    initial begin
        $monitor("t=%0t | count=%0d | tick=%b", $time, uut.count, tick);
    end

endmodule