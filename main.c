#include "Driver_USART.h"
#include "cmsis_os.h"
#include "lpc17xx.h"
#include "system_LPC17xx.h"
#include "httpserver-netconn.h"
#include "lwip.h"
#include "task.h"

void StartDefaultTask(void *argument);

int main() {
  SystemInit();
  SystemCoreClockUpdate();
  osKernelInitialize();
  const osThreadAttr_t defaultTask_attributes = {
      .name = "defaultTask",
      .priority = (osPriority_t)osPriorityIdle,
      .stack_size = 128 };
  osThreadNew(StartDefaultTask, NULL, &defaultTask_attributes);
  osKernelStart();
  while (1)
    ;
}

void StartDefaultTask(void *argument) {

  // sys_thread_new("BME280", BME_task, NULL,
  //                DEFAULT_THREAD_STACKSIZE, osPriorityNormal);
  // /* init code for LWIP */
  MX_LWIP_Init();
  /* USER CODE BEGIN StartDefaultTask */
  register_endpoint(GET, "/alive", alive_handler);
  http_server_netconn_init();
  //


  /* Infinite loop */
  for (;;) {

    poll();
  }
}

uint32_t HAL_GetTick(){
  return xTaskGetTickCount();
}
