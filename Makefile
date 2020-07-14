
######################################
# target
######################################
TARGET = test_www_in_rtos


######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -O0


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

PREFIX = arm-none-eabi-

CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size


HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m3


# float-abi
FLOAT-ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb  

######################################
# source
######################################
# C sources
C_SOURCES =  \
startup_LPC17xx.c \
system_LPC17xx.c \
main.c \
Drivers/UART_LPC17xx.c \
Drivers/I2C_LPC17xx.c \
Drivers/PIN_LPC17xx.c \
Drivers/GPDMA_LPC17xx.c \
Drivers/GPIO_LPC17xx.c \
Drivers/EMAC_LPC17xx.c \
Drivers/PHY_LAN8720.c \
Middleware/FreeRTOS/Source/croutine.c \
Middleware/FreeRTOS/Source/event_groups.c \
Middleware/FreeRTOS/Source/list.c \
Middleware/FreeRTOS/Source/queue.c \
Middleware/FreeRTOS/Source/stream_buffer.c \
Middleware/FreeRTOS/Source/tasks.c \
Middleware/FreeRTOS/Source/CMSIS_RTOS_V2/cmsis_os2.c \
Middleware/FreeRTOS/Source/portable/GCC/ARM_CM3/port.c \
Middleware/FreeRTOS/Source/portable/MemMang/heap_4.c \
Middleware/LwIP/src/netif/ppp/auth.c \
Middleware/LwIP/src/netif/ppp/ccp.c \
Middleware/LwIP/src/netif/ppp/chap_ms.c \
Middleware/LwIP/src/netif/ppp/chap-md5.c \
Middleware/LwIP/src/netif/ppp/chap-new.c \
Middleware/LwIP/src/netif/ppp/demand.c \
Middleware/LwIP/src/netif/ppp/eap.c \
Middleware/LwIP/src/netif/ppp/eui64.c \
Middleware/LwIP/src/netif/ppp/fsm.c \
Middleware/LwIP/src/netif/ppp/ipcp.c \
Middleware/LwIP/src/netif/ppp/ipv6cp.c \
Middleware/LwIP/src/netif/ppp/lcp.c \
Middleware/LwIP/src/netif/ppp/magic.c \
Middleware/LwIP/src/netif/ppp/mppe.c \
Middleware/LwIP/src/netif/ppp/multilink.c \
Middleware/LwIP/src/netif/ppp/ppp.c \
Middleware/LwIP/src/netif/ppp/pppapi.c \
Middleware/LwIP/src/netif/ppp/pppcrypt.c \
Middleware/LwIP/src/netif/ppp/pppoe.c \
Middleware/LwIP/src/netif/ppp/pppol2tp.c \
Middleware/LwIP/src/netif/ppp/pppos.c \
Middleware/LwIP/src/netif/ppp/upap.c \
Middleware/LwIP/src/netif/ppp/utils.c \
Middleware/LwIP/src/netif/ppp/vj.c \
Middleware/LwIP/src/netif/bridgeif.c \
Middleware/LwIP/src/netif/bridgeif_fdb.c \
Middleware/LwIP/src/netif/ethernet.c \
Middleware/LwIP/src/netif/lowpan6.c \
Middleware/LwIP/src/netif/lowpan6_ble.c \
Middleware/LwIP/src/netif/lowpan6_common.c \
Middleware/LwIP/src/netif/slipif.c \
Middleware/LwIP/src/netif/zepif.c \
Middleware/LwIP/src/netif/ppp/ecp.c \
Middleware/LwIP/src/api/api_lib.c \
Middleware/LwIP/src/api/api_msg.c \
Middleware/LwIP/src/api/err.c \
Middleware/LwIP/src/api/if_api.c \
Middleware/LwIP/src/api/netbuf.c \
Middleware/LwIP/src/api/netdb.c \
Middleware/LwIP/src/api/netifapi.c \
Middleware/LwIP/src/api/sockets.c \
Middleware/LwIP/src/api/tcpip.c \
Middleware/LwIP/src/core/altcp.c \
Middleware/LwIP/src/core/altcp_alloc.c \
Middleware/LwIP/src/core/altcp_tcp.c \
Middleware/LwIP/src/core/def.c \
Middleware/LwIP/src/core/dns.c \
Middleware/LwIP/src/core/inet_chksum.c \
Middleware/LwIP/src/core/init.c \
Middleware/LwIP/src/core/ip.c \
Middleware/LwIP/src/core/mem.c \
Middleware/LwIP/src/core/memp.c \
Middleware/LwIP/src/core/netif.c \
Middleware/LwIP/src/core/pbuf.c \
Middleware/LwIP/src/core/raw.c \
Middleware/LwIP/src/core/stats.c \
Middleware/LwIP/src/core/sys.c \
Middleware/LwIP/src/core/tcp.c \
Middleware/LwIP/src/core/tcp_in.c \
Middleware/LwIP/src/core/tcp_out.c \
Middleware/LwIP/src/core/timeouts.c \
Middleware/LwIP/src/core/udp.c \
Middleware/LwIP/src/core/ipv4/autoip.c \
Middleware/LwIP/src/core/ipv4/dhcp.c \
Middleware/LwIP/src/core/ipv4/etharp.c \
Middleware/LwIP/src/core/ipv4/icmp.c \
Middleware/LwIP/src/core/ipv4/igmp.c \
Middleware/LwIP/src/core/ipv4/ip4.c \
Middleware/LwIP/src/core/ipv4/ip4_addr.c \
Middleware/LwIP/src/core/ipv4/ip4_frag.c \
Middleware/LwIP/src/core/ipv6/dhcp6.c \
Middleware/LwIP/src/core/ipv6/ethip6.c \
Middleware/LwIP/src/core/ipv6/icmp6.c \
Middleware/LwIP/src/core/ipv6/inet6.c \
Middleware/LwIP/src/core/ipv6/ip6.c \
Middleware/LwIP/src/core/ipv6/ip6_addr.c \
Middleware/LwIP/src/core/ipv6/ip6_frag.c \
Middleware/LwIP/src/core/ipv6/mld6.c \
Middleware/LwIP/src/core/ipv6/nd6.c \
Middleware/LwIP/system/OS/sys_arch.c \
Middleware/LwIP/src/apps/mqtt/mqtt.c \
httpserver-netconn.c \
ethernetif.c \
lwip.c \
bosh_BME.c \
bosh_BME280/bme280.c \


