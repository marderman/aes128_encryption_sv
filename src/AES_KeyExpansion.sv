module AES_KeyExpansion (
    input  logic [127:0] key,  // 128-bit cipher key
    output logic [127:0] round_keys [0:10] // 11 round keys
);

  // S-Box Lookup Table (ROM)
  logic [7:0] sbox_rom [0:255];

  // Load S-Box from file
  initial begin
    $readmemh("aes_sbox.mem", sbox_rom);
    #1; // small delay to allow file load
  end

  // Rotate Word (RotWord)
  function automatic logic [31:0] RotWord(input logic [31:0] word);
    RotWord = {word[23:0], word[31:24]};
  endfunction

  // Substitute word using S-Box lookup (SubWord)
  function automatic logic [31:0] SubWord(input logic [31:0] word);
    SubWord = {sbox_rom[word[31:24]], sbox_rom[word[23:16]], 
            sbox_rom[word[15:8]],  sbox_rom[word[7:0]]};
  endfunction

  // Rcon table
  localparam logic [31:0] rcon_table [1:10] = '{
    32'h01000000, 32'h02000000, 32'h04000000, 32'h08000000, 32'h10000000,
    32'h20000000, 32'h40000000, 32'h80000000, 32'h1B000000, 32'h36000000
  };

  function automatic logic [31:0] Rcon(input int i);
    Rcon = rcon_table[i]; // Directly reference pre-initialized constant
  endfunction

  // Intermediate words (44 x 32-bit)
  logic [31:0] w [0:43];
  logic [31:0] temp;

  // Compute key expansion in an initial block after a small delay to ensure that the S-Box is loaded.
  initial begin
    #1; // Wait for the S-Box ROM to be populated

    // Initial key assignment from input 'key'
    w[0] = key[127:96];
    w[1] = key[95:64];
    w[2] = key[63:32];
    w[3] = key[31:0];

    for (int i = 4; i < 44; i = i + 1) begin
      temp = w[i-1];
      if (i % 4 == 0)
        temp = SubWord(RotWord(temp)) ^ Rcon(i/4);
      w[i] = w[i-4] ^ temp;
    end

    // Concatenate words to form the 11 round keys
    for (int round = 0; round < 11; round = round + 1) begin
      round_keys[round] = {w[round*4], w[round*4+1], w[round*4+2], w[round*4+3]};
    end
  end
endmodule
