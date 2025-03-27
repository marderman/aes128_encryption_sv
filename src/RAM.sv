module RAM #(
    parameter DATA_WIDTH = 128,
    parameter ADDRESS_WIDTH = 4
)(
    input  logic                         clk,
    input  logic [ADDRESS_WIDTH-1:0]     addra,
    input  logic [DATA_WIDTH-1:0]        dina,
    input  logic                         wea,
    input  logic [ADDRESS_WIDTH-1:0]     addrb,
    output logic [DATA_WIDTH-1:0]        doutb
);
    // Memory array with explicit initialization
    logic [DATA_WIDTH-1:0] mem [2**ADDRESS_WIDTH-1:0];
    
    // Initialize memory to zeros
    initial begin
        for (int i = 0; i < 2**ADDRESS_WIDTH; i++) begin
            mem[i] = 128'd0;
        end
    end

    always_ff @(posedge clk) begin
        if (wea) begin
            mem[addra] <= dina;
        end
        doutb <= mem[addrb];
    end
endmodule