module AES_KeyExpansion_tb;

  // Initialize the key at declaration so it’s known at time 0.
  logic [127:0] key = 128'h000102030405060708090A0B0C0D0E0F;
  logic [127:0] round_keys [0:10];

  // Instantiate the Key Expansion module
  AES_KeyExpansion uut (
      .key(key),
      .round_keys(round_keys)
  );

  // Declare expected round keys explicitly
  logic [127:0] expected_keys [0:10];

  initial begin
    #10; // Allow time for computation

    // Expected round keys (from FIPS-197)
    expected_keys[0]  = 128'h000102030405060708090A0B0C0D0E0F;
    expected_keys[1]  = 128'hD6AA74FDD2AF72FADAA678F1D6AB76FE;
    expected_keys[2]  = 128'hB692CF0B643DBDF1BE9BC5006830B3FE;
    expected_keys[3]  = 128'hB6FF744ED2C2C9BF6C590CBF0469BF41;
    expected_keys[4]  = 128'h47F7F7BC95353E03F96C32BCFD058DFD;
    expected_keys[5]  = 128'h3CAAA3E8A99F9DEB50F3AF57ADF622AA;
    expected_keys[6]  = 128'h5E390F7DF7A69296A7553DC10AA31F6B;
    expected_keys[7]  = 128'h14F9701AE35FE28C440ADF4D4EA9C026;
    expected_keys[8]  = 128'h47438735A41C65B9E016BAF4AEBF7AD2;
    expected_keys[9]  = 128'h549932D1F08557681093ED9CBE2C974E;
    expected_keys[10] = 128'h13111D7FE3944A17F307A78B4D2B30C5;

    // Compare generated round keys with expected values
    for (int i = 0; i < 11; i++) begin
      if (round_keys[i] !== expected_keys[i])
        $display("TEST FAILED: Round %0d Expected %h, Got %h", i, expected_keys[i], round_keys[i]);
      else
        $display("Round %0d PASSED: %h", i, round_keys[i]);
    end

    $finish;
  end
endmodule
