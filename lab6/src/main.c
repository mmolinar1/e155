/*
File: main.c
Author: Matthew Molinar
Email: mmolinar@hmc.edu
Date: 10/14/2025
*/


#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "main.h"
#include "DS1722.h"

/////////////////////////////////////////////////////////////////
// Provided Constants and Functions
/////////////////////////////////////////////////////////////////

//Defining the web page in two chunks: everything before the current time, and everything after the current time
char* webpageStart = "<!DOCTYPE html><html><head><title>E155 Web Server Demo Webpage</title>\
	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\
	</head>\
	<body><h1>E155 Web Server Demo Webpage</h1>";

char* ledStr = "<p>LED Control:</p><form action=\"ledon\"><input type=\"submit\" value=\"Turn the LED on!\"></form>\
	<form action=\"ledoff\"><input type=\"submit\" value=\"Turn the LED off!\"></form>";

  // HTML bit resolution buttons
char* res_str = "<h2>Set Resolution</h2>" \
    "<form action=\"res8\"><input type=\"submit\" value=\"Set 8-bit\"></form>" \
    "<form action=\"res9\"><input type=\"submit\" value=\"Set 9-bit\"></form>" \
    "<form action=\"res10\"><input type=\"submit\" value=\"Set 10-bit\"></form>" \
    "<form action=\"res11\"><input type=\"submit\" value=\"Set 11-bit\"></form>" \
    "<form action=\"res12\"><input type=\"submit\" value=\"Set 12-bit\"></form>";


char* webpageEnd   = "</body></html>";

//determines whether a given character sequence is in a char array request, returning 1 if present, -1 if not present
int inString(char request[], char des[]) {
	if (strstr(request, des) != NULL) {return 1;}
	return -1;
}

int updateLEDStatus(char request[])
{
	int led_status = 0;
	// The request has been received. now process to determine whether to turn the LED on or off
	if (inString(request, "ledoff")==1) {
		digitalWrite(LED_PIN, PIO_LOW);
		led_status = 0;
	}
	else if (inString(request, "ledon")==1) {
		digitalWrite(LED_PIN, PIO_HIGH);
		led_status = 1;
	}

	return led_status;
}

// Function to parse the request and update bit resolution
void update_resolution(char request[])
{
    if (inString(request, "res8") == 1) {
        initDS1722(RES_8_BIT);
    } else if (inString(request, "res9") == 1) {
        initDS1722(RES_9_BIT);
    } else if (inString(request, "res10") == 1) {
        initDS1722(RES_10_BIT);
    } else if (inString(request, "res11") == 1) {
        initDS1722(RES_11_BIT);
    } else if (inString(request, "res12") == 1) {
        initDS1722(RES_12_BIT);
    }
}

/////////////////////////////////////////////////////////////////
// Solution Functions
/////////////////////////////////////////////////////////////////

int main(void) {
  configureFlash();
  configureClock();

  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);
  gpioEnable(GPIO_PORT_C);

  pinMode(PB3, GPIO_OUTPUT);
  pinMode(PA6, GPIO_OUTPUT);
  
  RCC->APB2ENR |= (RCC_APB2ENR_TIM15EN);
  initTIM(TIM15);
  
  USART_TypeDef * USART = initUSART(USART1_ID, 125000);

  // SPI initialization (mode 1)
  initSPI(0b111, 0, 0);

  // Sensor Initialization
  initDS1722(RES_8_BIT);

  while(1) {
    /* Wait for ESP8266 to send a request.
    Requests take the form of '/REQ:<tag>\n', with TAG begin <= 10 characters.
    Therefore the request[] array must be able to contain 18 characters.
    */

    // Receive web request from the ESP
    char request[BUFF_LEN] = "                  "; // initialize to known value
    int charIndex = 0;
  
    // Keep going until you get end of line character
    while(inString(request, "\n") == -1) {
      // Wait for a complete request to be transmitted before processing
      while(!(USART->ISR & USART_ISR_RXNE));
      request[charIndex++] = readChar(USART);
    }

    // update the bit resolution
    update_resolution(request);

    // Reading tempertaure
    float current_temp = readTemp();
    char temp_str[32];
    sprintf(temp_str, "%.2f", current_temp);  // format temp as string
  
    // Update string with current LED state
    int led_status = updateLEDStatus(request);

    char ledStatusStr[20];
    if (led_status == 1)
      sprintf(ledStatusStr,"LED is on!");
    else if (led_status == 0)
      sprintf(ledStatusStr,"LED is off!");

    // Get Resolution status
    uint8_t current_res = get_resolution();
    char res_status_str[30];
    sprintf(res_status_str, "Current Resolution: %d-bit", current_res);

    // finally, transmit the webpage over UART
    sendString(USART, webpageStart); // webpage header code
    sendString(USART, ledStr); // button for controlling LED

    // LED
    sendString(USART, "<h2>LED Status</h2>");
    sendString(USART, "<p>");
    sendString(USART, ledStatusStr);
    sendString(USART, "</p>");

    // TEMP
    sendString(USART, "<h2>Temperature</h2>");
    sendString(USART, "<p>");
    sendString(USART, temp_str);
    sendString(USART, " &deg;C</p>");

    // BIT RES
    sendString(USART, res_str); // Send the buttons
    sendString(USART, "<h2>Bit Resolution Status</h2>");
    sendString(USART, "<p>");
    sendString(USART, res_status_str); // Send the current status
    sendString(USART, "</p>");

    sendString(USART, webpageEnd);
  }
}

/////////////////////////////////////////////////////////////////
// Testing SPI Transaction
/////////////////////////////////////////////////////////////////

//int main(void) {
//    configureFlash();
//    configureClock();

//    gpioEnable(GPIO_PORT_A);
//    gpioEnable(GPIO_PORT_B);
  
//    // Initialize SPI w a slow baud rate
//    initSPI(0b111, 0, 0);

//    char message[] = "Matthew";
//    int message_len = 7;

//    // transmit the message repeatedly
//    while(1) {
        
//        //  Chip Enable (CE)
//        digitalWrite(SPI_CE, PIO_LOW);

//        // Loop through the message and send each character
//        for (int i = 0; i < message_len; i++) {
//            // Send one byte and ignore the received byte
//            //spiSendReceive(message[i]);
//            spiSendReceive(0xAA);

//        }

//        // deselect
//        digitalWrite(SPI_CE, PIO_HIGH);
//    }
//}