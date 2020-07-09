.text
.globl main
  
main:
    
    # t4 指向 IO 输入
    # t5 指向 IO 输出
    addi $t4,$0,1025  
    addi $t5,$0,1026

    # 读取 f0 、f1，放入t0、t1
    lw $t0,0($t4)
    lw $t1,0($t4)
 
    addi $t3,$0,10

loop:
    add $t0,$t0,$t1
    sw $t0,0($t5)

    add $t1,$t0,$t1
    sw $t1,0($t5)

    addi $t3,$t3, -1
    beq  $t3, $0, finish

    j loop
    
finish:
    j finish



