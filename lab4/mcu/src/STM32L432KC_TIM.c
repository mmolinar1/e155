/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 09/25/2025
file: STM32L432KC_TIM.c

Source code for TIM15 and TIM16 functions
*/

#include <stdint.h>
#include "STM32L432KC_TIM.h"

#define PLL_CLOCK 80000000UL  // PLL clk at 80 MHz

// psc 5
// psc 700

/* Made these function based on PWM mode (see reference manual) */

static uint32_t tim15_prescaler = 5;
// Function to initialize the TIM15 prescaler once
void TIM15_init(uint32_t prescaler) {
    tim15_prescaler = prescaler;
    
    // Configure TIM15 for PWM
    TIM15->PSC = tim15_prescaler;
    
    // Configure channel for PWM mode
    TIM15->CCMR1_OUT &= ~(7 << 4);     // Clear OC1M bits
    TIM15->CCMR1_OUT |= (6 << 4);      // OC1M = 110 for PWM mode 1
    
    // Configure output polarity and enable output
    TIM15->CCER &= ~(1 << 1);      // CC1P = 0 active high polarity
    TIM15->CCER |= 1;              // CC1E = 1 enable output
    
    TIM15->BDTR |= (1 << 15);

    // Enable counter
    TIM15->CR1 |= 1;               // CEN = 1 enable counter
}

// TIM15 will be used to set frequency using PWM mode
void TIM15_set_frequency(uint32_t hz) {
    // Stop the timer temporarily
    TIM15->CR1 &= ~1;
    
    // Calculate period based on the fixed prescaler
    uint32_t period = PLL_CLOCK / ((tim15_prescaler + 1) * hz);
    
    // Set the auto-reload value and compare value for 50% duty cycle
    TIM15->ARR = period - 1;
    TIM15->CCR1 = period / 2;  // 50% duty cycle
    
    // Generate update event
    TIM15->EGR |= 1;
    
    // Restart the timer
    TIM15->CR1 |= 1;
}

/* Made these functions based on upcounting mode (see reference manual) */

static uint32_t tim16_prescaler = 700;

// Initialize TIM16
void TIM16_init(uint32_t prescaler) {
    TIM16->PSC = tim16_prescaler;
    TIM16->CR1 |= 1; //enable counter CEN bit
    TIM16->CR1 |= (1 << 7); //set ARPE bit
}

// TIM16 will be used to set duration (with fixed prescaler)
void TIM16_set_duration(uint32_t dur_ms) {
    // Calculate only the period (ARR) since prescaler is fixed
    uint32_t cycles = (PLL_CLOCK / 1000) * dur_ms / (TIM16->PSC + 1);
    uint32_t arr = cycles - 1;
    
    // Make sure ARR stays within 16 bits
    if(arr > 0xFFFF) arr = 0xFFFF;
    
    // Set ARR and duty cycle (50%)
    TIM16->ARR = arr;
    TIM16->CCR1 = arr/2;  // 50% duty cycle
    
    // Reset counter
    TIM16->CNT = 0;
    
    // Generate update event
    TIM16->EGR |= 1;
    TIM16->SR &= ~(1<<0);  // Clear UIF flag
    
    // Enable counter
    TIM16->CR1 |= 1;
    
    // Wait until UIF flag is set (timer complete)
    while(!(TIM16->SR & (1 << 0)));
    
    // Disable counter
    TIM16->CR1 &= ~1;
    // Clear the UIF flag
    TIM16->SR &= ~(1<<0);
}