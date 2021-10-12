.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global asm_zero
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_filtroVentana10
.global asm_pack32to16
.global asm_max
.global asm_invertir
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
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	Realice el producto de un vector, un escalar y saturar a los 12 bits 
@   void asm_productoEscalar12(uint16_t *vectorIn,uint16_t *vectorOut,
@							uint32_t longitud, uint16_t escalar);
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
.thumb_func
	asm_productoEscalar12:
		@registros usados r4: almaceno el valor de r0 / r5: el valor de saturacion
		push {r4-r5}
		ldr r5,=#0x00000fff
	.loop_pro12:
		ldrh r4,[r0],#2 @ r4 = mem16[r0] ; r0 +=2
		mul  r4,r3 @r4 = r4*r3
	.BEGINIF:
		cmp r4, r5
		ble .ENDIF
		mov r4,r5
	.ENDIF:
		strh r4,[r1],#2 @ mem16[r1] = r5 ; r1 +=2
		subs r2,#1 @ --longitud
		bne .loop_pro12
		pop {r4-r5}
		bx lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   extern void asm_filtroVentana10(uint16_t * vectorIn, uint16_t *vectorOut,
@												uint32_t longitudVectorIn);
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitudVectorIn

@ r7 j
@ r6 i
@ r8 es i+10
@ r9 pos
.EQU ventana, 10
.thumb_func
	asm_filtroVentana10:
		push {r4-r10}
		mov r6,#0
		mov r5,#0
	.loop1: @for (int i = 0; i < longitudVectorIn; i++) r6 es i
		mov r7,r6
		add r8,r6,#10
		.loop2: @for (int j = i; j < i + 10; j++) { @ j = r7 y r8=i+10
			cmp r7,r2 @if(j>longitudVectorIn){ 
			blt .ifuno
			mov r9,r7 @pos = j;@aqui va el else
			b .endifuno
		.ifuno:
			sub r9,r7,r2 @pos = j - longitudVectorIn;
		.endifuno:
			@sumatoria += vectorIn[pos]-------- desplazamienot de 2 xq uint16
			add r5, r0, r9 ,LSL #1
			ldrh r4, [r5] 
			add r3,r4
			@-------------------------------------------------
			add r7,r7,#1 @j++
			cmp r7,r8 @j < i + 10
			blt .loop2 @-----end for 2

			@div r5, r5, #10   @sumatoria/10;
			ldrh r4,[r0],#2 @ r4 = mem16[r0] ; r0 +=2 @vectorOut[i] = sumatoria/10;

		add  r6, r6, #1 @i++
		cmp  r6, ventana @compara si es igual a 10 ----- end for 1
        blt  .loop1 @loop del for 1
		pop {r4-r10}
		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	Realizar una función que reciba un vector de números signados de 32 bits y 
@	los “empaquete” en otro vector de 16 bits. La función deberá adecuar los 
@	valores de entrada a la nueva precisión.
@   vvoid pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
.thumb_func
	asm_pack32to16:
		push {r3,r4}
		mov r4,#0
		.loop_pack_1:
		ldr r3,[r0],#4 @ r3 = mem32[r0] ; r0 +=4
		lsr r3, #16 
		strh r3,[r1],#2 @ mem16[r1] = r3 ; r1 +=2
		add  r4, r4, #1 @i++
		cmp  r4, r2 
        blt  .loop_pack_1 
		pop {r3,r4}
		bx lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	Realizar una función que reciba un vector de números signados de 32 bits y 
@ 	devuelva la posición del máximo del vector.
@   int32_t max (int32_t * vectorIn, uint32_t longitud);
@ Parametros recibidos:
@   r0: *vectorIn
@	r1: longitud
.thumb_func
	asm_max:
	push {r2-r5}
	mov r2,#0 @r2 es pos
	mov r3,#0 @r3 es i
	mov r4, #0 @r4 es max
	.loop_max:
		ldr r5,[r0],#4 @ r3 = mem32[r0] ; r0 +=4
		.beginifmax:
		cmp r5, r4
		ble .endifmax
		mov r2,r3	@guardo posicion
		mov r4,r5 @guardo el mayor
		.endifmax:
	add r3, 1 
	cmp  r3, r1 
	blt  .loop_max 
	mov r0, r2
	pop {r2-r5}
	bx lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	Realizar una función que reciba un vector de muestras no signadas de 16 bits 
@	e invierta su orden.
@   void invertir (uint16_t * vector, uint32_t longitud);
@ Parametros recibidos:
@   r0: *vectorIn
@	r1: longitud
.thumb_func
	asm_invertir:
	push {r2-r8}
	mov r3,r1, ASR #1 @uint32_t centro = longitud >> 2;
	mov r5,#0 @ r5 es i del for

	mov r6,r0 @copio el puntero de posicion inicial
	sub r7,r1,#1 @ en las 2 copio longitud -1 
	add r6,r6,r7, LSL #1	@se asigna a r6 la ultima posicion
	@r7 lo puedes usar.
	.loop_inv:
	ldrh r7, [r0]     
    ldrh r8, [r6]

    strh r8, [r0],#2    @ mem16[r0] = r6 ; copio la ultima en la primera
	strh r7, [r6],#-2	@copio en la ultims pos y le resto 2
	add r5, 1 
	cmp  r5, r3 @solo hago la mitad del arreglo 
	blt  .loop_inv 
	pop {r2-r8}
	bx lr
