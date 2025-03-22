# aes128_encryption_sv

This project implements the AES-128 encryption algorithm in SystemVerilog for the Digital Hardware Description and Verification course at the University of Heidelberg. This [tool](https://legacy.cryptool.org/en/cto/aes-step-by-step) was used for reference.

# Building and testing

To build and test you can use the Makefile found in the verif folder. The file will compile all modules and then test them using the provided testbenches.

# Usage on NCT-Epic cluster

To run it on the NCT-Epic cluster execute the following commands in the verif folder:

```console
source /shares/nct-opt/software/xilinx/settingsZitiVivado.sh 2023.2
make
```