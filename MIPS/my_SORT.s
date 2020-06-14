.text
.globl main
  
main:
    # 打印字符串，提示用户输入待排序数组长度
    la $a0,string_1 
    li $v0,4
    syscall

    # 接收用户收入的数组长度,并放入t1
    li $v0,5   
    syscall
    addi $t1,$v0,0     

    
    # 将 t0,t2 清零,将数组起始地址放入 t4
    addi $t0,$zero,0   
    addi $t2,$zero,0   
    la $t4,arraylist     



#输入部分
input:               
    # 打印字符串，提示用户输入数组的元素
    la $a0,string_2  
    li $v0,4
    syscall
    li $v0,5
    syscall

    #求得 arraylist[i] ; 每个 int 型数据占 4 个字长
    addi $s0,$t0,0     
    mul $s0,$s0,4    
    addu $s1,$s0,$t4            #s1 为指向arraylist[i]的指针
    sw $v0,0($s1)

    addi $t0,$t0,1
    blt $t0,$t1,input


    addi $t0,$zero,0  
    
    #计算开始时间
    li $v0,30
    syscall
    addi $s6,$a0,0
  
loop_1:
    addi $t2,$zero,0    
loop_2:
    #计算并a[i]地址,并取出a[i],a[i+1]
    addi $s0,$t2,0     
    mul $s0,$s0,4
    addu $s1,$s0,$t4
    lw $s2,0($s1)
    lw $t3,4($s1)    
    

    #判断是否需要交换
    bge $s2,$t3,target  
    sw $t3,0($s1)   
    sw $s2,4($s1)    

target:
    #判断是否进行内部循环
    addi $t2,$t2,1   
    addi $s0,$t2,1   
    sub $s1,$t1,$t0    
    blt $s0,$s1,loop_2  

    #判断是否进行外部循环
    addi $t0,$t0,1     
    sub $s2,$t1,1
    blt $t0,$s2,loop_1  

    #计算结束时间
    li $v0,30
    syscall
    addi $s7,$a0,0

output:
    #输出提示字符串
    la $a0,string_3  
    li $v0,4
    syscall

    addi $t0,$zero,0   

print:          
    # 打印数组元素
    addi $s0,$t0,0
    mul $s0,$s0,4
    addu $s1,$s0,$t4    
    lw $a0,0($s1)
    li $v0,1
    syscall
    la $a0,string_5
    li $v0,4
    syscall

    #判断是否还进行循环
    addi $t0,$t0,1
    blt $t0,$t1,print 

    la $a0,string_4
    li $v0,4
    syscall

    sub $a0,$s7,$s6		
    li $v0,1
    syscall

    li $v0,10
    syscall


.data
arraylist:.space 1024
string_1:.asciiz "INPUT the number of data:\n"
string_2:.asciiz "INPUT the data:\n"
string_3:.asciiz "OUTPUT:\n"
string_4:.asciiz "\nSorting time: "
string_5:.asciiz "  "

