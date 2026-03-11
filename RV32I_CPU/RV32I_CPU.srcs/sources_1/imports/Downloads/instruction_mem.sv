`timescale 1ns / 1ps

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom[0:31];

    initial begin
        for (int i = 0; i < 32; i++) begin
            rom[i] = 32'h00000013;
        end

        rom[0] = 32'h000010B7;  // LUI   x1, 0x1
        rom[1] = 32'h00001117;  // AUIPC x2, 0x1
        rom[2] = 32'h00500193;  // ADDI  x3, x0, 5
        rom[3] = 32'h00500213;  // ADDI  x4, x0, 5
        rom[4] = 32'h00418663;  // BEQ   x3, x4, label
        rom[5] = 32'h00100293;  // ADDI  x5, x0, 1 (skip)
        rom[6] = 32'h0080036F;  // JAL   x6, jump
        rom[7] = 32'h00200393;  // ADDI  x7, x0, 2 (skip)
        rom[8] = 32'h00900413;  // label: ADDI x8, x0, 9
        rom[9] = 32'h00030067;  // jump: JALR x0, 0(x6)
    end

    assign instr_data = rom[instr_addr[31:2]];

endmodule
