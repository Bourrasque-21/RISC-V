`timescale 1ns / 1ps
`include "../imports/Downloads/define.vh"

module datapath (
    input               clk,
    input               rst,
    input        [ 3:0] alu_control,
    input        [31:0] instr_data,
    input               rf_we,
    input               alusrc,
    output logic [31:0] d_waddr,
    output logic [31:0] d_wdata,
    output logic [31:0] instr_addr
);

    logic [31:0] rd1, rd2, alu_result, alu_mux_out, imm_data;

    assign d_waddr = alu_result;
    assign d_wdata = rd2;

    pc U_PC (
        .clk(clk),
        .rst(rst),
        .instr_addr(instr_addr)
    );

    register_file U_REG_FILE (
        .clk  (clk),
        .rst  (rst),
        .RA1  (instr_data[19:15]),
        .RA2  (instr_data[24:20]),
        .WA   (instr_data[11:7]),
        .Wdata(alu_result),
        .rf_we(rf_we),
        .RD1  (rd1),
        .RD2  (rd2)
    );

    alu U_ALU (
        .rd1        (rd1),
        .rd2        (alu_mux_out),
        .alu_control(alu_control),
        .alu_result (alu_result)
    );

    imm_extender U_IMM_EXT (
        .instr_data(instr_data),
        .imm_data  (imm_data)
    );

    mux_2x1 U_2x1_MUX_ALU (
        .a      (rd2),
        .b      (imm_data),
        .sel    (alusrc),
        .mux_out(alu_mux_out)
    );

endmodule


module pc (
    input               clk,
    input               rst,
    output logic [31:0] instr_addr
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) instr_addr <= 32'd0;
        else instr_addr <= instr_addr + 32'd4;
    end

endmodule


module register_file (
    input               clk,
    input               rst,
    input        [ 4:0] RA1,
    input        [ 4:0] RA2,
    input        [ 4:0] WA,
    input        [31:0] Wdata,
    input               rf_we,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);
    logic [31:0] reg_file[0:31];

    assign RD1 = (RA1 == 5'd0) ? 32'd0 : reg_file[RA1];
    assign RD2 = (RA2 == 5'd0) ? 32'd0 : reg_file[RA2];

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                reg_file[i] <= i;
            end
        end else begin
            if (rf_we && (WA != 5'd0)) begin
                reg_file[WA] <= Wdata;
            end
        end
    end
endmodule


module alu (
    input        [31:0] rd1,
    input        [31:0] rd2,
    input        [ 3:0] alu_control,
    output logic [31:0] alu_result
);

    always_comb begin
        case (alu_control)
            `ADD: alu_result = rd1 + rd2;
            `SUB: alu_result = rd1 - rd2;
            `SLL: alu_result = rd1 << rd2[4:0];
            `SLT: alu_result = ($signed(rd1) < $signed(rd2)) ? 32'd1 : 32'd0;
            `SLTU: alu_result = (rd1 < rd2) ? 32'd1 : 32'd0;
            `XOR: alu_result = rd1 ^ rd2;
            `SRL: alu_result = rd1 >> rd2[4:0];
            `SRA: alu_result = $signed(rd1) >>> rd2[4:0];
            `OR: alu_result = rd1 | rd2;
            `AND: alu_result = rd1 & rd2;
            default: alu_result = 32'd0;
        endcase
    end
endmodule


module imm_extender (
    input        [31:0] instr_data,
    output logic [31:0] imm_data
);

    always_comb begin
        imm_data = 32'h0;
        case (instr_data[6:0])
            `S_TYPE: begin
                imm_data = {
                    {20{instr_data[31]}}, instr_data[31:25], instr_data[11:7]
                };
            end
        endcase
    end

endmodule


module mux_2x1 (
    input  [31:0] a,
    input  [31:0] b,
    input         sel,
    output [31:0] mux_out
);

    assign mux_out = (sel) ? b : a;

endmodule

