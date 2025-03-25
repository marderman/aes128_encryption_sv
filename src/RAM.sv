module RAM #(
  parameter DATA_WIDTH = 128, // set to 128 bits for your AES
  parameter ADDRESS_WIDTH = 4
)(
  input  logic clk,
  // PORT A (write port)
  input  logic [ADDRESS_WIDTH-1:0] addra, // write address
  input  logic [DATA_WIDTH-1:0] dina, // data input now 128 bits wide
  input  logic wea, // write enable
  // PORT B (read port)
  input  logic [ADDRESS_WIDTH-1:0] addrb, // read address
  output logic [DATA_WIDTH-1:0] doutb // data output now 128 bits wide
);

  // Define memory depth based on address width
  localparam DEPTH = 1 << ADDRESS_WIDTH;
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Write operation
  always_ff @(posedge clk) begin
    if (wea)
      mem[addra] <= dina;
  end

  // Read operation
  always_ff @(posedge clk) begin
    doutb <= mem[addrb];
  end
endmodule