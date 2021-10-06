# ARM -ASM
## Instruction Format 
This is the standard layout used in ARM assembly: 
   `<op>{cond}{flags} Rd, Rn, Operand2 `
For example, the following code is used to add two registers together:

ADD R0, R1, R2
- < op > — Three-letter mnemonic, called the operand
- {cond} — Optional two-letter condition code
- {flags} — Optional additional flag
- Rd — Destination register
- Rn — First register
- Operand2 — Second register or second operand
