#ifndef StrainGauge_h
#define StrainGauge_h

#include <Arduino.h>

class StrainGauge
{
public:
   StrainGauge();
   StrainGauge(uint16_t, uint16_t, uint16_t, uint16_t);
   ~StrainGauge();

   void setAmpPotPos(uint16_t);
   uint16_t getAmpPotPos();

   void setBridgePotPos(uint16_t);
   uint16_t getBridgePotPos();

   void setTargetValMinAmp(uint16_t);
   uint16_t getTargetValMinAmp();

   void setTargetValWithAmp(uint16_t);
   uint16_t getTargetValWithAmp();

   void setBridgeCaliNeeded();
   void setBridgeCaliComplete();
   boolean isBridgeCaliComplete();

   void setAmpCaliNeeded();
   void setAmpCaliComplete();
   boolean isAmpCaliComplete();

   void setBroken();
   boolean isBroken();

   uint16_t* getInputVals();
   const static uint32_t numValsToCached = 9;

   void updateInputVals(uint16_t val);

private:
   uint16_t ampPotPos;
   uint16_t bridgePotPos;

   uint16_t targetValMinAmp;
   uint16_t targetValWithAmp;

   boolean bridgeCaliComplete;
   boolean ampCaliComplete;

   boolean broken;

   uint16_t inputVals[numValsToCached];
   uint32_t currentIndexToUpdate;
};

#endif   //StrainGauge_h
