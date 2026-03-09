`timescale 1ns / 1ps

module data_mem (
    input        clk,
    input        dwe,
    input [31:0] d_waddr,
    input [31:0] d_wdata
);

    logic [7:0] dmem[0:31];

    always_ff @(posedge clk) begin
        if (dwe) begin
            dmem[d_waddr]   <= d_wdata[7:0];
            dmem[d_waddr+1] <= d_wdata[15:8];
            dmem[d_waddr+2] <= d_wdata[23:16];
            dmem[d_waddr+3] <= d_wdata[31:24];
        end
    end

endmodule