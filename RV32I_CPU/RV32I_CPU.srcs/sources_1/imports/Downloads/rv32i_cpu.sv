`timescale 1ns / 1ps
module rv32i_cpu (
    input        clk,
    input        rst,
    input [31:0] instr_addr,
    input [31:0] instr_data
);

    logic       rf_we;
    logic [3:0] alu_control;
    logic [31:0] rd1, rd2, alu_result;

    control_unit U_CONTROL_UNIT (
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (instr_data[6:0]),
        .rf_we      (rf_we),
        .alu_control(alu_control)
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
        .rd2        (rd2),
        .alu_control(alu_control),
        .alu_result (alu_result)
    );
endmodule


module control_unit (
    input        [6:0] funct7,
    input        [2:0] funct3,
    input        [6:0] opcode,
    output logic       rf_we,
    output logic [3:0] alu_control
);
    localparam R_TYPE = 7'b0110011;

    // ALUOp
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_SLL = 4'b0010;
    localparam ALU_SLT = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR = 4'b0101;
    localparam ALU_SRL = 4'b0110;
    localparam ALU_SRA = 4'b0111;
    localparam ALU_OR = 4'b1000;
    localparam ALU_AND = 4'b1001;

    always_comb begin
        rf_we = 1'b0;
        alu_control = ALU_ADD;
        if (opcode == R_TYPE) begin
            rf_we = 1'b1;
            case ({funct7, funct3})
                {7'b0000000, 3'b000} : alu_control = ALU_ADD;  // ADD 
                {7'b0100000, 3'b000} : alu_control = ALU_SUB;  // SUB 
                {7'b0000000, 3'b001} : alu_control = ALU_SLL;  // SLL 
                {7'b0000000, 3'b010} : alu_control = ALU_SLT;  // SLT 
                {7'b0000000, 3'b011} : alu_control = ALU_SLTU;  // SLTU
                {7'b0000000, 3'b100} : alu_control = ALU_XOR;  // XOR
                {7'b0000000, 3'b101} : alu_control = ALU_SRL;  // SRL
                {7'b0100000, 3'b101} : alu_control = ALU_SRA;  // SRA 
                {7'b0000000, 3'b110} : alu_control = ALU_OR;  // OR 
                {7'b0000000, 3'b111} : alu_control = ALU_AND;  // AND 
                default: begin
                    rf_we = 1'b0;
                    alu_control = ALU_ADD;
                end
            endcase
        end
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
                reg_file[i] <= 32'd0;
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
            4'b0000: alu_result = rd1 + rd2;  // ADD
            4'b0001: alu_result = rd1 - rd2;  // SUB
            4'b0010: alu_result = rd1 << rd2[4:0];  // SLL
            4'b0011: alu_result = ($signed(rd1) < $signed(rd2)) ? 32'd1 : 32'd0;  // SLT
            4'b0100: alu_result = (rd1 < rd2) ? 32'd1 : 32'd0;  // SLTU
            4'b0101: alu_result = rd1 ^ rd2;  // XOR
            4'b0110: alu_result = rd1 >> rd2[4:0];  // SRL
            4'b0111: alu_result = $signed(rd1) >>> rd2[4:0];  // SRA
            4'b1000: alu_result = rd1 | rd2;  // OR
            4'b1001: alu_result = rd1 & rd2;  // AND
            default: alu_result = 32'd0;
        endcase
    end
endmodule
