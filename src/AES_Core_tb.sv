module AES_Core_tb;

  logic clk;
  logic reset;
  logic start;
  logic done;
  logic [127:0] key;
  logic [127:0] plaintext;
  logic [127:0] ciphertext;

  // Clock generation: 10 ns period (5 ns high, 5 ns low)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Instantiate AES_Core module
  AES_Core uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .key(key),
    .plaintext(plaintext),
    .done(done),
    .ciphertext(ciphertext)
  );

  // Test stimulus
  initial begin
    // Set the AES key (128-bit)
    key = 128'h000102030405060708090A0B0C0D0E0F;

    // Set the plaintext test vector
    plaintext = 128'h00112233445566778899AABBCCDDEEFF;

    // Apply reset
    reset = 1;
    start = 0;
    #20;
    reset = 0;
    #10;

    // Assert start for one clock cycle
    start = 1;
    #10;
    start = 0;

    // Wait until encryption is done
    wait(done == 1);
    #10;

    // Check if the computed ciphertext matches expected value
    if (ciphertext === 128'h69C4E0D86A7B0430D8CDB78070B4C55A)
      $display("TEST PASSED: Ciphertext = %h", ciphertext);
    else
      $display("TEST FAILED: Expected 69C4E0D86A7B0430D8CDB78070B4C55A, got %h", ciphertext);

    #20;
    $finish;
  end

endmodule
