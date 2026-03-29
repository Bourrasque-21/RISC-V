`timescale 1ns / 1ps
// `include "_define.vh"

module tb_rv32i_mcu ();
    logic clk;
    logic rst;

    rv32i_mcu dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        @(negedge clk);
        @(negedge clk);

        rst = 0;

        repeat (1500) @(negedge clk);

        $stop;
    end

endmodule
