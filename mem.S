.text
.global mem_init
mem_init:
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








