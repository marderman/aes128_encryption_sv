module AES_AddRoundKey_tb;
  // Testbench signals
  logic [127:0] state_in;
  logic [127:0] round_key;
  logic [127:0] state_out;
  
  // Instantiate the AES_AddRoundKey module
  AES_AddRoundKey uut (
    .state_in(state_in),
    .round_key(round_key),
    .state_out(state_out)
  );
  
  initial begin
    // Set test vectors
    state_in  = 128'h00112233445566778899AABBCCDDEEFF;
    round_key = 128'h000102030405060708090A0B0C0D0E0F;
    #1;  // Allow time for XOR operation to propagate
    
    if (state_out !== 128'h00102030405060708090A0B0C0D0E0F0)
      $display("AES_AddRoundKey FAILED: Expected 00102030405060708090A0B0C0D0E0F0, got %h", state_out);
    else
      $display("AES_AddRoundKey PASSED: %h", state_out);
      
    $finish;
  end
endmodule
