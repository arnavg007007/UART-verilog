// Baud rate generator for UART communication
//converts system clock to 16x baud rate ticks

module baud_gen #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst,
    output reg  tick
);
    localparam TICKS = CLK_FREQ / (BAUD_RATE * 16);
    integer count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == TICKS - 1) begin
                count <= 0;
                tick  <= 1;
            end else begin
                count <= count + 1;
                tick  <= 0;
            end
        end
    end
endmodule