.text
.global _start
_start:
        b reset
        ldr pc, _undifined_instruction
        ldr pc, _software_interrupt
        ldr pc, _prefetch_abort
        ldr pc, _data_abort
        ldr pc, _not_used
        ldr pc, _irq
        ldr pc, _fiq

/*  ldr pc, _reset*/       
/* ldr pc, _undifined_instruction 等价于
ldr pc, =undifined_instruction 伪指令，
即将 undifined_instruction这个异常向量地址给pc*/

_undifined_instruction: .word undifined_instruction
_software_interrupt: .word software_interrupt
_prefetch_abort: .word prefetch_abort
_data_abort: .word data_abort
_not_used: .word not_used
_irq: .word irq
_fiq: .word fiq
_reset: .word reset

undifined_instruction:
        nop
software_interrupt:
        nop
prefetch_abort:
        nop
data_abort:
        nop
not_used:
        nop
irq:
        nop
fiq:
        nop
reset:
        bl set_svc      /*初始化先进入svc模式 */
        bl set_peri_port        /*c15coprocessor 外设基地址初始化 */
        bl disable_watchdog
        bl disable_interrupt   /*关闭外部中断，mask寄存器配置全1 */
        bl disable_mmu  /*关闭mmu和cache 1.cp15协处理器使i d cache失效 2. */
        bl clock_init   /*初始化时钟 */
        bl mem_init     /*内存初始化 */
        bl copy_to_ram /*将steppingstone的代码考到内存起点  */
        bl init_stack  /*初始化堆栈 */
        bl clean_bss   /*bss段初始化 */
        ldr pc, =gboot_main /*跳转到内存执行c语言程序 */
        @ bl light_led   /*不要忘记外设及地址初始化,否则外设无法使用（6410） */
       

set_svc:
        mrs r0, cpsr
        bic r0, r0,#0x1f
        orr r0, r0,#0xD3   /*设置svc的同时，将IRQ和FIQ屏蔽 */
        msr cpsr, r0
        mov pc, lr  /*国嵌没加返回，可能后续会加 */

set_peri_port:          /*把外设的基地址告诉CPU*/ 
        ldr r0, =0x70000000  /*对于6410来说,内存(0x00000000～0x60000000),外设(0x70000000-0x7fffffff)*/
        orr r0, r0, #0x13   /*外设大小:256M 0x70000013*/
        mcr p15,0,r0,c15,c2,4 /*把r0的值(包括了外设基地址+外设大小)告诉cpu*/
        mov pc,  lr

#define pWTCON 0x7E004000;  /*看门狗控制器地址 */
disable_watchdog:
        ldr r0, =pWTCON
        mov r1, #0x0
        str r1, [r0]
        mov pc, lr   /*国嵌没加返回，可能后续会加 */

disable_interrupt:  /*屏蔽内部中断,寄存器vic0 vic1，外部中断通过gpio，有其他寄存器控制 */
        ldr r0, =0x71200014
        mvn r1, #0x0
        str r1, [r0]
        ldr r0, =0x71300014
        str r1, [r0]
        mov pc, lr

disable_mmu:  /*关闭mmu和cache 1.cp15协处理器使i d cache失效 2.关闭mmu和dcache，icache可不关 */
        MCR p15, 0, r0, c7, c7, 0   
        MRC p15, 0, r0, c1, c0, 0
        bic r0, r0,#0x0000007/*将低三位清0 */
        MCR p15, 0, r0, c1, c0, 0
        mov pc, lr


