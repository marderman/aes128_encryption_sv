module AES_SBOX (
    input logic [7:0] sbox_in,  // 8-bit input byte to be substituted
    output logic [7:0] sbox_out // 8-bit substituted output
);
    // Define the SBOX as a ROM
    logic [7:0] sbox_rom [0:255];
    
    // Initialize the ROM with values from a file
    initial begin
        $readmemh("aes_sbox.mem", sbox_rom);
    end
    
    // Combinational lookup - no clock needed
    assign sbox_out = sbox_rom[sbox_in];
    
endmodule