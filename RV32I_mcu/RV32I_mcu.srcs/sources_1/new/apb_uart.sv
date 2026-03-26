`timescale 1ns / 1ps

module apb_uart (
    input               PCLK,
    input               PENABLE,
    input               PWRITE,
    input               PSEL,
    input        [31:0] PADDR,
    input        [31:0] PWDATA,
    output              PREADY,
    output logic [31:0] PRDATA
);


endmodule
