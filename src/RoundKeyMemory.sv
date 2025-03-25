module RoundKeyMemory #(
  parameter DATA_WIDTH = 128,
  parameter DEPTH = 11,
  parameter ADDR_WIDTH = $clog2(DEPTH)
)(
  input  logic                   clk,
  input  logic                   we,     // write enable
  input  logic [ADDR_WIDTH-1:0]  addr,   // address for both write and read
  input  logic [DATA_WIDTH-1:0]  din,    // data input for writing
  output logic [DATA_WIDTH-1:0]  dout    // data output for reading
);
  // Use a simple register array
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  logic [DATA_WIDTH-1:0] read_data;

  // Write operation
  always_ff @(posedge clk) begin
    if (we)
      mem[addr] <= din;
  end

  // Read operation
  always_ff @(posedge clk) begin
    read_data <= mem[addr];
  end

  // Output register for better timing
  always_ff @(posedge clk) begin
    dout <= read_data;
  end
endmodule