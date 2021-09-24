.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global asm_zero
.global asm_productoEscalar32
.global asm_productoEscalar16
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
    	@push {lr}
		@mov r0,r1, LSL #1
		@movs r0,r1, LSL #1
		@sub r0,r0,r1, LSL #1
		@pop {pc}
        svc 0
        bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	Funcion que inicialice un vector con ceros.
@   void asm_zero(uint32_t *vectorIn,uint32_t longitud);
@
@ Parametros recibidos:
@   r0: vector
@   r1: longitud
@
.thumb_func
	asm_zero:
		@registros usados
		mov r2,0
	.loop:
		@error str r2,[r0,4]!
		str r2,[r0],4 @sizeof(u32) == 4 , *vector++ = r2 ,book 4.5
		subs r1,1 @--longitud
		bne .loop
		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	Realice el producto de un vector y un escalar
@   void asm_productoEscalar(uint32_t *vectorIn,uint32_t *vectorOut,
@							uint32_t longitud, uint32_t escalar);
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@
.thumb_func
	asm_productoEscalar32:
		@registros usados r4: almaceno el valor de r0 / r5: el valor de multiplicacion
		push {r4-r5}
	.loop_pro:
		ldr r4,[r0],#4 @ r4 = mem32[r0] ; r0 +=4
		mul r5,r4,r3 @r5 = r4*r3
		str r5,[r1],#4 @ mem32[r1] = r5 ; r1 +=4
		subs r2,#1 @ --longitud
		bne .loop_pro
		pop {r4-r5}
		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	Realice el producto de un vector y un escalar
@   void asm_productoEscalar16(uint16_t *vectorIn,uint16_t *vectorOut,
@							uint32_t longitud, uint16_t escalar);
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
.thumb_func
	asm_productoEscalar16:
		@registros usados r4: almaceno el valor de r0 / r5: el valor de multiplicacion
		push {r4-r5}
	.loop_pro16:
		ldrh r4,[r0],#2 @ r4 = mem16[r0] ; r0 +=2
		mul r5,r4,r3 @r5 = r4*r3
		strh r5,[r1],#2 @ mem16[r1] = r5 ; r1 +=2
		subs r2,#1 @ --longitud
		bne .loop_pro16
		pop {r4-r5}
		bx lr
