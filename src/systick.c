
#include "sapi.h"
#include "main.h"

/*****************************************************************************
 * Private types/enumerations/variables
 ****************************************************************************/

#define TICKRATE_HZ (1000)	/* 1000 ticks per second */

/*****************************************************************************
 * Public types/enumerations/variables
 ****************************************************************************/

/*****************************************************************************
 * Private functions
 ****************************************************************************/

/*****************************************************************************
 * Public functions
 ****************************************************************************/


int main(void){
	SystemCoreClockUpdate();
	Board_Init();
	boardInit();
	/* Enable and setup SysTick Timer at a periodic rate */
	SysTick_Config(SystemCoreClock / TICKRATE_HZ);

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
	asm_svc();

	while (1)
	{
		__WFI();
	}

	atenderError();
}

// No se implementa la atención del error, se deja colgado con el while(1)
void atenderError()
{
	while(1);
}





