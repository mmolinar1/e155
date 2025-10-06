/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/04/2025
file: encoder.h 

Header file for encoder functions
*/

#ifndef ENCODER_H
#define ENCODER_H

#include <stdint.h>

// Global variables declarations
extern volatile int32_t encoder_count;

void encoder_init(void);         // sets up pins + interrupts

#endif