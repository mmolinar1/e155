#include "stm32l4xx_hal.h"

#define ENC_A_PIN        GPIO_PIN_0
#define ENC_A_PORT       GPIOA
#define ENC_B_PIN        GPIO_PIN_1
#define ENC_B_PORT       GPIOA

volatile int32_t encoder_count = 0;

void Encoder_GPIO_Init(void) {
    __HAL_RCC_GPIOA_CLK_ENABLE();

    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING_FALLING;
    GPIO_InitStruct.Pull = GPIO_PULLUP; // or GPIO_NOPULL depending on encoder
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;

    GPIO_InitStruct.Pin = ENC_A_PIN;
    HAL_GPIO_Init(ENC_A_PORT, &GPIO_InitStruct);

    GPIO_InitStruct.Pin = ENC_B_PIN;
    HAL_GPIO_Init(ENC_B_PORT, &GPIO_InitStruct);

    // Enable and set EXTI interrupts
    HAL_NVIC_SetPriority(EXTI0_IRQn, 1, 0);
    HAL_NVIC_EnableIRQ(EXTI0_IRQn);
    HAL_NVIC_SetPriority(EXTI1_IRQn, 1, 0);
    HAL_NVIC_EnableIRQ(EXTI1_IRQn);
}

// Interrupt handlers
void EXTI0_IRQHandler(void) {
    HAL_GPIO_EXTI_IRQHandler(ENC_A_PIN);
}

void EXTI1_IRQHandler(void) {
    HAL_GPIO_EXTI_IRQHandler(ENC_B_PIN);
}

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
    uint8_t A = HAL_GPIO_ReadPin(ENC_A_PORT, ENC_A_PIN);
    uint8_t B = HAL_GPIO_ReadPin(ENC_B_PORT, ENC_B_PIN);

    if (GPIO_Pin == ENC_A_PIN || GPIO_Pin == ENC_B_PIN) {
        // Decode direction based on A/B
        if (A == B)
            encoder_count++;  // CW
        else
            encoder_count--;  // CCW
    }
}
