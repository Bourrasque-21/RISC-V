`timescale 1ns / 1ps
`include "define.vh"

module rv32i_cpu (
    input         clk,
    input         rst,
    input  [31:0] instr_data,
    output [31:0] instr_addr,
    output [31:0] d_waddr,
    output [31:0] d_wdata,
    output        dwe
);

    logic rf_we, alu_mux_sel;
    logic [3:0] alu_control;

    control_unit U_CONTROL_UNIT (
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (instr_data[6:0]),
        .rf_we      (rf_we),
        .alusrc     (alu_mux_sel),
        .alu_control(alu_control),
        .dwe        (dwe)
    );

    datapath U_DATAPATH (
        .clk(clk),
        .rst(rst),
        .alu_control(alu_control),
        .instr_data(instr_data),
        .rf_we(rf_we),
        .alusrc(alu_mux_sel),
        .d_waddr(d_waddr),
        .d_wdata(d_wdata),
        .instr_addr(instr_addr)
    );

endmodule


module control_unit (
    input        [6:0] funct7,
    input        [2:0] funct3,
    input        [6:0] opcode,
    output logic       rf_we,
    output logic       alusrc,
    output logic       dwe,
    output logic [3:0] alu_control
);

    always_comb begin
        rf_we       = 1'b0;
        alusrc      = 1'b0;
        alu_control = `ADD;
        dwe         = 1'b0;
        case (opcode)
            `R_TYPE: begin
                rf_we  = 1'b1;
                alusrc = 1'b0;
                dwe    = 1'b0;
                case ({
                    funct7, funct3
                })
                    {7'b0000000, 3'b000} : alu_control = `ADD;
                    {7'b0100000, 3'b000} : alu_control = `SUB;
                    {7'b0000000, 3'b001} : alu_control = `SLL;
                    {7'b0000000, 3'b010} : alu_control = `SLT;
                    {7'b0000000, 3'b011} : alu_control = `SLTU;
                    {7'b0000000, 3'b100} : alu_control = `XOR;
                    {7'b0000000, 3'b101} : alu_control = `SRL;
                    {7'b0100000, 3'b101} : alu_control = `SRA;
                    {7'b0000000, 3'b110} : alu_control = `OR;
                    {7'b0000000, 3'b111} : alu_control = `AND;
                    default: begin
                        rf_we       = 1'b0;
                        alu_control = `ADD;
                    end
                endcase
            end
            `S_TYPE: begin
                rf_we       = 1'b0;
                alusrc      = 1'b1;
                alu_control = `ADD;
                dwe         = 1'b1;
            end
        endcase
    end
endmodule
