# 综合实验

在之前设计的 CPU 基础上（主要是单周期 CPU），增添了总线以及 I/O 接口，之后用该体系实现了一个简单应用。

 
# 文件介绍

* *.v          **设计文件**与**仿真文件** ,大致结构如下   
bus.v  
├── I:O  
│   └── IO_interface.v  
├── cpu  
│   ├── alu.v   
│   ├── alu_control.v    
│   ├── control.v  
│   ├── cpu_one_cycle.v   
│   └── register_file.v  
└── mem  
     └── mem.v  
     
    而fibo_tb.v为**仿真文件**
    
* fibo.asm 	    **汇编代码**
* test.coe        **IP核初始化文件**
* report.pdf      **实验文档**