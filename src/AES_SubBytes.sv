module AES_SubBytes (
    input logic [127:0] state_in,
    output logic [127:0] state_out
);
    // Generate 16 AES_SBOX instances - one for each byte
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : sbox_gen
            AES_SBOX sbox_inst (
                .sbox_in(state_in[127 - i*8 -: 8]),
                .sbox_out(state_out[127 - i*8 -: 8])
            );
        end
    endgenerate
endmodule