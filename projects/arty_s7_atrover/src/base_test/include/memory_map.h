// ----------------------------------------------------------------------
// --- __MEMORY_MAP__ ---
#ifndef __MEMORY_MAP__
#define __MEMORY_MAP__

#include<cstdint>

// ----------------------------------------------------------------------
uint32_t constexpr GPIO_BASE_ADDR = 0x80000000u;

#define SET_IO_REG(REG_INX, REG_NAME) volatile uint32_t* const REG_NAME = (uint32_t*)(REG_INX * 0x04 + GPIO_BASE_ADDR)
#define READ_IO(REG_ID) (*REG_ID)
#define WRITE_IO(REG_ID, VL) (*REG_ID) = VL

// Registers
SET_IO_REG( 0, DEBUG_REG      );
SET_IO_REG( 1, UART0_TX_REG   );
SET_IO_REG( 2, UART0_RX_REG   );
SET_IO_REG( 3, LEDS_REG       );
SET_IO_REG( 4, RGB0_REG       );
SET_IO_REG( 5, RGB0_DCYCLE_REG);
SET_IO_REG( 6, RGB1_REG       );
SET_IO_REG( 7, RGB1_DCYCLE_REG);
SET_IO_REG( 8, BUTTONS_REG    );
SET_IO_REG( 9, SWITCHES_REG   );
SET_IO_REG(10, M0_BWD_PWM_REG );
SET_IO_REG(11, M0_FWD_PWM_REG );
SET_IO_REG(12, M1_BWD_PWM_REG );
SET_IO_REG(13, M1_FWD_PWM_REG );
SET_IO_REG(14, DISTANCE_REG );

// ----------------------------------------------------------------------
// --- __MEMORY_MAP__ ---
#endif
// ----------------------------------------------------------------------
