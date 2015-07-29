#ifndef SGManager_h
#define SGManager_h

#include <Arduino.h>
#include "analogmuxdemux.h"
//#include "MCP4251.h"
#include "AD5231.h"
#include "StrainGauge.h"
#include "SerialProtocol.h"
#include "Filter.h"

// --------- AnalogMux Macro Define --------- //
#define SS0 2
#define SS1 3
#define SS2 4
#define MS0 5
#define MS1 6
#define MS2 7
#define READPIN A0

// ---------   MCP4251 Macro Define --------- //
#define POT_SS_PIN 10
#define OHM_AB 5040
#define OHM_WIPER 102

#define WIPER0_INIT_POS 4
#define WIPER1_INIT_POS 300

// #define TARGET_NO_AMP 20
// #define TARGET_WITH_AMP 295
#define TARGET_TOLERANCE_NO_AMP 1
#define TARGET_TOLERANCE_WITH_AMP 100

// -------- StrainGauge Macro Define -------- //
#define NUM_OF_GAUGES 9
#define CALI_TIMEOUT ((unsigned long)15000)
// #define BROKEN_OMIT

#define TARGET_VAL_MIN_AMP 5
#define TARGET_VAL_WITH_AMP 400

#define NUM_OF_CALI_INFO 5

// ------------- SGManager class ------------ //

class SGManager{

public:
   SGManager();
   ~SGManager();

   void serialPrint();
   void serialPrint(int);

   void sendStoredValues(int);

   void allCalibration();
   void allCalibrationAtConstAmp();

   void manualAssignBridgePotPosForOneGauge(uint16_t, uint16_t);
   void manualAssignAmpPotPosForOneGauge(uint16_t, uint16_t);

   void manualAssignBridgePotPosForAllGauges(uint16_t);
   void manualAssignAmpPotPosForAllGauges(uint16_t);

   void manualAssignTargetValMinAmpForOneGauge(uint16_t, uint16_t);
   void manualAssignTargetValWithAmpForOneGauge(uint16_t, uint16_t);
   void manualAssignTargetValAtConstAmpForOneGauge(uint16_t, uint16_t);

   void manualAssignTargetValMinAmpForAllGauges(uint16_t);
   void manualAssignTargetValWithAmpForAllGauges(uint16_t);
   void manualAssignTargetValAtConstAmpForAllGauges(uint16_t);

private:
   AnalogMux * analogMux;
   AD5231 * ad5231;
   StrainGauge * gauges[NUM_OF_GAUGES];
   FilterConfig* config;

   unsigned long startCaliTime;

   uint16_t stateMachine;

   void calibrateBridgeAtMinAmp();
   void calibrateAmpAtConstBridge();
   void calibrateBridgeAtConstAmp();
   uint16_t filterValue(int i);

   boolean calibrateBridgePotMinAmp(int);
   boolean calibrateAmpPotAtConstBridge(int);
   boolean calibrateBridgePotAtConstAmp(int);

};

#endif   //SGManager_h
