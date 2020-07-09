#include "lpc17xx.h"    
#include "system_LPC17xx.h"

#define LED4 (0)
/* start the main program */
void log_message(char *ch) {
  while (*ch)
    ITM_SendChar(*ch++);
}
int main() 
{
    SystemInit();   
    SystemCoreClockUpdate()  ; 
    log_message("app started");             
    LPC_GPIO0->FIODIR |=  1<<LED4;
    volatile int i = 0;
    volatile unsigned int k = (unsigned int)-1;
    log_message("while loop enter");
  while(1)
    {
       LPC_GPIO0->FIOCLR = 1<<LED4;  
       LPC_GPIO0->FIOSET = 1<<LED4;  
       LPC_GPIO0->FIOSET = 1<<LED4; 
       LPC_GPIO0->FIOSET = 1<<LED4; 
       i++;
    }
}