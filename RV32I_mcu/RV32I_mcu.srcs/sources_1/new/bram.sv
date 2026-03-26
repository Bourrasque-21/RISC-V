`timescale 1ns / 1ps
`include "_define.vh"

module data_dmem (
    input               PCLK,
    input               PENABLE,
    input               PWRITE,
    input               PSEL,
    input        [ 2:0] i_funct3,
    input        [31:0] PADDR,
    input        [31:0] PWDATA,
    output              PREADY,
    output logic [31:0] PRDATA
);

    logic [31:0] w_wdata, w_drdata;
    bram U_BRAM (
        .PCLK   (PCLK),
        .PADDR  (PADDR),
        .PWDATA (w_wdata),
        .PENABLE(PENABLE),
        .PWRITE (PWRITE),
        .PSEL   (PSEL),
        .PRDATA (w_drdata),
        .PREADY (PREADY)
    );

    // S-type control for byte to word address
    always_comb begin
        w_wdata = w_drdata;
        case (i_funct3)
            `SW: w_wdata = PWDATA;
            `SH: begin
                if (PADDR[1] == 1'b1) w_wdata = {PWDATA[15:0], w_drdata[15:0]};
                else w_wdata = {w_drdata[31:16], PWDATA[15:0]};
            end
            `SB: begin
                case (PADDR[1:0])
                    2'b00: w_wdata = {w_drdata[31:8], PWDATA[7:0]};
                    2'b01: w_wdata = {w_drdata[31:16], PWDATA[7:0], w_drdata[7:0]};
                    2'b10: w_wdata = {w_drdata[31:24], PWDATA[7:0], w_drdata[15:0]};
                    2'b11: w_wdata = {PWDATA[7:0], w_drdata[23:0]};
                endcase
            end
        endcase
    end
    // IL-type control 
    always_comb begin
        PRDATA = w_drdata;
        case (i_funct3)
            `LW: PRDATA = w_drdata;
            `LH: begin
                if (PADDR[1] == 1'b1)
                    PRDATA[31:0] = {{16{w_drdata[31]}}, w_drdata[31:16]};
                else
                    PRDATA[31:0] = {{16{w_drdata[15]}}, w_drdata[15:0]};
            end
            `LB: begin
                case (PADDR[1:0])
                    2'b00: PRDATA[31:0] = {{24{w_drdata[7]}}, w_drdata[7:0]};
                    2'b01: PRDATA[31:0] = {{24{w_drdata[15]}}, w_drdata[15:8]};
                    2'b10: PRDATA[31:0] = {{24{w_drdata[23]}}, w_drdata[23:16]};
                    2'b11: PRDATA[31:0] = {{24{w_drdata[31]}}, w_drdata[31:24]};
                endcase
            end
            `LHU: begin
                if (PADDR[1] == 1'b1)
                    PRDATA[31:0] = {16'h0000, w_drdata[31:16]};
                else
                    PRDATA[31:0] = {16'h0000, w_drdata[15:0]};
            end
            `LBU: begin
                case (PADDR[1:0])
                    2'b00: PRDATA[31:0] = {{24{1'b0}}, w_drdata[7:0]};
                    2'b01: PRDATA[31:0] = {{24{1'b0}}, w_drdata[15:8]};
                    2'b10: PRDATA[31:0] = {{24{1'b0}}, w_drdata[23:16]};
                    2'b11: PRDATA[31:0] = {{24{1'b0}}, w_drdata[31:24]};
                endcase
            end
        endcase
    end

endmodule

module bram (
    // BUS Global signal
    input PCLK,

    // APB Insterface signal
    input        [31:0] PADDR,
    input        [31:0] PWDATA,
    input               PENABLE,
    input               PWRITE,
    input               PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY
);

    logic [31:0] bmem[0:1023];  // 1024 * 4byte : 4k

    assign PREADY = (PENABLE & PSEL) ? 1'b1 : 1'b0;

    always_ff @(posedge PCLK) begin
        if (PSEL & PENABLE & PWRITE) bmem[PADDR[11:2]] <= PWDATA;
    end

    assign PRDATA = bmem[PADDR[11:2]];

endmodule
