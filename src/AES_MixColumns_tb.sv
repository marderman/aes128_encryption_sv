module AES_MixColumns_tb;
  // Testbench signals
  logic [127:0] state_in;
  logic [127:0] state_out;
  
  // Instantiate the AES_MixColumns module
  AES_MixColumns uut (
    .state_in(state_in),
    .state_out(state_out)
  );
  
  initial begin
    // Set test vector: Column0 = d4 bf 5d 30, and columns 1-3 = 0
    state_in = 128'hd4bf5d30000000000000000000000000;
    #1;  // Allow combinational logic to settle
    
    // Expected output: Column0 becomes 04 66 81 e5; others remain zero.
    if (state_out !== 128'h046681e5000000000000000000000000)
      $display("AES_MixColumns FAILED: Expected 046681e5000000000000000000000000, got %h", state_out);
    else
      $display("AES_MixColumns PASSED: %h", state_out);
      
    $finish;
  end
endmodule
