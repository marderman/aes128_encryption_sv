SRC_PATH = ../src
MEM_FILE = $(SRC_PATH)/aes_sbox.mem
TESTS = ALU_tb RoundKeyMemory_tb RAM_tb DMA_tb AES_AddRoundKey_tb AES_KeyExpansion_tb AES_MixColumns_tb AES_SBOX_tb AES_ShiftRows_tb AES_SubBytes_tb AES_Core_tb

all: simulate_all

sv_compile:
	cp $(MEM_FILE) .
	xvlog -sv $(SRC_PATH)/*.sv

elaborate_all: sv_compile
	@for tb in $(TESTS); do \
	    echo "Elaborating $$tb..."; \
	    xelab -debug typical -top $$tb -snapshot $$tb"_snapshot"; \
	done

simulate_all: elaborate_all
	@for tb in $(TESTS); do \
	    echo "Simulating $$tb..."; \
	    xsim $$tb"_snapshot" -R; \
	done

simulate_dump: elaborate_all
	@for tb in $(TESTS); do \
	    echo "Simulating (dump) $$tb..."; \
	    xsim $$tb"_snapshot" -tclbatch Makefile_cfg_xsim.tcl; \
	    xsim --gui $$tb"_snapshot.wdb"; \
	done

clean:
	find . -type f ! -name 'Makefile*' -execdir rm {} +
	rm -rf xsim.dir