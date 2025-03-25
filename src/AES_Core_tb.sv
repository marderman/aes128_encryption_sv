module AES_Core_tb;

  logic clk;
  logic rst;
  logic start;
  logic done;
  logic [127:0] key;
  logic [127:0] plaintext;
  logic [127:0] ciphertext;

  // Clock generation: 10 ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  AES_Core uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .key(key),
    .plaintext(plaintext),
    .done(done),
    .ciphertext(ciphertext)
  );

  initial begin
    key       = 128'h000102030405060708090A0B0C0D0E0F;
    plaintext = 128'h00112233445566778899AABBCCDDEEFF;
    rst   = 1;
    start = 0;
    #20;
    rst = 0;
    #10;
    start = 1;
    #10;
    start = 0;
    wait(done);
    #10;
    if(ciphertext === 128'h69C4E0D86A7B0430D8CDB78070B4C55A)
      $display("TEST PASSED: Ciphertext = %h", ciphertext);
    else
      $display("TEST FAILED: Expected 69C4E0D86A7B0430D8CDB78070B4C55A, got %h", ciphertext);
    #20;
    $finish;
  end

endmodule
