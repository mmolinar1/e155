/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/04/2025
file: main.c

*/

#ifndef ENCODER_H
#define ENCODER_H

#include <stdint.h>

// Global variables declarations
extern volatile int32_t encoder_count;
extern volatile int32_t direction; // direction: 1 for forward, -1 for backward, 0 for stopped

void encoder_init(void);         // sets up pins + interrupts

#endif