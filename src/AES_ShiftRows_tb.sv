module AES_ShiftRows_tb;
  // Testbench signals
  logic [127:0] state_in;
  logic [127:0] state_out;
  
  // Instantiate the AES_ShiftRows module
  AES_ShiftRows uut (
    .state_in(state_in),
    .state_out(state_out)
  );
  
  initial begin
    // Apply test vector (state in column-major order)
    state_in = 128'h00112233445566778899AABBCCDDEEFF;
    #1;  // Allow time for combinational logic to resolve
    
    // Expected output computed manually:
    // Expected state_out = 128'h0055AAFF4499EE3388DD2277CC1166BB
    if (state_out !== 128'h0055AAFF4499EE3388DD2277CC1166BB)
      $display("AES_ShiftRows FAILED: Expected 0055AAFF4499BB3388DD2277CC1166EE, got %h", state_out);
    else
      $display("AES_ShiftRows PASSED: %h", state_out);
      
    $finish;
  end
endmodule
