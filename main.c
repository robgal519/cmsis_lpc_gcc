#include "Driver_USART.h"
#include "cmsis_os.h"
#include "cmsis_os2.h"
#include "lpc17xx.h"
#include "system_LPC17xx.h"
#include "httpserver-netconn.h"
#include "lwip.h"
#include "task.h"
#include "bosh_BME.h"
void BME_task();
static volatile application_state state;

#define SBIT_TIMER0  1
#define SBIT_MR0I    0
#define SBIT_MR0R    1
#define SBIT_CNTEN   0
#define PCLK_TIMER0  2
#define MiliToMicroSec(x)  (x*1000)  /* ms is multiplied by 1000 to get us*/
unsigned int getPrescalarForUs(uint8_t timerPclkBit)
{
    unsigned int pclk,prescalarForUs;
    pclk = (LPC_SC->PCLKSEL0 >> timerPclkBit) & 0x03;  /* get the pclk info for required timer */

    switch ( pclk )                                    /* Decode the bits to determine the pclk*/
    {
    case 0x00:
        pclk = SystemCoreClock/4;
        break;

    case 0x01:
        pclk = SystemCoreClock;
        break; 

    case 0x02:
        pclk = SystemCoreClock/2;
        break; 

    case 0x03:
        pclk = SystemCoreClock/8;
        break;

    default:
        pclk = SystemCoreClock/4;
        break;  
    }

    prescalarForUs =pclk/1000000 - 1;                    /* Prescalar for 1us (1000000Counts/sec) */

    return prescalarForUs;
}

void StartDefaultTask(void *argument);

#define HTTP_OK "HTTP/1.1 200 OK\n"
#define HTTP_NOT_FOUND "HTTP/1.1 404 Not Found\n"

#define CONTENT_TYPE_JSON "Content-Type: application/json; charset=utf-8\n"
#define CONTENT_TYPE_TEXT "Content-Type: text/html; charset=utf-8\n"
#define END_OF_HEADER "\r\n"

#include "../webpages/index.h"
#include <string.h>
err_t index_html_handler(struct netconn *connection_context) {
  err_t ret = netconn_write(
      connection_context, HTTP_OK CONTENT_TYPE_TEXT "\r\n",
      strlen(HTTP_OK) + strlen(CONTENT_TYPE_TEXT) + 2, NETCONN_NOCOPY);

  ret = netconn_write(connection_context, (const unsigned char *)index_html,
                      index_html_len, NETCONN_NOCOPY);
  return ret;
}



static void i2C_event(uint32_t event) {
BME_i2c_event_register(event); 
}
void BME_task(){
   extern ARM_DRIVER_I2C Driver_I2C0;

  Driver_I2C0.Initialize(i2C_event);
  Driver_I2C0.PowerControl(ARM_POWER_FULL);
  Driver_I2C0.Control(ARM_I2C_BUS_SPEED, ARM_I2C_BUS_SPEED_FAST);
  Driver_I2C0.Control(ARM_I2C_BUS_CLEAR, 0);
  init_BME(&Driver_I2C0);
  const TickType_t xDelay = 500;
  while(true){
    BME_set_enable();
    run_BME(&state);
    osDelay(xDelay);
  }
}

err_t check_memeory(struct netconn *connection_context){
  netconn_write(connection_context, HTTP_OK CONTENT_TYPE_JSON END_OF_HEADER,
                strlen(HTTP_OK) + strlen(CONTENT_TYPE_JSON) +
                    strlen(END_OF_HEADER),
                NETCONN_NOCOPY);
  static char value[255];
  uint32_t size_of_val = snprintf(value,255,
  "{\n"\
  "\"total_mem\":%d\n"\
  "\"free_mem\":%d\n"\
"\"historic_min_free\":%d\n"\
"\"used_mem\":%d\n"\
  "}"
  ,configTOTAL_HEAP_SIZE,xPortGetFreeHeapSize(),xPortGetMinimumEverFreeHeapSize(),configTOTAL_HEAP_SIZE-xPortGetFreeHeapSize());
  netconn_write(connection_context, value, size_of_val, NETCONN_NOCOPY);
  return ERR_OK;
}