# C defines
C_DEFS =  \
-DRTE_DEVICE_FRAMEWORK_CLASSIC \
-DLPC175x_6x \
-DRTE_CMSIS_RTOS2 \

# C includes
C_INCLUDES =  -I. \
-ICMSIS/Core/Include \
-ICMSIS/Driver/Include \
-ICMSIS/RTOS2/Include \
-ICMSIS/RTOS/Include \
-IDrivers/Config \
-IDrivers \
-IMiddleware/FreeRTOS/Source/include \
-IMiddleware/FreeRTOS/Source/CMSIS_RTOS_V2 \
-IMiddleware/FreeRTOS/Source/portable/GCC/ARM_CM3 \
-IMiddleware/LwIP/system \
-IMiddleware/LwIP/system/arch \
-IMiddleware/LwIP/src/include \
-IMiddleware/LwIP/src/include/lwip \
-IMiddleware/LwIP/src/include/lwip/apps \
-IMiddleware/LwIP/src/include/lwip/priv \
-IMiddleware/LwIP/src/include/lwip/prot \
-IMiddleware/LwIP/src/include/netif \
-IMiddleware/LwIP/src/include/compat/posix \
-IMiddleware/LwIP/src/include/compat/posix/arpa \
-IMiddleware/LwIP/src/include/compat/posix/net \
-IMiddleware/LwIP/src/include/compat/posix/sys \
-IMiddleware/LwIP/src/include/compat/stdc \



CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections 
ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif

#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = LPC17xx.ld

# libraries
LIBS = -lc -lm -lnosys -lrdimon 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))


$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@ 
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	

	
$(BUILD_DIR):
	mkdir $@
