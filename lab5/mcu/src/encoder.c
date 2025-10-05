/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/03/2025
file: main.c

*/

#include "encoder.h"
#include "stm32l4xx.h"   // MCU-specific header

static volatile int32_t encoder_count = 0; // internal state

// Initialization function
void encoder_init(void) {

}

// Interrupt Handlers
void exit_a_handler(void) {

}

void exit_b_handler(void) {

}

uint32_t encoder_get_count(void) { return encoder_count; }
void encoder_reset(void) { encoder_count = 0; }
