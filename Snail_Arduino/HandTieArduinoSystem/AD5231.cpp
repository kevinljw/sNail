#include "AD5231.h"

AD5231::AD5231(uint8_t slave_select){
	SPI.begin();
	SPI.setBitOrder(MSBFIRST);

	this->slave_select = slave_select;
	pinMode(this->slave_select, OUTPUT);
	digitalWrite(this->slave_select, HIGH);
}

void AD5231::resistance_write(uint16_t value){
	digitalWrite(this->slave_select, LOW); //select slave
 	SPI.transfer(this->command); 
 	byte byte1 = (value >> 8);
 	byte byte0 = (value & 0xFF); //0xFF = B11111111
 	SPI.transfer(byte1);
 	SPI.transfer(byte0);
 	digitalWrite(this->slave_select, HIGH); //de-select slave
}