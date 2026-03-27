`timescale 1ns / 1ps

module rv32i_mcu (
    input       clk,
    input       rst,
    input logic [15:0] sw,
    input       uart_rx,
    output      uart_tx,
    output logic [15:0] led
);

    logic [31:0]
        instr_addr,
        instr_data,
        d_wdata,
        drdata,
        daddr,
        bus_addr,
        bus_wdata,
        bus_rdata,
        w_paddr,
        w_pwdata;
    logic [2:0] funct3_out;
    logic bus_wreq, bus_rreq, bus_ready, w_penable, w_pwrite;

    logic w_psel0, w_psel1, w_psel2, w_psel3, w_psel4, w_psel5;
    logic [31:0]
        w_prdata0, w_prdata1, w_prdata2, w_prdata3, w_prdata4, w_prdata5;
    logic w_pready0, w_pready1, w_pready2, w_pready3, w_pready4, w_pready5;

    assign w_prdata3 = 1'b0;
    assign w_prdata4 = 1'b0;
    assign w_pready3 = 1'b0;
    assign w_pready4 = 1'b0;

    instruction_mem U_INSTRUCTION_MEM (.*);

    rv32i_cpu U_RV32I (
        .clk       (clk),
        .rst       (rst),
        .instr_data(instr_data),
        .bus_rdata (bus_rdata),
        .bus_ready (bus_ready),
        .instr_addr(instr_addr),
        .bus_wreq  (bus_wreq),
        .bus_rreq  (bus_rreq),
        .bus_addr  (bus_addr),
        .bus_wdata (bus_wdata),
        .funct3_out(funct3_out)
    );

    APB_Master U_APB_MASTER (
        .PCLK  (clk),
        .PRESET(rst),
        .Addr  (bus_addr),
        .Wdata (bus_wdata),
        .WREQ  (bus_wreq),
        .RREQ  (bus_rreq),
        .Rdata (bus_rdata),
        .Ready (bus_ready),

        .PADDR  (w_paddr),
        .PWDATA (w_pwdata),
        .PENABLE(w_penable),
        .PWRITE (w_pwrite),
        // from APB SLAVE
        .PSEL0  (w_psel0),
        .PSEL1  (w_psel1),
        .PSEL2  (w_psel2),
        .PSEL3  (w_psel3),
        .PSEL4  (w_psel4),
        .PSEL5  (w_psel5),
        .PRDATA0(w_prdata0),
        .PRDATA1(w_prdata1),
        .PRDATA2(w_prdata2),
        .PRDATA3(w_prdata3),
        .PRDATA4(w_prdata4),
        .PRDATA5(w_prdata5),
        .PREADY0(w_pready0),
        .PREADY1(w_pready1),
        .PREADY2(w_pready2),
        .PREADY3(w_pready3),
        .PREADY4(w_pready4),
        .PREADY5(w_pready5)
    );

    data_dmem U_RAM (
        .PCLK   (clk),
        .PADDR  (w_paddr),
        .PWDATA (w_pwdata),
        .PENABLE(w_penable),
        .PWRITE (w_pwrite),
        .PSEL   (w_psel0),
        .PRDATA (w_prdata0),
        .PREADY (w_pready0),
        .i_funct3(funct3_out)
    );

    apb_gpo01 U_APB_GPO01 (
        .PCLK   (clk),
        .PRESET (rst),
        .PADDR  (w_paddr),
        .PWDATA (w_pwdata),
        .PENABLE(w_penable),
        .PWRITE (w_pwrite),
        .PSEL   (w_psel1),
        .PREADY (w_pready1),
        .PRDATA  (w_prdata1),
        .GPO_OUT (led)
    );

    apb_gpi02 U_APB_GPI02 (
        .PCLK   (clk),
        .PRESET (rst),
        .PADDR  (w_paddr),
        .PENABLE(w_penable),
        .PSEL   (w_psel2),
        .PREADY (w_pready2),
        .PRDATA (w_prdata2),
        .GPI_IN (sw)
    );

    apb_uart U_APB_UART (
        .PCLK   (clk),
        .PRESET (rst),
        .PADDR  (w_paddr),
        .PWDATA (w_pwdata),
        .PENABLE(w_penable),
        .PWRITE (w_pwrite),
        .PSEL   (w_psel5),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .PREADY (w_pready5),
        .PRDATA (w_prdata5)
    );


endmodule
