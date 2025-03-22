module AES_ShiftRows (
    input  logic [127:0] state_in,   // 128-bit state in column-major order
    output logic [127:0] state_out   // 128-bit state after ShiftRows (column-major)
);

  // Extract the individual bytes from the input state.
  // According to column-major ordering:
  // Column0: s00, s10, s20, s30
  // Column1: s01, s11, s21, s31
  // Column2: s02, s12, s22, s32
  // Column3: s03, s13, s23, s33
  logic [7:0] s00, s10, s20, s30;
  logic [7:0] s01, s11, s21, s31;
  logic [7:0] s02, s12, s22, s32;
  logic [7:0] s03, s13, s23, s33;

  assign s00 = state_in[127:120];
  assign s10 = state_in[119:112];
  assign s20 = state_in[111:104];
  assign s30 = state_in[103:96];

  assign s01 = state_in[95:88];
  assign s11 = state_in[87:80];
  assign s21 = state_in[79:72];
  assign s31 = state_in[71:64];

  assign s02 = state_in[63:56];
  assign s12 = state_in[55:48];
  assign s22 = state_in[47:40];
  assign s32 = state_in[39:32];

  assign s03 = state_in[31:24];
  assign s13 = state_in[23:16];
  assign s23 = state_in[15:8];
  assign s33 = state_in[7:0];

  // Form the rows from the columns:
  // Row0: s00, s01, s02, s03
  // Row1: s10, s11, s12, s13
  // Row2: s20, s21, s22, s23
  // Row3: s30, s31, s32, s33
  logic [31:0] row0, row1, row2, row3;
  assign row0 = { s00, s01, s02, s03 };
  assign row1 = { s10, s11, s12, s13 };
  assign row2 = { s20, s21, s22, s23 };
  assign row3 = { s30, s31, s32, s33 };

  // Perform the cyclic left shifts:
  // Row0: no shift.
  // Row1: shift left by 1 byte (8 bits).
  // Row2: shift left by 2 bytes (16 bits).
  // Row3: shift left by 3 bytes (24 bits).
  logic [31:0] shifted_row0, shifted_row1, shifted_row2, shifted_row3;
  assign shifted_row0 = row0;
  assign shifted_row1 = { row1[23:0], row1[31:24] };
  assign shifted_row2 = { row2[15:0], row2[31:16] };
  assign shifted_row3 = { row3[7:0],  row3[31:8]  };

  // Reassemble the state in column-major order.
  assign state_out = { shifted_row0[31:24], shifted_row1[31:24],
                       shifted_row2[31:24], shifted_row3[31:24],
                       shifted_row0[23:16], shifted_row1[23:16],
                       shifted_row2[23:16], shifted_row3[23:16],
                       shifted_row0[15:8],  shifted_row1[15:8],
                       shifted_row2[15:8],  shifted_row3[15:8],
                       shifted_row0[7:0],   shifted_row1[7:0],
                       shifted_row2[7:0],   shifted_row3[7:0] };

endmodule
