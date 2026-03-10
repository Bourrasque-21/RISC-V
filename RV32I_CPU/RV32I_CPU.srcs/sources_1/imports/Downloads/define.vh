//OPcode
`define R_TYPE 7'b0110011
`define S_TYPE 7'b0100011
`define IL_TYPE 7'b0000011
`define I_TYPE 7'b0010011

// ALU control
`define ADD 4'b0000
`define SUB 4'b1000
`define SLL 4'b0001
`define SLT 4'b0010
`define SLTU 4'b0011
`define XOR 4'b0100
`define SRL 4'b0101
`define SRA 4'b1101
`define OR 4'b0110
`define AND 4'b0111

// S-type
`define SB 3'b000 // sb rs2, imm(rs1)
`define SH 3'b001 // sh rs2, imm(rs1)
`define SW 3'b010 // sw rs2, imm(rs1)

// IL-type
`define LB 3'b000
`define LH 3'b001
`define LW 3'b010 //
`define LBU 3'b100
`define LHU 3'b101

// I-type
