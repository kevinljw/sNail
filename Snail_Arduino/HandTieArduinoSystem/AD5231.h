#ifndef AD5231_h
#define AD5231_h

#include <Arduino.h>
#include <SPI.h>

class AD5231
{
public:
   AD5231(uint16_t slave_select);

   void resistance_write(uint16_t value);

private:
   byte command = 0xB0;
   uint16_t slave_select; 
};

#endif // AD5231_h