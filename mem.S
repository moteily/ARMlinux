.text
.global mem_init
mem_init:
   /*设置data pin 16 */
    ldr r0, =0x7e00f120
    mov r1, #0x0
    str r1, [r0]
    /*DRAM控制器初始化顺序 */
    ldr r0, =0x7e001004
    mov r1, #0x4
    str r1, [r0]

    ldr r0, =0x7e001010
    ldr r1, =((7800/(1000000000/133000000)+1))
    str r1, [r0]

    //CAS
    ldr r0, =0x7e001014
    mov r1, #(3<<1)
    str r1, [r0]

    //t_DQSS
    ldr r0, =0x7e001018
    mov r1, #0x1
    str r1, [r0]

    //T_MRD
    ldr r0, =0x7e00101c
    mov r1, #0x2
    str r1, [r0]

    //t_RAS
    ldr r0, =0x7e001020
    ldr r1, =((45/(1000000000/133000000)+1))
    str r1, [r0]

    //t_RC
    ldr r0, =0x7e001024
    ldr r1, =((68/(1000000000/133000000)+1))
    str r1, [r0]

    //t_RCD
    ldr r0, =0x7e001028
    ldr r1, =((23/(1000000000/133000000)+1))
    str r1, [r0]

    //t_RFC
    ldr r0, =0x7e00102c
    ldr r1, =((80/(1000000000/133000000)+1))
    str r1, [r0]

    //t_RP
    ldr r0, =0x7e001030
    ldr r1, =((23/(1000000000/133000000)+1))
    str r1, [r0]

    //t_rrd
    ldr r0, =0x7e001034
    ldr r1, =((15/(1000000000/133000000)+1))
    str r1, [r0]

    //t_wr
    ldr r0, =0x7e001038
    ldr r1, =((15/(1000000000/133000000)+1))
    str r1, [r0]

    //t_wtr
    ldr r0, =0x7e00103c
    mov r1, #0x07
    str r1, [r0]

    //t_xp
    ldr r0, =0x7e001040
    mov r1, #0x02
    str r1, [r0]

    //t_xsr
    ldr r0, =0x7e001044
    ldr r1, =((120/(1000000000/133000000)+1))
    str r1, [r0]

    //t_esr
    ldr r0, =0x7e001048
    ldr r1, =((120/(1000000000/133000000)+1))
    str r1, [r0]

    ldr r0, =0x7e00100c
    ldr r1, =0x00010012
    str r1, [r0]

    ldr r0, =0x7e00104c
    ldr r1, =0x0b45
    str r1, [r0]

    ldr r0, =0x7e001200
    ldr r1, =0x150f8
    str r1, [r0]

    /*DDR 初始化顺序 */
    //nop
    ldr r0, =0x7e001008
    ldr r1, =0xc0000
    str r1, [r0]
    //pre charge all
    ldr r0, =0x7e001008
    ldr r1, =0x0
    str r1, [r0]
    //auto refresh
    ldr r0, =0x7e001008
    ldr r1, =0x40000   //or 4?
    str r1, [r0]
    //auto refresh
    ldr r0, =0x7e001008
    ldr r1, =0x40000
    str r1, [r0]
    //mrs
    ldr r0, =0x7e001008
    ldr r1, =0xa0000
    str r1, [r0] 
    //mrs
    ldr r0, =0x7e001008
    ldr r1, =0x80032
    str r1, [r0]
    //使dram控制器进入准备状态
    ldr r0, =0x7e001004
    mov r1, #0x0
    str r1, [r0]
    //检查是否进入准备状态
check_ready:
    ldr r0, =0x7e001000
    ldr r1, [r0]
    mov r2, #0x3
    and r1, r1, r2
    cmp r1, #0x1
    bne check_ready 

    mov pc, lr