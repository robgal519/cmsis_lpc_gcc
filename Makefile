
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
Drivers/PIN_LPC17xx.c \
Drivers/GPDMA_LPC17xx.c \
Middleware/FreeRTOS/Source/croutine.c \
Middleware/FreeRTOS/Source/event_groups.c \
Middleware/FreeRTOS/Source/list.c \
Middleware/FreeRTOS/Source/queue.c \
Middleware/FreeRTOS/Source/stream_buffer.c \
Middleware/FreeRTOS/Source/tasks.c \
Middleware/FreeRTOS/Source/timers.c \
Middleware/FreeRTOS/Source/CMSIS_RTOS_V2/cmsis_os2.c \
Middleware/FreeRTOS/Source/portable/GCC/ARM_CM3/port.c \
Middleware/FreeRTOS/Source/portable/MemMang/heap_4.c \

# C defines
C_DEFS =  \
-DRTE_DEVICE_FRAMEWORK_CLASSIC \
-DLPC175x_6x

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
