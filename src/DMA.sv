module DMA #(
  parameter DATA_WIDTH = 128,
  parameter ADDR_WIDTH = 4,
  parameter ROM_DEPTH  = 11,   // for 11 round keys
  parameter RAM_DEPTH  = 16    // enough locations to store each round result
)(
  input  logic                   clk,
  input  logic                   rst,
  input  logic                   start,       // start transfer signal (one cycle pulse)
  input  logic                   mode,        // 0: load, 1: store
  input  logic                   src_sel,     // when load: 0 = from ROM, 1 = from RAM
  input  logic [ADDR_WIDTH-1:0]  addr,        // address (not used by the MUX but provided for consistency)
  input  logic [DATA_WIDTH-1:0]  data_in,     // used in store mode
  input  logic [DATA_WIDTH-1:0]  data_in_rom, // data coming from RoundKeyMemory (ROM)
  input  logic [DATA_WIDTH-1:0]  data_in_ram, // data coming from state RAM
  output logic                   done,        // transfer done (one cycle pulse)
  output logic [DATA_WIDTH-1:0]  data_out     // valid in load mode
);

  typedef enum logic [1:0] {IDLE, WAIT_1, DONE} dma_state_t;
  dma_state_t state, next_state;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state    <= IDLE;
      done     <= 1'b0;
      data_out <= '0;
    end else begin
      state <= next_state;
      case (state)
        IDLE: begin
          if (start) begin
            done <= 1'b0;
            if (mode == 1'b0) begin // Load mode
              data_out <= (src_sel == 1'b0) ? data_in_rom : data_in_ram;
            end
          end
        end
        WAIT_1: begin
          // Nothing happens, just waiting
        end
        DONE: begin
          done <= 1'b1;
        end
      endcase
    end
  end

  always_comb begin
    next_state = state;

    case (state)
      IDLE: begin
        if (start) next_state = WAIT_1;
      end
      WAIT_1: begin
        next_state = DONE;
      end
      DONE: begin
        next_state = IDLE;
        done = 1'b1;
      end
    endcase
  end

endmodule
