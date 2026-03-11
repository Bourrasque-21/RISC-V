`timescale 1ns / 1ps

module tb_rv32i ();
    logic clk;
    logic rst;

    rv32i_top dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        @(negedge clk);
        @(negedge clk);

        rst = 0;

        repeat (40) @(posedge clk);

        $display("===== FINAL REGISTER CHECK =====");
        $display("x1 = %h (LUI result)", dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[1]);
        $display("x2 = %h (AUIPC result)", dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[2]);
        $display("x3 = %h", dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[3]);
        $display("x4 = %h", dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[4]);
        $display("x5 = %h (should stay 00000005 if branch skipped ADDI)", dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[5]);
        $display("x6 = %h (JAL link addr)", dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[6]);
        $display("x7 = %h (should stay 00000007 if JAL skipped ADDI)", dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[7]);
        $display("x8 = %h (branch target)", dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[8]);

        $stop;
    end

    initial begin
        $display("time | pc | instr");
        forever begin
            @(posedge clk);
            $display("%4t | %h | %h",
                $time,
                dut.instr_addr,
                dut.instr_data
            );
        end
    end

endmodule
