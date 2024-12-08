`timescale 1ns / 100ps

module InputFIFO #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_LINES = 5
) (
    input wire clk_i,
    input wire rstn_i,
    input wire wr_en_i,   // Write Enable
    input wire rd_en_i,   // Read Enable
    input wire [DATA_WIDTH-1:0] data_i,
    
    output wire full_o, empty_o, idle_o,
    
    output wire [DATA_WIDTH-1:0] data_o
);

    reg [(1 << ADDR_LINES)-1:0] status;
    wire [ADDR_LINES - 1:0] wr_ptr, rd_ptr;
     
     PE5B cntr_write (      // Status reg's zeroes-detector
         .in(~status),
         .out(wr_ptr)
     );

     PE5B cntr_read (       // Status reg's ones-detector
         .in(status),
         .out(rd_ptr)
     );

    always @ (posedge clk_i or negedge rstn_i) begin
        if (~rstn_i)
            status <= 'b0;
        else begin
            if (wr_en_i) begin
                if(~status[wr_ptr])
                    status[wr_ptr] <= ~status[wr_ptr];
            end
            else if (rd_en_i) begin
                if (status[rd_ptr])
                    status[rd_ptr] <= ~status[rd_ptr];
            end
        end
    end
    
    // FIFO status Flags
    assign full_o = status[(1 << ADDR_LINES)-1];
    assign empty_o = (status == 'b0);
    
    assign idle_o = ~(wr_en_i | rd_en_i);
         
    // PORT A --> Write
    // PORT B --> Read
    dual_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),    // Specify RAM data width
        .ADDR_LINES(ADDR_LINES)     // Specify RAM (number of) address bits
    ) FIFO (
        .addra(wr_ptr),             // Port A address bus, width determined from RAM_DEPTH
        .addrb(rd_ptr),             // Port B address bus, width determined from RAM_DEPTH
        .dina(data_i),              // Port A RAM input data, width determined from DATA_WIDTH

        .clk_i(clk_i),              // Clock

        .wea(wr_en_i),                // Port A write enable
        .ena(~full_o),              // Port A RAM Enable, for additional power savings, disable port when not in use
        .enb(status[rd_ptr]),       // Port B RAM Enable, for additional power savings, disable port when not in use

        .rstnb(rstn_i),             // Port B output reset (does not affect memory contents)
        .regceb(rd_en_i),             // Port B output register enable

        .doutb(data_o)              // Port B RAM output data, width determined from DATA_WIDTH
    );
endmodule
