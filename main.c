
// #define GPKCON 0x7f008800       /*GPK控制寄存器0 */
// #define GPKDAT 0x7f008808       /*GPK数据寄存器 */
// light_led:
//         ldr r0, =GPKCON
//         ldr r1, =0x11110000     /*GPK4-7设置为output */
//         str r1, [r0]

//         ldr r0, =GPKDAT
//         ldr r1, =0xa0   /*一亮一灭 */
//         str r1, [r0]
//         mov pc, lr
#define GPKCON (volatile unsigned long*)0x7f008800
#define GPKDAT (volatile unsigned long*)0x7f008808
int gboot_main()
{
    __asm__ volatile(
        "ldr r1, =0x11110000\n"     /*GPK4-7设置为output */
        "str r1, [%0]\n"
        "ldr r1, =0xa0\n"   /*一亮一灭 */
        "str r1, [%1]\n"
        :
        :"r"(GPKCON),"r"(GPKDAT)
        :"r1" 
    );
    //*(GPKCON) = 0x11110000;
    //*(GPKDAT) = 0xa0;
    //light_led();  //C调用汇编，light_led 要声明为.global
    return 0; 
}