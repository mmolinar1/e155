/*
File: STM32L432KC_SPI.c
Author: Matthew Molinar
Email: mmolinar@hmc.edu
Date: 10/14/2025

Source code for SPI functions
*/

#include "STM32L432KC.h"
#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"

/* Enables the SPI peripheral and intializes its clock speed (baud rate), polarity, and phase.
 *    -- br: (0b000 - 0b111). The SPI clk will be the master clock / 2^(BR+1).
 *    -- cpol: clock polarity (0: inactive state is logical 0, 1: inactive state is logical 1).
 *    -- cpha: clock phase (0: data captured on leading edge of clk and changed on next edge, 
 *          1: data changed on leading edge of clk and captured on next edge)
 * Refer to the datasheet for more low-level details. */ 
 void initSPI(int br, int cpol, int cpha) {
    // turn on GPIOA and GPIOB clk domains
    RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN);

    // turn on SPI1 clk domain
    RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;

    // Initially assigning SPI pins
    pinMode(SPI_SCK, GPIO_ALT);
    pinMode(SPI_MISO, GPIO_ALT);
    pinMode(SPI_MOSI, GPIO_ALT);
    pinMode(SPI_CE, GPIO_OUTPUT);

    // Set output speed type to high for SCK
    GPIOB->OSPEEDR |= (GPIO_OSPEEDR_OSPEED3);

    // Set to AF05 for SPI alternate functions
    GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL3, 5);
    GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL4, 5);
    GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL5, 5);
    
    // Set baud rate divider
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_BR, br);

    // Set to MSTR
    SPI1->CR1 |= (SPI_CR1_MSTR);
    SPI1->CR1 &= ~(SPI_CR1_CPOL | SPI_CR1_CPHA | SPI_CR1_LSBFIRST | SPI_CR1_SSM);

    SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPHA, cpha);
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPOL, cpol);

    SPI1->CR2 |= _VAL2FLD(SPI_CR2_DS, 0b0111);
    SPI1->CR2 |= (SPI_CR2_FRXTH | SPI_CR2_SSOE);

    // Enable SPI
    SPI1->CR1 |= (SPI_CR1_SPE);
}

/* Transmits a character (1 byte) over SPI and returns the received character.
 *    -- send: the character to send over SPI
 *    -- return: the character received over SPI */
char spiSendReceive(char send) {
    while(!(SPI1->SR & SPI_SR_TXE)); // Wait until the transmit buffer is empty

    *(volatile char *) (&SPI1->DR) = send; // Transmit the character over SPI

    while(!(SPI1->SR & SPI_SR_RXNE)); // Wait until data in RX

    return (volatile char) SPI1->DR; // received character
}