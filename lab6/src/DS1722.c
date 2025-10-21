/*
File: DS1722.c
Author: Matthew Molinar
Email: mmolinar@hmc.edu
Date: 10/14/2025

Source code for DS1722 functions
*/

#include "DS1722.h"
#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"

// register config bits
#define CONFIG_REG_RES_8_BIT    0x00 // R2,R1,R0 = 000
#define CONFIG_REG_RES_9_BIT    0x02 // R2,R1,R0 = 001
#define CONFIG_REG_RES_10_BIT   0x04 // R2,R1,R0 = 010
#define CONFIG_REG_RES_11_BIT   0x06 // R2,R1,R0 = 011
#define CONFIG_REG_RES_12_BIT   0x08 // R2,R1,R0 = 100

static uint8_t current_resolution;

// Initializes the DS1722 with a specific resolution
void initDS1722(uint8_t resolution) {
    uint8_t config_byte;
    current_resolution = resolution; // Store resolution

    // Determine the correct config byte to send
    switch(resolution) {
        case RES_8_BIT:
            config_byte = CONFIG_REG_RES_8_BIT;
            break;
        case RES_9_BIT:
            config_byte = CONFIG_REG_RES_9_BIT;
            break;
        case RES_10_BIT:
            config_byte = CONFIG_REG_RES_10_BIT;
            break;
        case RES_11_BIT:
            config_byte = CONFIG_REG_RES_11_BIT;
            break;
        case RES_12_BIT:
            config_byte = CONFIG_REG_RES_12_BIT;
            break;
        default:
            config_byte = CONFIG_REG_RES_8_BIT;
            current_resolution = RES_8_BIT; 
            break;
    }

    digitalWrite(SPI_CE, PIO_HIGH); // Select device
    
    // Send write-config command followed by the resolution config byte
    spiSendReceive(CONFIG_WRITE_CMD); 
    spiSendReceive(config_byte); 
    
    digitalWrite(SPI_CE, PIO_LOW); // Deselect device
}


// Reads the temperature from the DS1722
float readTemp(void) {
    uint8_t tempLow, tempHigh;
    
    // Read LSB
    digitalWrite(SPI_CE, PIO_HIGH);
    spiSendReceive(READ_TEMP_LSB_CMD);
    tempLow = spiSendReceive(0x00);
    digitalWrite(SPI_CE, PIO_LOW);
    
    // Read MSB (separate transaction)
    digitalWrite(SPI_CE, PIO_HIGH);
    spiSendReceive(READ_TEMP_MSB_CMD);
    tempHigh = spiSendReceive(0x00);
    digitalWrite(SPI_CE, PIO_LOW);
    
    // Process temperature data
    int16_t raw_temp = (tempHigh << 8) | tempLow;
    


    int16_t scaled_temp;
    float multiplier;

    // Apply the correct shift and multiplier based on the stored resolution
    switch(current_resolution) {
        case RES_8_BIT:
            scaled_temp = raw_temp >> 8; // Shift right 8 bits
            multiplier = 1.0;            // LSB = 1.0
            break;
        case RES_9_BIT:
            scaled_temp = raw_temp >> 7; // Shift right 7 bits
            multiplier = 0.5;            // LSB = 0.5
            break;
        case RES_10_BIT:
            scaled_temp = raw_temp >> 6; // Shift right 6 bits
            multiplier = 0.25;           // LSB = 0.25
            break;
        case RES_11_BIT:
            scaled_temp = raw_temp >> 5; // Shift right 5 bits
            multiplier = 0.125;          // LSB = 0.125
            break;
        case RES_12_BIT:
            scaled_temp = raw_temp >> 4; // Shift right 4 bits
            multiplier = 0.0625;         // LSB = 0.0625
            break;
        default:  // 8 bit by default
            scaled_temp = raw_temp >> 8; // Shift right 8 bits
            multiplier = 1.0;            // LSB = 1.0
            break;

    }
    
    // The final temperature is the shifted value * LSB weight
    return (float)scaled_temp * multiplier;
}

// get the current bit resolution
uint8_t get_resolution(void) {
    return current_resolution;
}