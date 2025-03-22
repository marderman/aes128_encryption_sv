module AES_SBOX_tb;
  // Testbench signals
  logic [7:0] sbox_in;
  logic [7:0] sbox_out;
  
  // Instantiate the AES_SBOX module
  AES_SBOX uut (
    .sbox_in(sbox_in),
    .sbox_out(sbox_out)
  );
  
  initial begin
    // Test vector 1: for input 0x00, the AES SBOX output should be 0x63
    sbox_in = 8'h00;
    #1;  // Allow combinational logic to settle
    if (sbox_out !== 8'h63)
      $display("AES_SBOX FAILED for input 0x00: Expected 63, got %h", sbox_out);
    else
      $display("AES_SBOX PASSED for input 0x00: %h", sbox_out);
      
    // Test vector 2: for input 0x53, the AES SBOX output should be 0xed
    sbox_in = 8'h53;
    #1;
    if (sbox_out !== 8'hed)
      $display("AES_SBOX FAILED for input 0x53: Expected ed, got %h", sbox_out);
    else
      $display("AES_SBOX PASSED for input 0x53: %h", sbox_out);
      
    $finish;
  end
endmodule