`timescale 1ns / 1ps

module apb_gpi02 (
    input               PCLK,
    input               PRESET,
    input        [31:0] PADDR,
    input               PENABLE,
    input               PSEL,
    input        [15:0] GPI_IN,
    output logic        PREADY,
    output logic [31:0] PRDATA
);

    assign PREADY = PENABLE & PSEL;

    always_comb begin
        case (PADDR[11:0])
            12'h0000: PRDATA = {16'h0000, GPI_IN};
            default:  PRDATA = 32'h0000_0000;
        endcase
    end
endmodule
