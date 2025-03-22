module AES_Core(
    input  logic         clk,
    input  logic         reset,
    input  logic         start,
    input  logic [127:0] key,         // 128-bit cipher key
    input  logic [127:0] plaintext,   // 128-bit plaintext
    output logic         done,        // Completion signal
    output logic [127:0] ciphertext   // 128-bit ciphertext
);

  typedef enum logic [1:0] {
    IDLE, INIT, ROUND, FINISH
  } state_t;
  state_t current_state, next_state;

  logic [127:0] state_reg;
  logic [3:0]   round;

  // Key Expansion Module
  logic [127:0] round_keys [0:10];
  AES_KeyExpansion key_exp_inst (
      .key(key),
      .round_keys(round_keys)
  );

  // AES Transformations
  logic [127:0] subbytes_out, shiftrows_out, mixcolumns_out, round_transform, addroundkey_out, init_state;

  AES_SubBytes subbytes_inst (
      .state_in(state_reg),
      .state_out(subbytes_out)
  );

  AES_ShiftRows shiftrows_inst (
      .state_in(subbytes_out),
      .state_out(shiftrows_out)
  );

  AES_MixColumns mixcolumns_inst (
      .state_in(shiftrows_out),
      .state_out(mixcolumns_out)
  );

  assign round_transform = (round == 10) ? shiftrows_out : mixcolumns_out;

  AES_AddRoundKey addroundkey_inst (
      .state_in(round_transform),
      .round_key(round_keys[round]),
      .state_out(addroundkey_out)
  );

  AES_AddRoundKey addroundkey_init_inst (
      .state_in(plaintext),
      .round_key(round_keys[0]),
      .state_out(init_state)
  );

  // FSM and State Register Update
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= IDLE;
      round         <= 0;
      state_reg     <= 128'd0;
      done          <= 1'b0;
      ciphertext    <= 128'd0;
    end else begin
      current_state <= next_state;

      case (current_state)
        IDLE: begin
          done <= 1'b0;
        end

        INIT: begin
          state_reg <= init_state;
          round     <= 1;
        end

        ROUND: begin
          state_reg <= addroundkey_out;
          if (round < 10)
            round <= round + 1;
        end

        FINISH: begin
          done       <= 1'b1;
          ciphertext <= state_reg;
        end
      endcase
    end
  end

  // FSM Logic
  always_comb begin
    next_state = current_state;
    case (current_state)
      IDLE:    if (start) next_state = INIT;
      INIT:    next_state = ROUND;
      ROUND:   if (round == 10) next_state = FINISH;
      FINISH:  next_state = FINISH;
    endcase
  end

endmodule
