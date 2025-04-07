module DMA #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 4,
    parameter ROM_DEPTH  = 11,   // for 11 round keys
    parameter RAM_DEPTH  = 16    // enough locations to store each round result
)(
    input  logic                      clk,
    input  logic                      rst,
    input  logic                      start,        // start transfer signal (one cycle pulse)
    input  logic                      mode,         // 0: load, 1: store
    input  logic                      src_sel,      // when load: 0 = from ROM, 1 = from RAM
    input  logic [ADDR_WIDTH-1:0]      addr,         // address
    input  logic [DATA_WIDTH-1:0]      data_in,      // used in store mode
    output logic                      done,         // transfer done (one cycle pulse)
    output logic [DATA_WIDTH-1:0]      data_out      // valid in load mode
);

    typedef enum logic [1:0] {IDLE, WAIT_1, DONE} dma_state_t;
    dma_state_t state, next_state;

    // Internal signals for memory control
    logic we_rk_mem;
    logic [ADDR_WIDTH-1:0] addr_rk_mem;
    logic [DATA_WIDTH-1:0] data_in_rk_mem;
    logic [DATA_WIDTH-1:0] data_out_rk_mem;

    logic we_state_ram;
    logic [ADDR_WIDTH-1:0] addr_state_ram;
    logic [DATA_WIDTH-1:0] data_in_state_ram;
    logic [DATA_WIDTH-1:0] data_out_state_ram;

    // Internal RoundKeyMemory instance
    RoundKeyMemory #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(ROM_DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) rk_mem (
        .clk(clk),
        .we(we_rk_mem),
        .addr(addr_rk_mem),
        .din(data_in_rk_mem),
        .dout(data_out_rk_mem)
    );

    // Internal state RAM instance
    RAM #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDR_WIDTH)
    ) state_ram (
        .clk(clk),
        .addra(addr_state_ram),
        .dina(data_in_state_ram),
        .wea(we_state_ram),
        .addrb(addr_state_ram), // Use the same address for read in this simple DMA
        .doutb(data_out_state_ram)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state           <= IDLE;
            done            <= 1'b0;
            data_out        <= '0;
            we_rk_mem       <= 1'b0;
            addr_rk_mem     <= '0;
            data_in_rk_mem  <= '0;
            we_state_ram    <= 1'b0;
            addr_state_ram  <= '0;
            data_in_state_ram <= '0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    if (start) begin
                        done <= 1'b0;
                    end
                end
                WAIT_1: begin
                    // Waiting for memory response
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
                if (start) begin
                    next_state = WAIT_1;
                    if (mode == 1'b0) begin // Load
                        if (src_sel == 1'b0) begin
                            addr_rk_mem = addr;
                            data_out = data_out_rk_mem;
                        end else begin
                            addr_state_ram = addr;
                            data_out = data_out_state_ram;
                        end
                    end else begin // Store
                        if (src_sel == 1'b0) begin
                            we_rk_mem = 1'b1;
                            addr_rk_mem = addr;
                            data_in_rk_mem = data_in;
                        end else begin
                            we_state_ram = 1'b1;
                            addr_state_ram = addr;
                            data_in_state_ram = data_in;
                        end
                    end
                end
            end
            WAIT_1: begin
                next_state = DONE;
                if (mode == 1'b0) begin
                    data_out = (src_sel == 1'b0) ? data_out_rk_mem : data_out_state_ram;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule