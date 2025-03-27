module AES_Core (
    input  logic                clk,
    input  logic                rst,
    input  logic                start,           // start overall encryption process
    input  logic [127:0]        key,             // input key for KeyExpansion
    input  logic [127:0]        plaintext,       // plaintext to encrypt
    output logic                done,
    output logic [127:0]        ciphertext
);

    // Extended FSM states with WAIT states for DMA transactions.
    typedef enum logic [3:0] {
        IDLE,
        KEY_EXP,                 // Compute key expansion (assumed combinational)
        KEY_STORE,               // Issue DMA store for one round key
        KEY_STORE_WAIT,          // Wait for dma_done of key store
        LOAD_INIT,               // Issue DMA store for plaintext into state RAM
        LOAD_INIT_WAIT,          // Wait for dma_done of load init
        LOAD_KEY,                // Issue DMA load for round key from RoundKeyMemory
        LOAD_KEY_WAIT,           // Wait for dma_done of load key
        LOAD_STATE,              // Issue DMA load for previous round state from state RAM
        LOAD_STATE_WAIT,         // Wait for dma_done of load state
        COMPUTE,                 // Do AES round computation
        STORE,                   // Issue DMA store for computed state into state RAM
        STORE_WAIT,              // Wait for dma_done of store
        NEXT_ROUND,              // Increment round counter and loop
        FINISH                   // Set done signal, output ciphertext
    } state_t;
    state_t current_state, next_state;

    // Counters for key storage and rounds.
    logic [3:0] key_idx;     // index for writing 0 to 10 round keys
    logic [3:0] round;       // round index for AES rounds (0 to 10)

    // Internal registers for AES computation.
    logic [127:0] state_reg;         // current AES state (round result)
    logic [127:0] round_key_reg;     // loaded round key from DMA

    // DMA interface signals.
    logic dma_start;
    logic dma_done;
    logic dma_mode;          // 0 = load, 1 = store
    logic dma_src_sel;       // when load: 0 = RoundKeyMemory, 1 = state RAM
    logic [3:0] dma_addr;          // address used for memory access
    logic [127:0] dma_data_in;       // used in store mode
    logic [127:0] dma_data_out;      // loaded data from DMA

    // Instantiate the DMA with integrated MUX and memories.
    DMA #(
        .DATA_WIDTH(128),
        .ADDR_WIDTH(4)
    ) dma_inst (
        .clk(clk),
        .rst(rst),
        .start(dma_start),
        .mode(dma_mode),
        .src_sel(dma_src_sel),
        .addr(dma_addr),
        .data_in(dma_data_in),
        .done(dma_done),
        .data_out(dma_data_out)
    );

    // Instantiate the KeyExpansion module.
    logic [127:0] round_keys [0:10];
    AES_KeyExpansion key_exp_inst (
        .key(key),
        .round_keys(round_keys)
    );

    // Instantiate AES transformations.
    logic [127:0] subbytes_out, shiftrows_out, mixcolumns_out, round_transform, addroundkey_out;
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
        .round_key(round_key_reg),
        .state_out(addroundkey_out)
    );

    // FSM: Sequential state update.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            key_idx       <= 0;
            round         <= 0;
            state_reg     <= 128'd0;
            done          <= 1'b0;
            ciphertext    <= 128'd0;  // Explicitly clear ciphertext
        end else begin
            current_state <= next_state;
            case (current_state)
                KEY_STORE_WAIT: begin
                    if(dma_done)
                        key_idx <= key_idx + 1;
                end
                LOAD_INIT_WAIT: begin
                    if(dma_done)
                        state_reg <= plaintext;
                end
                LOAD_KEY_WAIT: begin
                    if(dma_done)
                        round_key_reg <= dma_data_out;
                end
                LOAD_STATE_WAIT: begin
                    if(dma_done)
                        state_reg <= dma_data_out;
                end
                COMPUTE: begin
                    if (round == 0)
                        state_reg <= plaintext ^ round_key_reg;
                    else
                        state_reg <= addroundkey_out;
                end
                STORE_WAIT: begin
                    // No sequential update in store wait.
                end
                NEXT_ROUND: begin
                    round <= round + 1;
                end
                FINISH: begin
                    done <= 1'b1;
                    ciphertext <= state_reg;
                end
                default: ;
            endcase
        end
    end

    // FSM: Combinational next-state and DMA control.
    always_comb begin
        // Default assignments.
        next_state  = current_state;
        dma_start   = 1'b0;
        dma_mode    = 1'b0;
        dma_src_sel = 1'b0;
        dma_addr    = 4'd0;
        dma_data_in = 128'd0;

        case (current_state)
            IDLE: begin
                if(start)
                    next_state = KEY_EXP;
            end

            KEY_EXP: begin
                next_state = KEY_STORE;
                key_idx = 0;
            end

            KEY_STORE: begin
                dma_start   = 1'b1;
                dma_mode    = 1'b1;           // store mode
                dma_src_sel = 1'b0;           // select RoundKeyMemory
                dma_addr    = key_idx;
                dma_data_in = round_keys[key_idx];
                next_state  = KEY_STORE_WAIT;
            end

            KEY_STORE_WAIT: begin
                dma_start   = 1'b0;
                dma_mode    = 1'b1;
                dma_src_sel = 1'b0;
                dma_addr    = key_idx;
                dma_data_in = round_keys[key_idx];
                next_state  = (dma_done) ? ((key_idx == 10) ? LOAD_INIT : KEY_STORE) : KEY_STORE_WAIT;
            end

            LOAD_INIT: begin
                dma_start   = 1'b1;
                dma_mode    = 1'b1;           // store mode
                dma_src_sel = 1'b1;           // select state RAM
                dma_addr    = 4'd0;
                dma_data_in = plaintext;
                next_state  = LOAD_INIT_WAIT;
            end

            LOAD_INIT_WAIT: begin
                dma_start   = 1'b0;
                dma_mode    = 1'b1;
                dma_src_sel = 1'b1;
                dma_addr    = 4'd0;
                dma_data_in = plaintext;
                next_state  = (dma_done) ? LOAD_KEY : LOAD_INIT_WAIT;
            end

            LOAD_KEY: begin
                dma_start   = 1'b1;
                dma_mode    = 1'b0;           // load mode
                dma_src_sel = 1'b0;           // select RoundKeyMemory
                dma_addr    = round;
                dma_data_in = 128'd0;
                next_state  = LOAD_KEY_WAIT;
            end

            LOAD_KEY_WAIT: begin
                dma_start   = 1'b0;
                dma_mode    = 1'b0;
                dma_src_sel = 1'b0;
                dma_addr    = round;
                dma_data_in = 128'd0;
                next_state  = (dma_done) ? ((round == 0) ? COMPUTE : LOAD_STATE) : LOAD_KEY_WAIT;
            end

            LOAD_STATE: begin
                dma_start   = 1'b1;
                dma_mode    = 1'b0;           // load mode
                dma_src_sel = 1'b1;           // select state RAM
                dma_addr    = round;
                dma_data_in = 128'd0;
                next_state  = LOAD_STATE_WAIT;
            end

            LOAD_STATE_WAIT: begin
                dma_start   = 1'b0;
                dma_mode    = 1'b0;
                dma_src_sel = 1'b1;
                dma_addr    = round;
                dma_data_in = 128'd0;
                next_state  = (dma_done) ? COMPUTE : LOAD_STATE_WAIT;
            end

            COMPUTE: begin
                next_state = STORE;
            end

            STORE: begin
                dma_start   = 1'b1;
                dma_mode    = 1'b1;           // store mode
                dma_src_sel = 1'b1;           // select state RAM
                dma_addr    = round + 1;
                dma_data_in = state_reg;
                next_state  = STORE_WAIT;
            end

            STORE_WAIT: begin
                dma_start   = 1'b0;
                dma_mode    = 1'b1;
                dma_src_sel = 1'b1;
                dma_addr    = round + 1;
                dma_data_in = state_reg;
                next_state  = (dma_done) ? ((round < 10) ? NEXT_ROUND : FINISH) : STORE_WAIT;
            end

            NEXT_ROUND: begin
                next_state = LOAD_KEY;
            end

            FINISH: begin
                next_state = FINISH;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule