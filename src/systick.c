
#include "sapi.h"
#include "main.h"

/*****************************************************************************
 * Private types/enumerations/variables
 ****************************************************************************/

#define TICKRATE_HZ (1000)	/* 1000 ticks per second */
#define DWT_CONTROL             (*((volatile uint32_t*)0xE0001000))
#define DWT_CYCCNT              (*((volatile uint32_t*)0xE0001004))
#define DWT_CYCCNTENA_BIT       (1UL<<0)

#define EnableCycleCounter()    DWT_CONTROL |= DWT_CYCCNTENA_BIT
#define GetCycleCounter()       DWT_CYCCNT
#define ResetCycleCounter()     DWT_CYCCNT = 0
#define DisableCycleCounter()   DWT_CONTROL &= ~DWT_CYCCNTENA_BIT

// Variable que se incrementa cada vez que se llama al handler de interrupcion
// del SYSTICK.
static volatile uint32_t s_ticks = 0;

static void Inicio (void);
//void SysTick_Handler (void);
static void Suma (void);
static void LlamandoAMalloc (void);
static void PrivilegiosSVC (void);
void SVC_Handler (void);
static void zeros();
static void mult();
static void mult16();
static void mult12();
static void filtroVentana();
static void pack32to16();
static void max();
static void invertir();
int main(void){
	Inicio();
	uint32_t aValue = 20,
				 otherValue = 30,
				 sumResult;
	volatile uint32_t x = __get_CONTROL();
	x |=1;
	__set_CONTROL(x);

	x =0xff;
	__get_CONTROL();

	x &=-1;
	__set_CONTROL(x);

	x =0xff;
	__get_CONTROL();

	//svc_call(0);

	sumResult = asm_sum(aValue, otherValue);
	//asm_svc();
	zeros();
    mult();
    mult16();
    mult12();
    pack32to16();
    filtroVentana();
    max();
    invertir();
	while (1)
	{
		__WFI();
	}

	atenderError();
}
static void zeros(){
	uint32_t array[8]={(uint32_t)-1,(uint32_t)-2,(uint32_t)-3,
			(uint32_t)-4,(uint32_t)-5,(uint32_t)-6,
			(uint32_t)-7,(uint32_t)-8};
	asm_zero(&array[0],8);
	c_zero(array,8);

}

static void mult(){
	uint32_t array_in[8]={0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08};
    uint32_t array_out[8]={0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08};
    c_productoEscalar32(&array_in[0],&array_out[0],8,2);
	asm_productoEscalar32(&array_in[0],&array_out[0],8,2);
}

static void mult16(){
	uint16_t array_in[8]={0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08};
    uint16_t array_out[8]={0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08};
    c_productoEscalar16(&array_in[0],&array_out[0],8,2);
	asm_productoEscalar16(&array_in[0],&array_out[0],8,2);
}

static void mult12(){
	uint16_t array_in[8]={0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08};
    uint16_t array_out[8]={0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08};
    c_productoEscalar12(&array_in[0],&array_out[0],8,0x08FF);
	asm_productoEscalar12(&array_in[0],&array_out[0],8,0x08FF);
}
static void filtroVentana(){
	uint16_t array_in[20]={0x01,0x02,0x03,0x02,0x03,0x02,0x03,0x02,0x03,0x02,0x03,0x02,0x03,0x02,0x03,0x02,0x03,0x02,0x03,0x02};
    uint16_t array_out[20]={0x00};
    //c_filtroVentana10(&array_in[0],&array_out[0],20);
    asm_filtroVentana10(&array_in[0],&array_out[0],20);
}
static void pack32to16(){
	uint32_t array_in[10]={0x02040201,0x03040302,0x09090809,0x09090902,0x08080803,0x06060602,0x04040403,0x07070702,0x05050503,0x04040402};
    uint16_t array_out[10]={0x00};

    asm_pack32to16(&array_in[0],&array_out[0],sizeof(array_in)/sizeof(array_in[0]));
    c_pack32to16(&array_in[0],&array_out[0],sizeof(array_in)/sizeof(array_in[0]));
}
static void max(){
	uint32_t pos = 0;
	uint32_t array_in[10]={0x01,0x02,0x06,0x02,0x03,0x09,0x03,0x02,0x03,0x02};
	c_max (&array_in[0], 10);
	pos = asm_max(&array_in[0], 10);
}
static void invertir(){
	uint32_t contador = 0;
	uint16_t array_in[10]={0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a};
	EnableCycleCounter();
	ResetCycleCounter();
	asm_invertir (&array_in[0], 10);
	contador = GetCycleCounter();
	ResetCycleCounter();
	c_invertir (&array_in[0], 10);
	contador = GetCycleCounter();
}
// Inicia soporte de la placa y periodo de la interrupcion del SYSTICK
// cada 1 milisegundo.
static void Inicio (void)
{
	SystemCoreClockUpdate();
	Board_Init();
	boardInit();
	/* Enable and setup SysTick Timer at a periodic rate */
	SysTick_Config(SystemCoreClock / TICKRATE_HZ);
}

// Segun la configuracion realizada en Inicio(), este handler de interrupcion
// se ejecutara cada 1 milisegundo.
//void SysTick_Handler (void)
//{
//    ++ s_ticks;
//}


static void Suma (void)
{
    const uint32_t A = 20;
    const uint32_t B = 30;

    const uint32_t SumResult_C = c_sum (A, B);
    const uint32_t SumResult_Asm = asm_sum (A, B);

    // Actividad de debug: SumResult_C y SumResult_Asm deberian contener el
    // mismo valor.
    __BKPT (0);

    (void) SumResult_C;
    (void) SumResult_Asm;
}


static void LlamandoAMalloc (void)
{
    // De donde saca memoria malloc?
    // (se vera en clase)
    void * ptr = malloc (2048);

    (void) ptr;
}


static void PrivilegiosSVC (void)
{
    // Obtiene valor del registro de 32 bits del procesador llamado "control".
    // El registro guarda los siguientes estados:
    // bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
    // bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
    // bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
    //        Recordar que este valor solo se usa en modo Thread. Las
    //        interrupciones siempre se ejecutan en modo Handler con total
    //        privilegio.
    uint32_t x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x |= 1;
    // bit 0 a modo No privilegiado.
    __set_CONTROL (x);

    // En este punto se estaria ejecutando en modo No privilegiado.
    // Lectura del registro "control" para confirmar.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x &= ~1u;
    // Se intenta volver a modo Privilegiado (bit 0, valor 0).
    __set_CONTROL (x);

    // Confirma que esta operacion es ignorada por estar ejecutandose en modo
    // Thread no privilegiado.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    // En este punto, ejecutando en modo Thread no privilegiado, la unica forma
    // de volver a modo privilegiado o de realizar cualquier cambio que requiera
    // modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
    // opertivo de tiempo real.
    // Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
    // utilizando la instruccion "svc".
    // No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
    // es necesario implementar una funcion en assembler. Ver el archivo suma.S.
    asm_svc ();

    // El sistema operativo (el handler de SVC) deberia haber devuelto el modo
    // de ejecucion de Thread a privilegiado (bit 0 en valor 0).
    x = __get_CONTROL ();

    // Fin del ejemplo de SVC
}


// Handler de la interrupcion "SVC" (Supervisor Call).
// Usado por el ejemplo "EjemploPrivilegiosSVC".
void SVC_Handler (void)
{
    // Se obtiene el valor del registro "control". El bit 0 indica el nivel
    // de privilegio en modo "Thread". Deberia ser 1: No privilegiado.
    uint32_t x = __get_CONTROL ();

    // Borra el bit 0. Nuevo valor 0: privilegiado.
    x &= ~1u;

    // Asigna el nuevo valor al registro "control". Esta operacion deberia
    // ejecutarse ya que todo manejador de interrupciones se ejecuta en modo
    // "Handler" con total privilegio.
    __set_CONTROL (x);
}

// No se implementa la atención del error, se deja colgado con el while(1)
void atenderError()
{
	while(1);
}





