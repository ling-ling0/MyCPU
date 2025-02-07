# MyCPU
> 浙江大学计算机系统系列贯通课程实验项目
>
> 此仓库中只存储编写的部分代码, 项目整体工具链和环境配置请参考 浙江大学计算机系统贯通课程仓库

### 项目简介
使用Verilog、C、C++、汇编语言等语言自底向上实现基于 RISC-V 指令集的五级流水线 CPU, 并实现部分特权指令, 实现用户态与内核态的分离, 并在其上运行自己编写的简易系统软件代码, 实现线程调度等系统底层功能.
### 项目结构
* hardware
  硬件部分
  
  使用硬件描述语言 Verilog 和 Systemverilog进行 CPU 的电路设计, 采用模块化的思想, 实现五级流水线 CPU。
  
  功能实现：
  * 流水线CPU中的stall(竞争)和forwarding(前递)处理
  * 特权指令处理(CSR寄存器流水线)
  * 基于BHT(branch-history table)和BTB(branch-target buffer)的动态分支预测
  * 二路组相连Cache(高速缓存)
  * MMU(Memory Management Unit,内存管理单元),实现虚实地址翻译和访问权限控制
  
* kernel
  软件内核代码

  使用 RISC-V 汇编和C++语言编写 Linux 内核启动部分代码, 实现简易操作系统的运行, 并采用 OpenSBI 作为软硬件接口在上述硬件代码上正确运行起来.

  功能实现：
  * 中断处理(时钟中断)
  * 线程调度(使用最短剩余时间优先算法)
  * 基于SV39模式的虚拟内存系统
  * 用户模式和内核模式的分离
  * 虚拟内存缺页处理(demand paging)
  * fork系统调用(使用copy-on-write机制)
