#include "c_func.h"


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand)
{
    return (firstOperand + secondOperand);
}
void c_zero(uint32_t *vector,uint32_t longitud)
{
	for(uint32_t i =0 ; i< longitud ; i++)
		vector[i] = 0;
}

void c_productoEscalar32(uint32_t *vectorIn,uint32_t *vectorOut, uint32_t longitud, uint32_t escalar)
{
	for(uint32_t i =0 ; i< longitud ; i++)
		vectorIn[i]=vectorOut[i]*escalar;
}
void c_productoEscalar16(uint16_t *vectorIn,uint16_t *vectorOut, uint16_t longitud, uint16_t escalar)
{
	for(uint32_t i =0 ; i< longitud ; i++)
			vectorIn[i]=vectorOut[i]*escalar;
}
void c_productoEscalar12(uint16_t *vectorIn,uint16_t *vectorOut, uint16_t longitud, uint16_t escalar)
{
	for(uint32_t i =0 ; i< longitud ; i++){
			vectorIn[i]=vectorOut[i]*escalar;
			if(vectorIn[i]>4095){
				vectorIn[i]=4095;
			}
	}
}

void c_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn)
{
    uint32_t sumatoria = 0;
    uint32_t pos = 0;

    for (int i = 0; i < longitudVectorIn; i++) {
        for (int j = i; j < i + 10; j++) {
            if(j>longitudVectorIn){
            	pos = j - longitudVectorIn;
            }
            else{
            	pos = j;
            }
            sumatoria += vectorIn[pos];
        }
        vectorOut[i] = sumatoria/10;
        sumatoria = 0;
    }
}

void c_pack32to16 (int32_t *vectorIn, int16_t *vectorOut, uint32_t longitud){
    for(int i=0;i<longitud;i++)
        vectorOut[i] = (uint16_t)(vectorIn[i]>>16);
}

int32_t c_max (int32_t *vectorIn, uint32_t longitud){
    int32_t max;
    int32_t pos = 0;
    max = 0;
    for(int i = 0; i<longitud;i++){
        if(vectorIn[i]>max){
            pos = i;
        }
    }
    return(pos);
}

void c_downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N){

}