/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/03/2025
file: encoder.c
*/
#include "encoder.h"
#include "main.h"

// Global variable definitions
volatile int32_t encoder_count = 0;

// Initialization function
void encoder_init(void) {
    // Enable PIN_A as input
    gpioEnable(GPIO_PORT_A);
    pinMode(PIN_A, GPIO_INPUT);
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD1, 0b10); // Set PA1 as pull-down


    // Enable PIN_B as input
    gpioEnable(GPIO_PORT_A);
    pinMode(PIN_B, GPIO_INPUT);
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD2, 0b10); // Set PA2 as pull-down

    // Initialize timer
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    initTIM(DELAY_TIM);

    // 1. Enable SYSCFG clock domain in RCC
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
    // 2. Configure EXTICR for the input button interrupt
    SYSCFG->EXTICR[0] |= _VAL2FLD(SYSCFG_EXTICR1_EXTI1, 0b000); // Select PA1
    SYSCFG->EXTICR[0] |= _VAL2FLD(SYSCFG_EXTICR1_EXTI2, 0b000); // Select PA2
}

// Interrupt Handlers
void EXTI1_IRQHandler(void) {
    // Check that PIN_A was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(PIN_A))){
        // Clear the interrupt 
        EXTI->PR1 |= (1 << gpioPinOffset(PIN_A));

        // Read current state of both pins
        uint32_t a_state = digitalRead(PIN_A);
        uint32_t b_state = digitalRead(PIN_B);

        // If a_state == b_state, CCW
        // If a_state != b_state, CW
        if (a_state == b_state) {
            encoder_count--; // CCW
        } else {
            encoder_count++; // CW
        }
    }
}

void EXTI2_IRQHandler(void) {
    // Check that PIN_B was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(PIN_B))){
        // Clear the interrupt
        EXTI->PR1 |= (1 << gpioPinOffset(PIN_B));

        // Read current state of both pins
        uint32_t a_state = digitalRead(PIN_A);
        uint32_t b_state = digitalRead(PIN_B);

        // If a_state != b_state, CCW
        // If a_state == b_state, CW 
        if (a_state != b_state) {
            encoder_count--; // CCW
        } else {
            encoder_count++; // CW
        }
    }
}