module RoundKeyMemory_tb;

    // Testbench parameters
    parameter DATA_WIDTH = 128;
    parameter DEPTH = 11;
    parameter ADDR_WIDTH = 4;
    
    // Testbench signals
    logic clk;
    logic we;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] din;
    logic [DATA_WIDTH-1:0] dout;

    // Instantiate the DUT (Device Under Test)
    RoundKeyMemory #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns period (100 MHz clock)

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        we = 0;
        addr = 0;
        din = 0;
        
        // Write to memory address 3
        #10 we = 1; addr = 4'h3; din = 128'hDEADBEEF12345678;
        #10 we = 0;
        
        // Read from memory address 3
        #10 addr = 4'h3;
        #10;
        $display("Read Data from address 3: %h", dout);
        
        // Write to memory address 7
        #10 we = 1; addr = 4'h7; din = 128'hCAFEBABE87654321;
        #10 we = 0;
        
        // Read from memory address 7
        #10 addr = 4'h7;
        #10;
        $display("Read Data from address 7: %h", dout);
        
        // Finish simulation
        #50 $finish;
    end
endmodule
