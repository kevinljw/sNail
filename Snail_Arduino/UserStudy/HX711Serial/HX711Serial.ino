#include "hx711.h"

Hx711 scale(A1, A0);

void setup() {

  Serial.begin(115200);

}

void loop() {

  Serial.print(scale.getGram(), 1);
  Serial.println(" g");

}
