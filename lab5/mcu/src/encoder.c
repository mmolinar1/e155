/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/03/2025
file: main.c

*/

#include "encoder.h"
#include "main.h"

static volatile int32_t encoder_count = 0; // internal state

// Initialization function
void encoder_init(void) {

}

// Interrupt Handlers
void exit_a_handler(void) {
// Check that the button was what triggered our interrupt
    if (EXTI->PR1 & (1 << )){
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << );

        // Then toggle the LED
        togglePin(PIN_A);

    }
}

void exit_b_handler(void) {
// Check that the button was what triggered our interrupt
    if (EXTI->PR1 & (1 << )){
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << );

        // Then toggle the LED
        togglePin(PIN_B);

    }
}

// get and reset count functions
uint32_t encoder_get_count(void) { return encoder_count; }
void encoder_reset(void) { encoder_count = 0; }