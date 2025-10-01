/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 09/27/2025
file: STM32L432KC_FLASH.c

Source code for FLASH functions - from
course GitHub
*/

#include "STM32L432KC_FLASH.h"

void configureFlash(void) {
    FLASH->ACR |= (0b100); // Set to 4 waitstates
    FLASH->ACR |= (1 << 8); // Turn on the ART
}