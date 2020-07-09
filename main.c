#include "lpc17xx.h"    
#include "system_LPC17xx.h"
#include "Driver_USART.h"

extern ARM_DRIVER_USART Driver_USART0;
#define LED4 (0)
/* start the main program */
void log_message(char *ch) {
  while (*ch)
    ITM_SendChar(*ch++);
}

void myUSART_callback(uint32_t event)
{

}
 

int main() 
{
    SystemInit();   
    SystemCoreClockUpdate(); 
    ARM_DRIVER_USART * USARTdrv = &Driver_USART0;
    USARTdrv->Initialize(myUSART_callback);
    /*Power up the USART peripheral */
    USARTdrv->PowerControl(ARM_POWER_FULL);
    /*Configure the USART to 4800 Bits/sec */
    USARTdrv->Control(ARM_USART_MODE_ASYNCHRONOUS |
                      ARM_USART_DATA_BITS_8 |
                      ARM_USART_PARITY_NONE |
                      ARM_USART_STOP_BITS_1 |
                      ARM_USART_FLOW_CONTROL_NONE, 115200);
     
    /* Enable Receiver and Transmitter lines */
    USARTdrv->Control (ARM_USART_CONTROL_TX, 1);
    USARTdrv->Control (ARM_USART_CONTROL_RX, 1);
    const char message[] = "Press Enter to receive a message";
    USARTdrv->Send(message, sizeof(message));

    log_message("app started");             
    LPC_GPIO0->FIODIR |=  1<<LED4;
    log_message("while loop enter");
  while(1)
    {
       LPC_GPIO0->FIOCLR = 1<<LED4;  
       LPC_GPIO0->FIOSET = 1<<LED4;  
       LPC_GPIO0->FIOSET = 1<<LED4; 
       LPC_GPIO0->FIOSET = 1<<LED4; 
    }
}