//test bench to send 4 bytes through uart and check if received correctly

`timescale 1ns/1ps

module tb_uart;
    reg        clk, rst, tx_start;
    reg  [7:0] tx_data;
    wire [7:0] rx_data;
    wire       rx_done, tx_done, tx_serial;

    uart_top #() uut (
        .clk(clk), .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .tx_done(tx_done),
        .tx_serial(tx_serial)
    );

    // Override baud_gen parameters for simulation speed
    defparam uut.baud.CLK_FREQ  = 1600;
    defparam uut.baud.BAUD_RATE = 10;

    initial clk = 0;
    always #5 clk = ~clk;

    task send_byte;
        input [7:0] data;
        begin
            @(posedge clk);
            tx_data  = data;
            tx_start = 1;
            @(posedge clk);
            tx_start = 0;
            #20000;    // wait 20us — enough for a full 10-bit frame at our sim baud rate
            $display("Sent: 0x%02X | Received: 0x%02X | %s",
                data, rx_data,
                (data == rx_data) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $dumpfile("sim/dump_uart.vcd");
        $dumpvars(0, tb_uart);
        rst = 1; tx_start = 0; tx_data = 8'h0;
        #30 rst = 0;
        #50;

        send_byte(8'h55);   // alternating bits — 01010101
        send_byte(8'hA5);   // 10100101
        send_byte(8'hFF);   // all ones
        send_byte(8'h00);   // all zeros — hardest case

        #500000 $finish;
    end
endmodule