err_t get_BME_temperature(struct netconn *connection_context) {
  netconn_write(connection_context, HTTP_OK CONTENT_TYPE_JSON END_OF_HEADER,
                strlen(HTTP_OK) + strlen(CONTENT_TYPE_JSON) +
                    strlen(END_OF_HEADER),
                NETCONN_NOCOPY);
  static char value[255];
  uint32_t size_of_val = snprintf(value,255,
  "{"\
  "\"temperature\":%d.%02d,"\
  "\"unit\":\"°C\""\
  "}"
  ,(uint32_t)state.temp, ((uint32_t)(state.temp*100))%100);
  netconn_write(connection_context, value, size_of_val, NETCONN_NOCOPY);
  return ERR_OK;
}
err_t get_BME_pressure(struct netconn *connection_context) {
  netconn_write(connection_context, HTTP_OK CONTENT_TYPE_JSON END_OF_HEADER,
                strlen(HTTP_OK) + strlen(CONTENT_TYPE_JSON) +
                    strlen(END_OF_HEADER),
                NETCONN_NOCOPY);
  static char value[255];
  uint32_t size_of_val = snprintf(value,255,
  "{"\
  "\"pressure\":%d.%04d,"\
  "\"unit\":\"hPa\""\
  "}"
  ,(uint32_t)state.pressure/100, ((uint32_t)(state.pressure*100))%10000);
  netconn_write(connection_context, value, size_of_val, NETCONN_NOCOPY);
  return ERR_OK;
}
err_t get_BME_humidity(struct netconn *connection_context) {
  netconn_write(connection_context, HTTP_OK CONTENT_TYPE_JSON END_OF_HEADER,
                strlen(HTTP_OK) + strlen(CONTENT_TYPE_JSON) +
                    strlen(END_OF_HEADER),
                NETCONN_NOCOPY);
  static char value[255];
  uint32_t size_of_val = snprintf(value,255,
  "{"\
  "\"humidity\":%d.%02d,"\
  "\"unit\":\"%%\""\
  "}"
  ,(uint32_t)state.humidity, ((uint32_t)(state.humidity*100))%100);
  netconn_write(connection_context, value, size_of_val, NETCONN_NOCOPY);
  return ERR_OK;
}


int main() {
  SystemInit();
  SystemCoreClockUpdate();

   LPC_SC->PCONP |= (1<<SBIT_TIMER0); /* Power ON Timer0,1 */

    LPC_TIM0->MCR  = (1<<SBIT_MR0I) | (1<<SBIT_MR0R);     /* Clear TC on MR0 match and Generate Interrupt*/
    LPC_TIM0->PR   = getPrescalarForUs(PCLK_TIMER0);      /* Prescalar for 1us */
    LPC_TIM0->MR0  = MiliToMicroSec(1);                 /* Load timer value to generate 100ms delay*/
    LPC_TIM0->TCR  = (1 <<SBIT_CNTEN);                    /* Start timer by setting the Counter Enable*/
    NVIC_EnableIRQ(TIMER0_IRQn);                          /* Enable Timer0 Interrupt */

  osKernelInitialize();
  const osThreadAttr_t defaultTask_attributes = {
      .name = "defaultTask",
      .priority = (osPriority_t)osPriorityIdle,
      .stack_size = 512 };
  osThreadNew(StartDefaultTask, NULL, &defaultTask_attributes);
    const osThreadAttr_t bme_thread_attributes = {
  .name = "bme_thread",
  .priority = (osPriority_t) osPriorityNormal,
  .stack_size = 512
  };
  osThreadNew(BME_task, NULL, &bme_thread_attributes);
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
  register_endpoint(GET, "/memory", check_memeory);
  register_endpoint(GET, "/index.html", index_html_handler);
  register_endpoint(GET, "/", index_html_handler);
  register_endpoint(GET, "/temperature", get_BME_temperature);
  register_endpoint(GET, "/pressure", get_BME_pressure);
  register_endpoint(GET, "/humidity", get_BME_humidity);
  http_server_netconn_init();
  //


  /* Infinite loop */
  for (;;) {
    poll();
  }
}

static uint32_t ms_counter = 0;

void TIMER0_IRQHandler(void)
{
    unsigned int isrMask;

    isrMask = LPC_TIM0->IR; 
    LPC_TIM0->IR = isrMask;         /* Clear the Interrupt Bit */
    ms_counter++;
}

uint32_t HAL_GetTick(){
  return ms_counter;
}
