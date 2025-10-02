#include "stm32l432xx.h"

void tim2_gpio_init(void) {
    // Enable GPIOA clock
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;

    // Set PA0 to Alternate Function mode (MODER = 10)
    GPIOA->MODER &= ~(3U << (0 * 2));   // clear MODER0
    GPIOA->MODER |=  (2U << (0 * 2));   // set AF mode

    // Select AF1 (TIM2_CH1) for PA0
    GPIOA->AFR[0] &= ~(0xF << (0 * 4)); // clear AFRL0
    GPIOA->AFR[0] |=  (1U << (0 * 4));  // AF1
}

void tim2_init(void) {
    // Enable TIM2 clock
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;

    // Set prescaler and auto-reload
    TIM2->PSC = 90;         // Prescaler (PSC+1 = 91)
    TIM2->ARR = 999;        // Auto-reload (ARR+1 = 1000)

    // Configure TIM2_CH1 in toggle mode (OC1M = 0b011)
    TIM2->CCMR1 &= ~(0x7 << 4);
    TIM2->CCMR1 |=  (0x3 << 4);   // OC1M = 011 (toggle on match)

    // Set compare value
    TIM2->CCR1 = 0;   // match at 0, toggle every period

    // Enable output for channel 1
    TIM2->CCER |= TIM_CCER_CC1E;

    // Generate an update event to load PSC and ARR
    TIM2->EGR |= TIM_EGR_UG;

    // Enable counter
    TIM2->CR1 |= TIM_CR1_CEN;
}

int main(void) {
    tim2_gpio_init();
    tim2_init();

    while (1) {
        // main loop can be empty, timer handles waveform
    }
}
