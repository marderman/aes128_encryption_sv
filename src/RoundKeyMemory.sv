module RoundKeyMemory #(
    parameter DATA_WIDTH = 128,
    parameter DEPTH = 11,
    parameter ADDR_WIDTH = 4
)(
    input  logic                      clk,
    input  logic                      we,
    input  logic [ADDR_WIDTH-1:0]     addr,
    input  logic [DATA_WIDTH-1:0]     din,
    output logic [DATA_WIDTH-1:0]     dout
);
    // Memory array with explicit initialization
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    
    // Initialize memory to zeros
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            mem[i] = 128'd0;
        end
    end

    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
        dout <= mem[addr];
    end
endmodule