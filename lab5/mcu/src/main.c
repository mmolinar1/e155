/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/03/2025
file: main.c

*/

#include "main.h"

int main(void) {
    
    // initialize
    encoder_init();

    // Enable interrupts globally
    __enable_irq();

    // PIN_A
    // 1. Configure mask bit
    EXTI->IMR1 |= (1 << gpioPinOffset(PIN_A)); // Configure the mask bit
    // 2. Enable rising edge trigger
    EXTI->RTSR1 |= (1 << gpioPinOffset(PIN_A));// Enable rising edge trigger
    // 3. Enable falling edge trigger
    EXTI->FTSR1 |= (1 << gpioPinOffset(PIN_A));// Enable falling edge trigger
    // 4. Turn on EXTI interrupt in NVIC_ISER
    NVIC->ISER[0] |= (1 << EXTI2_IRQn);

    // PIN_B
    // 1. Configure mask bit
    EXTI->IMR1 |= (1 << gpioPinOffset(PIN_B)); // Configure the mask bit
    // 2. Enable rising edge trigger
    EXTI->RTSR1 |= (1 << gpioPinOffset(PIN_B));// Enable rising edge trigger
    // 3. Enable falling edge trigger
    EXTI->FTSR1 |= (1 << gpioPinOffset(PIN_B));// Enable falling edge trigger
    // 4. Turn on EXTI interrupt in NVIC_ISER
    NVIC->ISER[0] |= (1 << EXTI1_IRQn);

    while(1){   
        delay_millis(TIM2, 1000);    // check every second (1 Hz)

        // Get current encoder count
        int32_t curr_count = encoder_get_count();
        int32_t pulse_diff = curr_count - prev_count;
        prev_count = curr_count;
        
        // Get direction
        int32_t dir = encoder_get_direction();

        // Calculate rotations per second
        // For a quadrature encoder with 408 PPR, we get 4x counts per revolution
        rps = (float)pulse_diff / (4 * 408);

        // velocity - speed and direction
        velocity = rps * dir;     
        
        // Display results
        printf("Rev/s: %.2f", velocity);
    }

}