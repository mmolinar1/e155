/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 09/25/2025
file: STM32L432KC_TIM.h

Header for tim15 and tim16 functions
*/

#ifndef STM32L4_TIM_H
#define STM32L4_TIM_H

#include <stdint.h>

///////////////////////////////////////////////////////////////////////////////
// Definitions
///////////////////////////////////////////////////////////////////////////////

// Base addresses
#define TIM15_BASE (0x40014000UL) // base address of TIM15
#define TIM16_BASE (0x40014400UL) // base address of TIM16

/**
  * @brief TIM15 and TIM16 timers
  */

  typedef struct
{
  volatile uint32_t CR1;          /*!< TIM15 control register 1,                                Address offset: 0x00 */
  volatile uint32_t CR2;          /*!< TIM15 control register 2,                                Address offset: 0x04 */
  volatile uint32_t SMCR;         /*!< TIM15 slave mode control register,                       Address offset: 0x08 */
  volatile uint32_t DIER;         /*!< TIM15 DMA/interrupt enable register,                     Address offset: 0x0C */
  volatile uint32_t SR;           /*!< TIM15 status register,                                   Address offset: 0x10 */
  volatile uint32_t EGR;          /*!< TIM15 event generation register,                         Address offset: 0x14 */
  volatile uint32_t CCMR1_OUT;    /*!< TIM15 capture/compare mode register 1,                   Address offset: 0x18 */
  volatile uint32_t CCMR1_IN;     /*!< Reserved,                                                Address offset: 0x1C */
  volatile uint32_t CCER;         /*!< TM15 capture/compare enable register,                    Address offset: 0x20 */
  volatile uint32_t CNT;          /*!< TIM15 counter,                                           Address offset: 0x24 */
  volatile uint32_t PSC;          /*!< TIM15 prescaler,                                         Address offset: 0x28 */
  volatile uint32_t ARR;          /*!< TIM15 auto-reload register,                              Address offset: 0x2C */
  volatile uint32_t RCR;          /*!< TIM15 repetition counter register,                       Address offset: 0x30 */
  volatile uint32_t CCR1;         /*!< TIM15 capture/compare register 1,                        Address offset: 0x34 */
  volatile uint32_t CCR2;         /*!< TIM15 capture/compare register 2,                        Address offset: 0x38 */
  uint32_t      RESERVED1;        /*!< Reserved,                                                Address offset: 0x3C */
  uint32_t      RESERVED2;        /*!< Reserved,                                                Address offset: 0x40 */
  volatile uint32_t BDTR;         /*!< TIM15 break and dead-time register,                      Address offset: 0x44 */
  volatile uint32_t DCR;          /*!< TIM15 DMA control register,                              Address offset: 0x48 */
  volatile uint32_t DMAR;         /*!< TIM15 DMA address for full transfer,                     Address offset: 0x4C */
  volatile uint32_t OR1;          /*!< TIM15 option register 1,                                 Address offset: 0x50 */
  uint32_t      RESERVED3;        /*!< Reserved,                                                Address offset: 0x54 */
  uint32_t      RESERVED4;        /*!< Reserved,                                                Address offset: 0x58 */
  uint32_t      RESERVED5;        /*!< Reserved,                                                Address offset: 0x5C */
  volatile uint32_t OR2;          /*!< TIM15 option register 2,                                 Address offset: 0x60 */

} TIM15_TypeDef;

typedef struct
{
  volatile uint32_t CR1;          /*!< TIM16 control register 1,                                Address offset: 0x00 */
  volatile uint32_t CR2;          /*!< TIM16 control register 2,                                Address offset: 0x04 */
  uint32_t      RESERVED0;         /*!< Reserved,                                               Address offset: 0x08 */
  volatile uint32_t DIER;         /*!< TIM16 DMA/interrupt enable register,                     Address offset: 0x0C */
  volatile uint32_t SR;           /*!< TIM16 status register,                                   Address offset: 0x10 */
  volatile uint32_t EGR;          /*!< TIM16 event generation register,                         Address offset: 0x14 */
  volatile uint32_t CCMR1;        /*!< TIM16 capture/compare mode register 1,                   Address offset: 0x18 */
  uint32_t      RESERVED1;        /*!< Reserved,                                                Address offset: 0x1C */
  volatile uint32_t CCER;         /*!< TIM16 capture/compare enable register,                    Address offset: 0x20 */
  volatile uint32_t CNT;          /*!< TIM16 counter,                                           Address offset: 0x24 */
  volatile uint32_t PSC;          /*!< TIM16 prescaler,                                         Address offset: 0x28 */
  volatile uint32_t ARR;          /*!< TIM16 auto-reload register,                              Address offset: 0x2C */
  volatile uint32_t RCR;          /*!< TIM16 repetition counter register,                       Address offset: 0x30 */
  volatile uint32_t CCR1;         /*!< TIM16 capture/compare register 1,                        Address offset: 0x34 */
  uint32_t      RESERVED2;        /*!< Reserved,                                                Address offset: 0x38 */
  uint32_t      RESERVED3;        /*!< Reserved,                                                Address offset: 0x3C */
  uint32_t      RESERVED4;        /*!< Reserved,                                                Address offset: 0x40 */
  volatile uint32_t BDTR;         /*!< TIM16 break and dead-time register,                      Address offset: 0x44 */
  volatile uint32_t DCR;          /*!< TIM16 DMA control register,                              Address offset: 0x48 */
  volatile uint32_t DMAR;         /*!< TIM16 DMA address for full transfer,                     Address offset: 0x4C */
  volatile uint32_t OR1;          /*!< TIM16 option register 1,                                 Address offset: 0x50 */
  uint32_t      RESERVED5;        /*!< Reserved,                                                Address offset: 0x54 */
  uint32_t      RESERVED6;        /*!< Reserved,                                                Address offset: 0x58 */
  uint32_t      RESERVED7;        /*!< Reserved,                                                Address offset: 0x5C */
  volatile uint32_t OR2;          /*!< TIM16 option register 2,                                 Address offset: 0x60 */

} TIM16_TypeDef;

#define TIM15 ((TIM15_TypeDef *) TIM15_BASE)
#define TIM16 ((TIM16_TypeDef *) TIM16_BASE)

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void TIM15_init(uint32_t prescaler);       // init function for prescaler
void TIM15_set_frequency(uint32_t hz);     // TIM15 will be used to set frequency
void TIM16_set_duration(uint32_t dur_ms);  // TIM16 will be used to set duration
void TIM16_init(uint32_t prescaler);       // init function for prescaler

#endif