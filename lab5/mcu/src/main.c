/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/03/2025
file: main.c

*/

#include "stm32l4xx.h"
#include "encoder.h"
#include <stdint.h>

int main(void) {
    // Enable PIN_A as input
    gpioEnable(GPIO_PORT_A);
    pinMode(PIN_A, GPIO_INPUT);

    // Enable PIN_B as input
    gpioEnable(GPIO_PORT_A);
    pinMode(PIN_B, GPIO_INPUT);
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD2, 0b01); // Set PA2 as pull-up

    // Initialize timer
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    initTIM(DELAY_TIM);

    // 1. Enable SYSCFG clock domain in RCC
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
    // 2. Configure EXTICR for the input button interrupt
    SYSCFG->EXTICR[0] |= _VAL2FLD(SYSCFG_EXTICR1_EXTI2, 0b000); // Select PA2

    // Enable interrupts globally
    __enable_irq();

    // PIN_A
    // 1. Configure mask bit
    EXTI->IMR1 |= (1 << gpioPinOffset(PIN_A)); // Configure the mask bit
    // 2. Disable rising edge trigger
    EXTI->RTSR1 &= ~(1 << gpioPinOffset(PIN_A));// Disable rising edge trigger
    // 3. Enable falling edge trigger
    EXTI->FTSR1 |= (1 << gpioPinOffset(PIN_A));// Enable falling edge trigger
    // 4. Turn on EXTI interrupt in NVIC_ISER
    NVIC->ISER[0] |= (1 << EXTI2_IRQn);

    // PIN_B
    // 1. Configure mask bit
    EXTI->IMR1 |= (1 << gpioPinOffset(PIN_B)); // Configure the mask bit
    // 2. Disable rising edge trigger
    EXTI->RTSR1 &= ~(1 << gpioPinOffset(PIN_B));// Disable rising edge trigger
    // 3. Enable falling edge trigger
    EXTI->FTSR1 |= (1 << gpioPinOffset(PIN_B));// Enable falling edge trigger
    // 4. Turn on EXTI interrupt in NVIC_ISER
    NVIC->ISER[0] |= (1 << EXTI1_IRQn);

    while(1){   
        delay_millis(TIM2, 200);
    }

}