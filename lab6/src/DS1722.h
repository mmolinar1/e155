/*
File: DS1722.h
Author: Matthew Molinar
Email: mmolinar@hmc.edu
Date: 10/14/2025

Header file for DS1722 functions
*/


#ifndef DS1722_H
#define DS1722_H

#include <stdint.h>

// DS1722 Register Addresses
#define READ_TEMP_LSB_CMD   0x01 // Read Temperature LSB Register
#define READ_TEMP_MSB_CMD   0x02 // Read Temperature MSB Register
#define CONFIG_WRITE_CMD    0x80 // Write to Configuration Register

// Configuration bits
#define RES_8_BIT   8
#define RES_9_BIT   9
#define RES_10_BIT  10
#define RES_11_BIT  11
#define RES_12_BIT  12

// Initializes the DS1722 sensor
void initDS1722(uint8_t resolution);

// Reads the temperature from the DS1722
float readTemp(void);

// Get the current bit resolution
uint8_t get_resolution(void);

#endif