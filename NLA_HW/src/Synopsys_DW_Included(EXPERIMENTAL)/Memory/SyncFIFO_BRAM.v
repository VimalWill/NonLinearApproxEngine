`timescale 1ns / 100ps

module SyncFIFO_BRAM #(
    parameter RAM_WIDTH = 32,
    parameter ADDR_LINES = 12
) (
    input wire clk_i,
    input wire rstn_i,
    input wire wr_en,   // Write Enable
    input wire rd_en,   // Right Enable
    input wire [RAM_WIDTH-1:0] data_i,
    
    output wire full_o,
    output wire empty_o,
    
    output wire start_o,
    output wire [RAM_WIDTH-1:0] data_o
);

    reg [(1 << ADDR_LINES) - 1:0] status;
    wire [ADDR_LINES - 1:0] wr_ptr, rd_ptr;

    DW01_prienc #((1 << ADDR_LINES), ADDR_LINES)      // Status reg's zeroes-detector by DesignWare
    U1 ( .A(~status), .INDEX(wr_ptr) );

    DW01_prienc #((1 << ADDR_LINES), ADDR_LINES)      // Status reg's zeroes-detector by DesignWare
    U2 ( .A(status), .INDEX(rd_ptr) );

    always @ (posedge clk_i or negedge rstn_i) begin
        if (~rstn_i)
            status <= 'b0;
        else begin
            if (wr_en) begin
                if(~status[wr_ptr])
                    status[wr_ptr] <= ~status[wr_ptr];
            end
            else if (rd_en) begin
                if (status[rd_ptr])
                    status[rd_ptr] <= ~status[rd_ptr];
            end
        end
    end
    
    assign full_o = status[(1 << ADDR_LINES) - 1] && 1'b1;
    assign empty_o = ~(status[0] || 'b0); // NOR gate
    
    assign start_o = data_i == 32'b01111111100100000000000000000000; // NaN
     
    // PORT A --> Write
    // PORT B --> Read
    dual_port_ram #(
        .RAM_WIDTH(RAM_WIDTH),              // Specify RAM data width
        .ADDR_LINES(ADDR_LINES)             // Specify RAM (number of) address bits
    ) FIFO (
        .addra(wr_ptr),   // Port A address bus, width determined from RAM_DEPTH
        .addrb(rd_ptr),   // Port B address bus, width determined from RAM_DEPTH
        .dina(data_i),    // Port A RAM input data, width determined from RAM_WIDTH
        .dinb(),          // Port B RAM input data, width determined from RAM_WIDTH

        .clk_i(clk_i),    // Clock

        .wea(wr_en & ~start_o),      // Port A write enable
        .web(1'b0),       // Port B write enable
        .ena(~full_o),       // Port A RAM Enable, for additional power savings, disable port when not in use
        .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
        
        .rstna(rstn_i),   // Port A output reset (does not affect memory contents)
        .rstnb(rstn_i),   // Port B output reset (does not affect memory contents)
        .regcea(1'b0),    // Port A output register enable
        .regceb(rd_en),   // Port B output register enable
        
        .douta(),         // Port A RAM output data, width determined from RAM_WIDTH
        .doutb(data_o)    // Port B RAM output data, width determined from RAM_WIDTH
    );

endmodule
