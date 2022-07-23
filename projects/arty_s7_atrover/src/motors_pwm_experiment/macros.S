.altmacro
.macro op_reg op, reg
  op x\reg, \reg*4(sp)
.endm

.macro op_regs op, start, end
  .set i,\start
  .rept \end
    op_reg sw, %i
    .set i,i+1
  .endr
.endm

.macro push_regs
  addi sp, sp, -32*4
  op_regs sw, 0, 31
.endm

.macro pop_regs
  op_regs sw, 0, 31
  addi sp, sp, 32*4
.endm
