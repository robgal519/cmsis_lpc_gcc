#include "Driver_USART.h"
#include "cmsis_os.h"
#include "lpc17xx.h"
#include "system_LPC17xx.h"

void StartDefaultTask(void *argument);

int main() {
  SystemInit();
  SystemCoreClockUpdate();
  osKernelInitialize();
  const osThreadAttr_t defaultTask_attributes = {
      .name = "defaultTask",
      .priority = (osPriority_t)osPriorityIdle,
      .stack_size = 1024 * 4};
  osThreadNew(StartDefaultTask, NULL, &defaultTask_attributes);
  osKernelStart();
  while (1)
    ;
}

void StartDefaultTask(void *argument) {
  int i = 0;
  while (1) {
    i++;
  }
  /* USER CODE END StartDefaultTask */
}