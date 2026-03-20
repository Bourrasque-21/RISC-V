`timescale 1ns / 1ps
`include "_define.vh"

module control_fsm_unit (
    input              clk,
    input              rst,
    input        [6:0] funct7,
    input        [2:0] funct3,
    input        [6:0] opcode,
    output logic       pc_en,
    output logic       branch_c,
    output logic       jal_c,
    output logic       jalr_c,
    output logic       rf_we,
    output logic       alusrc,
    output logic       dwe,
    output logic [2:0] funct3_out,
    output logic [2:0] rfwd_src,
    output logic [3:0] alu_control
);
        
    typedef enum logic [2:0] {
        IF  = 0,
        ID  = 1,
        EXE = 2,
        MEM = 3,
        WB  = 4
    } state_t;
    state_t c_state, n_state;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IF;
        end else begin
            c_state <= n_state;
        end
    end

    always_comb begin
        n_state     = c_state;
        rf_we       = 1'b0;
        alusrc      = 1'b0;
        alu_control = 4'b000;
        dwe         = 1'b0;
        funct3_out  = 3'b0;
        rfwd_src    = 3'b0;
        branch_c    = 1'b0;
        jal_c       = 1'b0;
        jalr_c      = 1'b0;
        pc_en       = 1'b0;
        unique case (c_state)
            IF:begin
                pc_en = 1;
            end

            ID:begin
                // rf_rs1 = ;
                // rf_rs2 = ;
            end

            EXE: begin
                unique case (opcode)
                    `R_TYPE: begin
                        rf_we      = 1'b1;
                        alusrc     = 1'b0;
                        dwe        = 1'b0;
                        funct3_out = `ADD;
                        rfwd_src   = 3'b0;
                        branch_c   = 1'b0;
                        jal_c      = 1'b0;
                        jalr_c     = 1'b0;
                        unique case ({
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
                        endcase
                        n_state = WB;
                    end
                    `S_TYPE: begin
                        rf_we       = 1'b0;
                        alusrc      = 1'b1;
                        alu_control = `ADD;
                        dwe         = 1'b1;
                        funct3_out  = funct3;
                        rfwd_src    = 3'b0;
                        branch_c    = 1'b0;
                        jal_c       = 1'b0;
                        jalr_c      = 1'b0;
                        n_state     = MEM;
                    end
                    `IL_TYPE: begin
                        rf_we       = 1'b1;
                        alusrc      = 1'b1;
                        alu_control = `ADD;
                        dwe         = 1'b0;
                        funct3_out  = funct3;
                        rfwd_src    = 3'b001;
                        branch_c    = 1'b0;
                        jal_c       = 1'b0;
                        jalr_c      = 1'b0;
                        n_state     = MEM;
                    end
                    `I_TYPE: begin
                        rf_we      = 1'b1;
                        alusrc     = 1'b1;
                        dwe        = 1'b0;
                        funct3_out = funct3;
                        rfwd_src   = 3'b0;
                        branch_c   = 1'b0;
                        jal_c      = 1'b0;
                        jalr_c     = 1'b0;
                        if (funct3 == 3'b101) alu_control = {funct7[5], funct3};
                        else alu_control = {1'b0, funct3};
                        n_state = WB;
                    end
                    `B_TYPE: begin
                        rf_we       = 1'b0;
                        alusrc      = 1'b0;
                        dwe         = 1'b0;
                        funct3_out  = funct3;
                        rfwd_src    = 3'b0;
                        branch_c    = 1'b1;
                        jal_c       = 1'b0;
                        jalr_c      = 1'b0;
                        alu_control = {1'b0, funct3};
                        n_state     = WB;
                    end
                    `LUI_TYPE: begin
                        rf_we       = 1'b1;
                        alusrc      = 1'b0;
                        alu_control = `ADD;
                        dwe         = 1'b0;
                        funct3_out  = funct3;
                        rfwd_src    = 3'b010;
                        branch_c    = 1'b0;
                        jal_c       = 1'b0;
                        jalr_c      = 1'b0;
                        n_state     = WB;
                    end
                    `AUIPC_TYPE: begin
                        rf_we       = 1'b1;
                        alusrc      = 1'b0;
                        alu_control = `ADD;
                        dwe         = 1'b0;
                        funct3_out  = funct3;
                        rfwd_src    = 3'b011;
                        branch_c    = 1'b0;
                        jal_c       = 1'b0;
                        jalr_c      = 1'b0;
                        n_state     = WB;
                    end
                    `JAL_TYPE: begin
                        rf_we       = 1'b1;
                        alusrc      = 1'b0;
                        alu_control = `ADD;
                        dwe         = 1'b0;
                        funct3_out  = funct3;
                        rfwd_src    = 3'b100;
                        branch_c    = 1'b0;
                        jal_c       = 1'b1;
                        jalr_c      = 1'b0;
                        n_state     = WB;
                    end
                    `JALR_TYPE: begin
                        rf_we       = 1'b1;
                        alusrc      = 1'b1;
                        alu_control = `ADD;
                        dwe         = 1'b0;
                        funct3_out  = funct3;
                        rfwd_src    = 3'b100;
                        branch_c    = 1'b0;
                        jal_c       = 1'b0;
                        jalr_c      = 1'b1;
                        n_state     = WB;
                    end
                endcase
            end

            // WB:

            // MEM:


        endcase
    end

endmodule
