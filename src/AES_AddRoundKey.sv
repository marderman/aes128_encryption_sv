module AES_AddRoundKey (
    input  logic [127:0] state_in,   // 128-bit input state
    input  logic [127:0] round_key,  // 128-bit round key
    output logic [127:0] state_out   // 128-bit output state after AddRoundKey
);

  // Dummy signal for the ALU zero output, not used in AddRoundKey.
  logic dummy_zero;

  // Instantiate the ALU module with WIDTH set to 128.
  // Set alu_op to 2'b10 to perform the XOR operation.
  ALU #(.WIDTH(128)) alu_inst (
      .operand_a(state_in),
      .operand_b(round_key),
      .alu_op(2'b10),       // XOR operation
      .result(state_out),
      .zero(dummy_zero)
  );

endmodule
