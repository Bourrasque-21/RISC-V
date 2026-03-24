`timescale 1ns / 1ps

module rv32i_mcu (
    input clk,
    input rst
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
        w_pwdata,
        w_pdata0;
    logic [2:0] funct3_out;
    logic bus_wreq, bus_rreq, bus_ready, w_psel0;

    instruction_mem U_INSTRUCTION_MEM (.*);

    rv32i_cpu U_RV32I (
        .*,
        .funct3_out(funct3_out)
    );

    APB_Master U_ABP_MASTER (
        .PCLK   (clk),
        .PRESETn(~rst),
        .Addr   (bus_addr),
        .Wdata  (bus_wdata),
        .WREQ   (bus_wreq),
        .RREQ   (bus_rreq),
        .Rdata  (bus_rdata),
        .Ready  (bus_ready),
        .PADDR  (w_paddr),
        .PWDATA (w_pwdata),
        .PENABLE(),
        .PWRITE (),
        .PSEL0  (w_psel0),
        .PSEL1  (),
        .PSEL2  (),
        .PSEL3  (),
        .PSEL4  (),
        .PSEL5  (),
        .PRDATA0(w_pdata0),
        .PRDATA1(),
        .PRDATA2(),
        .PRDATA3(),
        .PRDATA4(),
        .PRDATA5(),
        .PREADY0(),
        .PREADY1(),
        .PREADY2(),
        .PREADY3(),
        .PREADY4(),
        .PREADY5()
    );

    data_mem U_DATA_MEM (
        .clk      (clk),
        .dwe      (w_psel0),
        .daddr    (w_paddr),
        .d_wdata  (w_pwdata),
        .drdata   (w_pdata0),
        .funct3_in(funct3_out)
    );

endmodule
