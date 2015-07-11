#include "StrainGauge.h"

StrainGauge::StrainGauge(){

}

StrainGauge::StrainGauge(uint8_t ampPotPos, uint8_t bridgePotPos, uint16_t targetValMinAmp,
                         uint16_t targetValWithAmp){
   this->ampPotPos = ampPotPos;
   this->bridgePotPos = bridgePotPos;
   this->targetValMinAmp = targetValMinAmp;
   this->targetValWithAmp = targetValWithAmp;
   broken = false;
   currentIndexToUpdate = 0;
   for(int i = 0;i < numValsToCached;i++) {
      inputVals[i] = 0;
   }
}

StrainGauge::~StrainGauge(){

}

void StrainGauge::setAmpPotPos(uint8_t ampPotPos){
   this->ampPotPos = ampPotPos;
}

uint8_t StrainGauge::getAmpPotPos(){
   return ampPotPos;
}

void StrainGauge::setBridgePotPos(uint8_t bridgePotPos){
   this->bridgePotPos = bridgePotPos;
}

uint8_t StrainGauge::getBridgePotPos(){
   return bridgePotPos;
}

void StrainGauge::setTargetValMinAmp(uint16_t targetVal){
   this->targetValMinAmp = targetVal;
}

uint16_t StrainGauge::getTargetValMinAmp(){
   return targetValMinAmp;
}

void StrainGauge::setTargetValWithAmp(uint16_t targetVal){
   this->targetValWithAmp = targetVal;
}

uint16_t StrainGauge::getTargetValWithAmp(){
   return targetValWithAmp;
}

void StrainGauge::setBridgeCaliNeeded(){
   bridgeCaliComplete = false;
}

void StrainGauge::setBridgeCaliComplete(){
   bridgeCaliComplete = true;
}

boolean StrainGauge::isBridgeCaliComplete(){
   return bridgeCaliComplete;
}

void StrainGauge::setAmpCaliNeeded(){
   ampCaliComplete = false;
}

void StrainGauge::setAmpCaliComplete(){
   ampCaliComplete = true;
}

boolean StrainGauge::isAmpCaliComplete(){
   return ampCaliComplete;
}

void StrainGauge::setBroken(){
   broken = true;
}

boolean StrainGauge::isBroken(){
   return broken;
}

uint16_t* StrainGauge::getInputVals() {
   return inputVals;
}

void StrainGauge::updateInputVals(uint16_t val) {
   inputVals[currentIndexToUpdate] = val;
   currentIndexToUpdate = (currentIndexToUpdate + 1) % numValsToCached;
}
