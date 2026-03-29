`timescale 1ns / 1ps
// `include "_define.vh"

module tb_rv32i_mcu ();
    logic clk;
    logic rst;
    logic [15:0] sw;
    logic uart_rx;
    logic uart_tx;

    // Waveform-friendly debug aliases
    wire       dbg_uart_rx       = uart_rx;
    wire       dbg_uart_tx       = uart_tx;
    wire       dbg_rx_done       = dut.U_APB_UART.w_rx_done;
    wire [7:0] dbg_rx_byte       = dut.U_APB_UART.w_rx_data;
    wire [7:0] dbg_rx_data_reg   = dut.U_APB_UART.rx_data_reg;
    wire       dbg_rx_valid      = dut.U_APB_UART.rx_valid_reg;
    wire       dbg_tx_start      = dut.U_APB_UART.w_tx_start;
    wire [7:0] dbg_tx_data_reg   = dut.U_APB_UART.tx_data_reg;
    wire       dbg_tx_busy       = dut.U_APB_UART.w_tx_busy;
    wire [1:0] dbg_baud_sel      = dut.U_APB_UART.w_baud_set;
    wire       dbg_b_tick        = dut.U_APB_UART.w_b_tick;
    wire [31:0] dbg_apb_addr     = dut.w_paddr;
    wire        dbg_apb_psel_uart = dut.w_psel5;
    wire        dbg_apb_penable   = dut.w_penable;
    wire        dbg_apb_pwrite    = dut.w_pwrite;
    wire [31:0] dbg_apb_pwdata    = dut.w_pwdata;
    wire [31:0] dbg_apb_prdata    = dut.w_prdata5;
    wire [31:0] dbg_status_data   = dut.U_APB_UART.status_data;
    wire        dbg_interrupt_signal = dut.uart_interrupt_signal;
    wire        dbg_interrupt_clear  = dut.uart_interrupt_clear;
    wire [31:0] dbg_instr_addr       = dut.instr_addr;
    wire [31:0] dbg_bus_addr         = dut.bus_addr;
    wire        dbg_ram_wreq         = dut.ram_wreq;
    wire        dbg_ram_rreq         = dut.ram_rreq;
    wire [31:0] dbg_bmem0            = dut.U_RAM.U_BRAM.bmem[0];
    wire [31:0] dbg_bmem2            = dut.U_RAM.U_BRAM.bmem[2];
    wire [31:0] dbg_return_reg       = dut.U_RV32I.U_DATAPATH.U_REG_FILE.reg_file[26];

    localparam int UART_DIV_9600 = 651;
    localparam int UART_DIV_19200 = 326;
    localparam int UART_DIV_115200 = 54;

    rv32i_mcu dut (
        .clk    (clk),
        .rst    (rst),
        .sw     (sw),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    always #5 clk = ~clk;

    function automatic int uart_div_from_sel(input logic [1:0] baud_sel);
        case (baud_sel)
            2'b00: uart_div_from_sel = UART_DIV_9600;
            2'b01: uart_div_from_sel = UART_DIV_19200;
            default: uart_div_from_sel = UART_DIV_115200;
        endcase
    endfunction

    task automatic uart_send_byte(
        input logic [1:0] baud_sel,
        input logic [7:0] data
    );
        int uart_bit_clks;
        begin
            uart_bit_clks = uart_div_from_sel(baud_sel) * 16;
            uart_rx = 1'b0;
            repeat (uart_bit_clks) @(negedge clk);
            for (int i = 0; i < 8; i++) begin
                uart_rx = data[i];
                repeat (uart_bit_clks) @(negedge clk);
            end
            uart_rx = 1'b1;
            repeat (uart_bit_clks) @(negedge clk);
        end
    endtask

    initial begin
        clk     = 0;
        rst     = 1;
        sw      = 16'h0000;
        uart_rx = 1'b1;

        @(negedge clk);
        @(negedge clk);

        rst = 0;

        // Let the main loop run first.
        repeat (3000) @(negedge clk);

        // UART default baud after reset is 9600.
        uart_send_byte(2'b00, 8'h41);

        repeat (3000) @(negedge clk);

        uart_send_byte(2'b00, 8'h42);

        repeat (4300) @(negedge clk);


        uart_send_byte(2'b00, 8'h43);

        repeat (5000) @(negedge clk);
        $stop;
    end

endmodule