#define CLK_DIV0 0x7e00f020
#define OTHERS 0x7e00f900
#define MPLL_CON 0x7e00f010
#define APLL_CON 0x7e00f00c
#define CLK_SRC 0x7e00f01c
#define ARM_RATIO    0  /*ARMCLK = DOUTAPLL / (ARM_RATIO + 1)  	= 532/(0+1) = 532  MHz */ 
#define MPLL_RATIO   0  /* DOUTMPLL = MOUTMPLL / (MPLL_RATIO + 1)   = 532/(0+1) = 532  MHz*/ 
#define HCLKX2_RATIO 1  /*HCLKX2 = HCLKX2IN / (HCLKX2_RATIO + 1) = 532/(1+1) = 266  MHz */
#define HCLK_RATIO   1  /*HCLK 	= HCLKX2   / (HCLK_RATIO + 1)   = 266/(1+1) = 133  MHz */ 
#define PCLK_RATIO   3  /*PCLK   = HCLKX2   / (PCLK_RATIO + 1)   = 266/(3+1) = 66.5 MHz */
#define APLL_CON_VAL  ((1<<31) | (266 << 16) | (3 << 8) | (1 << 0))
#define MPLL_CON_VAL  ((1<<31) | (266 << 16) | (3 << 8) | (1 << 0)) /*MPLL APLL都设置为533MHz */
#define MPLL_SEL 1
#define APLL_SEL 1      /*选择PLL作为时钟源 */
clock_init:
        /*  1. 设置各PLL的LOCK_TIME,使用默认值,下面又重新配置了一遍，其实不配置按照默认值也是一样*/ 
	ldr r0, =0x7E00F000  	/*  APLL_LOCK，供cpu使用 */
	ldr r1, =0x0000FFFF
	str r1, [r0]
	str r1, [r0, #4]	/* MPLL_LOCK，供AHB(存储/中断/lcd等控制器)/APB(看门狗，定时器，SD等)总线上的设备使用 */ 
	str r1, [r0, #8]	/* EPLL_LOCK，供UART,IIS,IIC使用 */ 
        /*  2. 设置为异步模式(Asynchronous mode)*/  
	ldr r0, =OTHERS	/*OTHERS寄存器 */ 
	bic r1, r1, #0xc0	/* bit[6:7]清0,即SYNCMODE=0/SYNCMUXSEL=0,第六位设置使用MPll产生clk，见手册图*/ 
        str r1, [r0]
        /*  3. 设置时钟分频系数   */ 
        ldr r0, =CLK_DIV0
	ldr r1, =(ARM_RATIO << 0) | (HCLK_RATIO << 8) | (HCLKX2_RATIO << 9) | (PCLK_RATIO << 12)
	str r1, [r0]
        /*  4. 设置PLL,放大时钟*/  
	/*  4.1 配置APLL  */
	ldr r0, =APLL_CON	
	ldr r1, =APLL_CON_VAL	/*FOUT = MDIV X FIN / (PDIV X 2SDIV) = 266*12/(3*2^1) = 532MHz */
	str r1, [r0]		
	/*4.2 配置MPLL */   
	ldr r0, =MPLL_CON	
	ldr r1, =MPLL_CON_VAL	 /*FOUT = MDIV X FIN / (PDIV X 2SDIV) = 266*12/(3*2^1) = 532MHz */
	str r1, [r0]		
	/*5.选择PLL的输出作为时钟源 */   
	ldr r0, =CLK_SRC	
	ldr r1, =(MPLL_SEL << 1) | (APLL_SEL << 0)
	str r1, [r0]
	mov pc, lr	



#define GPKCON 0x7f008800       /*GPK控制寄存器0 */
#define GPKDAT 0x7f008808       /*GPK数据寄存器 */
.global light_led
light_led:
        ldr r0, =GPKCON
        ldr r1, =0x11110000     /*GPK4-7设置为output */
        str r1, [r0]

        ldr r0, =GPKDAT
        ldr r1, =0xa0   /*一亮一灭 */
        str r1, [r0]
        mov pc, lr
/*复制4k sram 到内存 */
copy_to_ram:
        ldr r0, =0x0c000000  //起点(垫脚石)
        ldr r1, =0x50008000  //终点（内存）
        add r3, r0, #4*1024  //复制4k空间的代码,因为6410的垫脚石是4k
copy_loop:
        ldr r2, [r0], #4
        str r2, [r1], #4
        cmp r0, r3
        bne copy_loop
        mov pc, lr
/*在内存初始化64mb的堆栈，由于是满减栈，因此从内存起始地址向上取64M作为栈底指针sp的位置，即54000000 */
init_stack: 
        ldr sp,=0x54000000
        mov pc ,lr 

clean_bss:
        ldr r0, =bss_start
        ldr r1, =bss_end
        cmp r0, r1
        moveq pc, lr   // bss为空 直接返回，否则执行下面的clean_loop清除bss
clean_loop:
        mov r2,#0
        str r2, [r0], #4
        cmp r0,r1
        bne clean_loop
        mov pc, lr

