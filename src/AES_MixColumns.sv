module AES_MixColumns (
    input  logic [127:0] state_in,   // 128-bit state in column-major order
    output logic [127:0] state_out   // 128-bit state after MixColumns
);

  // Extract the 4 columns directly.
  logic [31:0] col0, col1, col2, col3;
  assign col0 = state_in[127:96];
  assign col1 = state_in[95:64];
  assign col2 = state_in[63:32];
  assign col3 = state_in[31:0];

  // Function: xtime - multiply a byte by 2 in GF(2⁸)
  function automatic logic [7:0] xtime(input logic [7:0] b);
    xtime = {b[6:0], 1'b0} ^ (8'h1B & {8{b[7]}});
  endfunction

  // Function: mix_column - perform the MixColumns transformation on one column.
  function automatic logic [31:0] mix_column(input logic [31:0] col);
    logic [7:0] a0, a1, a2, a3;
    logic [7:0] b0, b1, b2, b3;
    begin
      a0 = col[31:24];
      a1 = col[23:16];
      a2 = col[15:8];
      a3 = col[7:0];
      b0 = xtime(a0) ^ (xtime(a1) ^ a1) ^ a2 ^ a3;
      b1 = a0 ^ xtime(a1) ^ (xtime(a2) ^ a2) ^ a3;
      b2 = a0 ^ a1 ^ xtime(a2) ^ (xtime(a3) ^ a3);
      b3 = (xtime(a0) ^ a0) ^ a1 ^ a2 ^ xtime(a3);
      mix_column = {b0, b1, b2, b3};
    end
  endfunction

  // Apply mix_column to each column.
  logic [31:0] new_col0, new_col1, new_col2, new_col3;
  assign new_col0 = mix_column(col0);
  assign new_col1 = mix_column(col1);
  assign new_col2 = mix_column(col2);
  assign new_col3 = mix_column(col3);

  // Reassemble the output state (still in column-major order).
  assign state_out = { new_col0, new_col1, new_col2, new_col3 };

endmodule
