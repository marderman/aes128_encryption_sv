module RAM_tb;

    // Testbench parameters
    parameter DATA_WIDTH = 128;
    parameter ADDRESS_WIDTH = 4;
    
    // Testbench signals
    logic clk;
    logic wea;
    logic [ADDRESS_WIDTH-1:0] addra;
    logic [DATA_WIDTH-1:0] dina;
    logic [ADDRESS_WIDTH-1:0] addrb;
    logic [DATA_WIDTH-1:0] doutb;

    // Instantiate the DUT (Device Under Test)
    RAM #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) uut (
        .clk(clk),
        .addra(addra),
        .dina(dina),
        .wea(wea),
        .addrb(addrb),
        .doutb(doutb)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns period (100 MHz clock)

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        wea = 0;
        addra = 0;
        addrb = 0;
        dina = 0;
        
        // Write to memory address 2
        #10 wea = 1; addra = 4'h2; dina = 128'h1234567890ABCDEF;
        #10 wea = 0;
        
        // Read from memory address 2
        #10 addrb = 4'h2;
        #10;
        $display("Read Data from address 2: %h", doutb);
        
        // Write to memory address 5
        #10 wea = 1; addra = 4'h5; dina = 128'hFEDCBA0987654321;
        #10 wea = 0;
        
        // Read from memory address 5
        #10 addrb = 4'h5;
        #10;
        $display("Read Data from address 5: %h", doutb);
        
        // Finish simulation
        #50 $finish;
    end
endmodule
