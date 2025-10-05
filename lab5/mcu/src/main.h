/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/03/2025
file: main.h

main header filer with custom defines
*/

#ifndef MAIN_H
#define MAIN_H

#include "STM32L432KC.h"
#include <stm32l432xx.h>
#include "stm32l4xx.h"
#include "encoder.h"

///////////////////////////////////////////////////////////////////////////////
// Custom defines
///////////////////////////////////////////////////////////////////////////////

#define PIN_A PA1    // 5 V tolerant pins
#define PIN_B PA2    // 5 V tolerant pins
#define DELAY_TIM TIM2

#endif