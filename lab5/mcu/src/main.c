/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/03/2025
file: main.c

uses two interrupts to calculate speed in revolutions per second
and the direction in which a motor is spinning
*/

#include "main.h"
#include "encoder.h"

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
   NVIC->ISER[0] |= (1 << EXTI1_IRQn);

   // PIN_B
   // 1. Configure mask bit
   EXTI->IMR1 |= (1 << gpioPinOffset(PIN_B)); // Configure the mask bit
   // 2. Enable rising edge trigger
   EXTI->RTSR1 |= (1 << gpioPinOffset(PIN_B));// Enable rising edge trigger
   // 3. Enable falling edge trigger
   EXTI->FTSR1 |= (1 << gpioPinOffset(PIN_B));// Enable falling edge trigger
   // 4. Turn on EXTI interrupt in NVIC_ISER
   NVIC->ISER[0] |= (1 << EXTI2_IRQn);

   while(1){
       int32_t curr_count = encoder_count; 
       encoder_count = 0;  
       int32_t time_ms = 500;
       delay_millis(TIM2, time_ms);    // check every half second

       // Calculate rotations per second 
       // 408 PPR, and get 4x counts per revolution
       float rps;
       rps = (float)(curr_count*(1000/time_ms)) / (4 * 408);
       while(!(TIM2->SR & 1)); // Wait for UIF to go high
        
       // Display results
       printf("Rev/s: %.2f\n", rps);
   }
}

// polling test (interrupt vs.polling)
// #include "main.h" 

// int main(void) {
//     // PIN A (PA1) setup
//     gpioEnable(GPIO_PORT_A);
//     pinMode(PIN_A, GPIO_INPUT);
//     GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD1, 0b10); // Set PA1 as pull-down

//     // PIN B (PA2) setup
//     // Note: PIN_B is PA2, so it uses GPIO_PORT_A
//     pinMode(PIN_B, GPIO_OUTPUT); //
//     GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD2, 0b10); // Set PA2 as pull-down

//     // Initialize timer
//     RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
//     initTIM(DELAY_TIM);

//     // Initialize state variables by reading the pins
//     volatile int32_t a_state = digitalRead(PIN_A);
//     volatile int32_t b_val = 0;
//     volatile int32_t prev_a_state = a_state;


//     while(1){
//         // Update previous state trackers
//         prev_a_state = a_state;

//         // Read the current state of the pins
//         a_state = digitalRead(PIN_A);

//         // Check for an edge (a change in state) on PIN_A
//         if (a_state != prev_a_state) {
//           b_val = !b_val;
//           digitalWrite(PIN_B, b_val);
//         } 
        
//         while(!(DELAY_TIM->SR & 1)); // Wait for Update Interrupt Flag
//         delay_millis(TIM2, 100);
//     }
// }


// // interrupt test (interrupt vs. polling)
// #include "main.h"
// #include "encoder.h" 

// int main(void) {
    
//    // 1. Initialize PIN_A as input and PIN_B as output
//    encoder_init();

//    __enable_irq();

//    EXTI->IMR1 |= (1 << gpioPinOffset(PIN_A));
//    // Enable the trigger for both rising and falling edges
//    EXTI->RTSR1 |= (1 << gpioPinOffset(PIN_A));
//    EXTI->FTSR1 |= (1 << gpioPinOffset(PIN_A));
//    NVIC->ISER[0] |= (1 << EXTI1_IRQn);
    
//    while(1){
//    delay_millis(TIM2, 100);
//    }
// }