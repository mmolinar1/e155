/*
author: Matthew Molinar
email: mmolinar@hmc.edu
date created: 10/04/2025
file: main.c

*/

#ifndef ENCODER_H
#define ENCODER_H

#include <stdint.h>

void encoder_init(void);         // sets up pins + interrupts
uint32_t encoder_get_count(void);  // returns current position
void encoder_reset(void);        // reset count to 0
int32_t encoder_get_velocity(void);
int32_t encoder_get_direction(void); 

#endif
