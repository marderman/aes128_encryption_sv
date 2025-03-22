module AES_SubBytes_tb;
  // Testbench signals
  logic [127:0] state_in;
  logic [127:0] state_out;
  
  // Instantiate the AES_SubBytes module
  AES_SubBytes uut (
    .state_in(state_in),
    .state_out(state_out)
  );
  
  initial begin
    // Test Vector 1:
    // Input: All bytes are 0x00, each 0x00 is substituted by 0x63 per AES standard SBOX.
    // Expected output: 16 copies of 0x63 -> 128'h63636363636363636363636363636363
    state_in = 128'h00000000000000000000000000000000;
    #1;  // Allow combinational logic to settle
    if (state_out !== 128'h63636363636363636363636363636363)
      $display("AES_SubBytes FAILED for all zeros: Expected 63636363636363636363636363636363, got %h", state_out);
    else
      $display("AES_SubBytes PASSED for all zeros: %h", state_out);
      
    // Test Vector 2:
    // Input: A state with increasing bytes: 0x00, 0x01, 0x02, ... 0x0F.
    // Due to the instance ordering in AES_SubBytes, the most-significant byte corresponds to 0x00, and the least-significant byte corresponds to 0x0F.
    // Standard AES SBOX substitution for these values is:
    // 0x00 -> 0x63, 0x01 -> 0x7c, 0x02 -> 0x77, 0x03 -> 0x7b,
    // 0x04 -> 0xf2, 0x05 -> 0x6b, 0x06 -> 0x6f, 0x07 -> 0xc5,
    // 0x08 -> 0x30, 0x09 -> 0x01, 0x0A -> 0x67, 0x0B -> 0x2b,
    // 0x0C -> 0xfe, 0x0D -> 0xd7, 0x0E -> 0xab, 0x0F -> 0x76.
    // Therefore, expected output is 128'h637c777bf26b6fc53001672bfed7ab76.
    state_in = 128'h000102030405060708090a0b0c0d0e0f;
    #1;
    if (state_out !== 128'h637c777bf26b6fc53001672bfed7ab76)
      $display("AES_SubBytes FAILED for incremental bytes: Expected 637c777bf26b6fc53001672bfed7ab76, got %h", state_out);
    else
      $display("AES_SubBytes PASSED for incremental bytes: %h", state_out);
      
    $finish;
  end
endmodule
