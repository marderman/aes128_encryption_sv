module DMA_tb;

    // Testbench parameters
    parameter DATA_WIDTH = 128;
    parameter ADDR_WIDTH = 4;
    
    // Testbench signals
    logic clk;
    logic rst;
    logic start;
    logic mode;
    logic src_sel;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] data_in;
    logic done;
    logic [DATA_WIDTH-1:0] data_out;

    // Instantiate the DUT (Device Under Test)
    DMA #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .src_sel(src_sel),
        .addr(addr),
        .data_in(data_in),
        .done(done),
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns period (100 MHz clock)

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        mode = 0;
        src_sel = 0;
        addr = 0;
        data_in = 0;

        // Reset sequence
        #10 rst = 0;
        
        // Load from ROM (addr = 2)
        #10 start = 1; mode = 0; src_sel = 0; addr = 4'h2;
        #10 start = 0;
        
        // Wait for transfer to complete
        wait(done);
        $display("Loaded Data: %h", data_out);

        // Store to RAM (addr = 5, data = 0xABCD)
        #10 start = 1; mode = 1; src_sel = 1; addr = 4'h5; data_in = 128'hABCD;
        #10 start = 0;
        
        // Wait for transfer to complete
        wait(done);

        // Load from RAM (addr = 5)
        #10 start = 1; mode = 0; src_sel = 1; addr = 4'h5;
        #10 start = 0;
        
        // Wait for transfer to complete
        wait(done);
        $display("Loaded from RAM: %h", data_out);
        
        // Finish simulation
        #50 $finish;
    end
endmodule
