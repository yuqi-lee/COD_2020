.text
.globl main
  
main:
    

    # 接收 F0,放入 t0
    addi $v0,$0,5   
    syscall
    addi $t0,$v0,0 

    # 接收 F1,放入 t1
    addi $v0,$0,5   
    syscall
    addi $t1,$v0,0 


    addi $t2,$0,10
    addi $t3,$0,0

loop:
    add $t0,$t0,$t1
    addi $a0,$t0,0
    addi $v0,$0,1
    syscall

    add $t1,$t0,$t1
    addi $a0,$t1,0
    addi $v0,$0,1
    syscall

    addi $t3,$t3,1
    beq		$t2, $t3, finish

    j loop
    

finish:
    j finish



