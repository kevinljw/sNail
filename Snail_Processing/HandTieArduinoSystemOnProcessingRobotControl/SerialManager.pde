import processing.serial.*;
import java.util.ArrayList;
import java.util.Arrays;

public class SerialManager implements ControlListener, SerialNotifier, GRTListener{

   final static int SERIAL_PORT_BAUD_RATE = 38400;

   final static int SERIAL_PORT_NUM = 7;

   //send to arduino protocol
   public final static int ALL_CALIBRATION = 0;
   public final static int ALL_CALIBRATION_CONST_AMP = 1;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_MIN_AMP = 2;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_WITH_AMP = 3;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_AT_CONST_AMP = 4;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_MIN_AMP = 5;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_WITH_AMP = 6;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_AT_CONST_AMP = 7;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_BRIDGE_POT_POS = 8;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_AMP_POT_POS = 9;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGE_BRIDGE_POT_POS = 10;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGE_AMP_POT_POS = 11;
   public final static int SEND_LED_SIGNAL = 12;


   //receive from arduino protocol
   public final static int RECEIVE_NORMAL_VALS = 0;
   public final static int RECEIVE_CALI_VALS = 1;
   public final static int RECEIVE_TARGET_MIN_AMP_VALS = 2;
   public final static int RECEIVE_TARGET_AMP_VALS = 3;
   public final static int RECEIVE_BRIDGE_POT_POS_VALS = 4;
   public final static int RECEIVE_AMP_POT_POS_VALS = 5;
   public final static int RECEIVE_CALIBRATING_MIN_AMP_VALS = 6;
   public final static int RECEIVE_CALIBRATING_AMP_VALS = 7;
   public final static int RECEIVE_RECORD_SIGNAL = 8;

   //GRT
   public final float likelihoodThreshold = RobotControl.likelihoodThreshold;
   int lastClassLabel;


   Serial arduinoPort;
   PApplet mainClass;
   String portName;

   ArrayList<SerialListener> serialListeners = new ArrayList<SerialListener>();

   public SerialManager(PApplet mainClass){
      this.mainClass = mainClass;
   }

   private void connectToSerial(){
      // Setup serial port I/O
      println("AVAILABLE SERIAL PORTS:");
      println(Serial.list());
      portName = Serial.list()[SERIAL_PORT_NUM];
      connectToSerial(portName);
   }

   private void connectToSerial(int portNumber){
      portName = Serial.list()[portNumber];
      connectToSerial(portName);
   }

   private void connectToSerial(String name){
      println();
      println("LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
      println("  -> Using port : " + name);
      disconnectSerial();

      try {
         arduinoPort = new Serial(mainClass, name, SERIAL_PORT_BAUD_RATE);
         arduinoPort.bufferUntil(10);    //newline
      } catch (Exception e) {
         println("connectToSerial : " + e.getMessage());
      }
   }

   private void disconnectSerial(){
      try {
         arduinoPort.clear();
         arduinoPort.stop();
      } catch (Exception e) {
         println("disconnectSerial : " + e.getMessage());
      }
   }

   private float [] parseSpaceSeparatedData(Serial port) throws Exception{
      String buf = port.readString();
      // print(buf);
      String [] bufSplitArr = buf.split(" ");
      float [] parsedDataArr = new float[bufSplitArr.length-1];

      for (int i = 0; i < bufSplitArr.length-1; ++i){
         parsedDataArr[i] = Float.parseFloat(bufSplitArr[i]);
         // print(parsedDataArr[i]+" ");
      }

      return parsedDataArr;
   }

   public void parseDataFromSerial(Serial port) throws Exception{
      if (port.equals(arduinoPort)) {
         parseDataFromArduino(port);
      }
   }

   private void parseDataFromArduino(Serial port) throws Exception{
      float [] parsedData = parseSpaceSeparatedData(port);
      float [] values = Arrays.copyOfRange(parsedData,1,parsedData.length);
      switch ((int)parsedData[0]) {
         case RECEIVE_NORMAL_VALS:
            notifyAllWithAnalogVals(values);
            break;
         case RECEIVE_CALI_VALS:
            notifyAllWithCaliVals(values);
            break;
         case RECEIVE_TARGET_MIN_AMP_VALS:
            notifyAllWithTargetAnalogValsMinAmp(values);
            break;
         case RECEIVE_TARGET_AMP_VALS:
            notifyAllWithTargetAnalogValsWithAmp(values);
            break;
         case RECEIVE_BRIDGE_POT_POS_VALS:
            notifyAllWithBridgePotPosVals(values);
            break;
         case RECEIVE_AMP_POT_POS_VALS:
            notifyAllWithAmpPotPosVals(values);
            break;
         case RECEIVE_CALIBRATING_MIN_AMP_VALS:
            notifyAllWithCalibratingValsMinAmp(values);
            break;
         case RECEIVE_CALIBRATING_AMP_VALS:
            notifyAllWithCalibratingValsWithAmp(values);
            break;
         case RECEIVE_RECORD_SIGNAL:
            notifyAllWithReceiveRecordSignal();
            break;
      }
   }

   public void sendToArduino(String str){
     try {
       arduinoPort.write(str);
     }
     catch(Exception e) {
       println(e.getMessage());
     }
   }

   public void performKeyPress(char k){
      switch (k) {
         case 'c' :
            disconnectSerial();
            connectToSerial(portName);

            //sendToArduino(Integer.toString(ALL_CALIBRATION_CONST_AMP));
            
            break;
      }
   }

   @Override
   public void registerForSerialListener(SerialListener listener){
      serialListeners.add(listener);
   }

   @Override
   public void removeSerialListener(SerialListener listener){
      serialListeners.remove(listener);
   }

   @Override
   public void notifyAllWithDiscoveredSerialPorts(){
      String [] portNames = Serial.list();
      for (SerialListener listener : serialListeners) {
         listener.updateDiscoveredSerialPorts(portNames);
      }
   }

   @Override
   public void notifyAllWithAnalogVals(float [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateAnalogVals(values);
      }
   }

   @Override
   public void notifyAllWithCaliVals(float [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateCaliVals(values);
      }
   }

   @Override
   public void notifyAllWithTargetAnalogValsMinAmp(float [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateTargetAnalogValsMinAmp(values);
      }
   }

   @Override
   public void notifyAllWithTargetAnalogValsWithAmp(float [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateTargetAnalogValsWithAmp(values);
      }
   }

   @Override
   public void notifyAllWithBridgePotPosVals(float [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateBridgePotPosVals(values);
      }
   }

   @Override
   public void notifyAllWithAmpPotPosVals(float [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateAmpPotPosVals(values);
      }
   }

   @Override
   public void notifyAllWithCalibratingValsMinAmp(float [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateCalibratingValsMinAmp(values);
      }
   }

   @Override
   public void notifyAllWithCalibratingValsWithAmp(float [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateCalibratingValsWithAmp(values);
      }
   }

   @Override
   public void notifyAllWithReceiveRecordSignal(){
      for (SerialListener listener : serialListeners) {
         listener.updateReceiveRecordSignal();
      }
   }

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (millis() < 1000) return;

      if (theEvent.getName().equals(UIInteractionMgr.SLIDER_BRIDGE_TARGET_MIN_AMP_ALL)) {
         manualChangeAllGauges(MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_MIN_AMP, theEvent);
      }
      else if (theEvent.getName().equals(UIInteractionMgr.SLIDER_AMP_TARGET_CONST_BRIDGE_ALL)){
         manualChangeAllGauges(MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_WITH_AMP, theEvent);
      }
      else if (theEvent.getName().equals(UIInteractionMgr.SLIDER_BRIDGE_TARGET_CONST_AMP_ALL)){
         manualChangeAllGauges(MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_AT_CONST_AMP, theEvent);
      }
      else if (theEvent.getName().equals(UIInteractionMgr.SLIDER_BRIDGE_POT_ALL)){
         manualChangeAllGauges(MANUAL_CHANGE_TO_ALL_GAUGE_BRIDGE_POT_POS, theEvent);
      }
      else if (theEvent.getName().equals(UIInteractionMgr.SLIDER_AMP_POT_ALL)){
         manualChangeAllGauges(MANUAL_CHANGE_TO_ALL_GAUGE_AMP_POT_POS, theEvent);
      }
      else if (theEvent.getName().equals(UIInteractionMgr.CALIBRATE)){
         sendToArduino(Integer.toString(ALL_CALIBRATION));
      }
      else if (theEvent.getName().equals(UIInteractionMgr.CALIBRATE_CONST_AMP)){
         sendToArduino(Integer.toString(ALL_CALIBRATION_CONST_AMP));
      }
      else if (theEvent.getName().contains(UIInteractionMgr.SLIDERS_BRIDGE_TARGET_MIN_AMP)){
         manualChangeOneGauge(MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_MIN_AMP, theEvent,
                              UIInteractionMgr.SLIDERS_BRIDGE_TARGET_MIN_AMP);
      }
      else if (theEvent.getName().contains(UIInteractionMgr.SLIDERS_AMP_TARGET_CONST_BRIDGE)){
         manualChangeOneGauge(MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_WITH_AMP, theEvent,
                              UIInteractionMgr.SLIDERS_AMP_TARGET_CONST_BRIDGE);
      }
      else if (theEvent.getName().contains(UIInteractionMgr.SLIDERS_BRIDGE_TARGET_CONST_AMP)){
         manualChangeOneGauge(MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_AT_CONST_AMP, theEvent,
                              UIInteractionMgr.SLIDERS_BRIDGE_TARGET_CONST_AMP);
      }
      else if (theEvent.getName().contains(UIInteractionMgr.SLIDERS_BRIDGE_POT)){
         manualChangeOneGauge(MANUAL_CHANGE_TO_ONE_GAUGE_BRIDGE_POT_POS, theEvent,
                              UIInteractionMgr.SLIDERS_BRIDGE_POT);
      }
      else if (theEvent.getName().contains(UIInteractionMgr.SLIDERS_AMP_POT)){
         manualChangeOneGauge(MANUAL_CHANGE_TO_ONE_GAUGE_AMP_POT_POS, theEvent,
                              UIInteractionMgr.SLIDERS_AMP_POT);
      }
      else if (theEvent.getName().equals(UIInteractionMgr.DROPDOWN_ARDUINO_SERIAL_LIST)){
         connectToSerial((int)(theEvent.getValue()));
      }
   }

   private void manualChangeAllGauges(int protocol, ControlEvent theEvent){
      String sendMessage = new String(protocol + " "
                                      + (int)(theEvent.getValue()));
      sendToArduino(sendMessage);
   }

   private void manualChangeOneGauge(int protocol, ControlEvent theEvent,
                                     String splitStr){
      String [] nameSplit = theEvent.getName().split(splitStr);

      int index = Integer.parseInt(nameSplit[1]);

      String sendMessage = new String(protocol + " " + index + " "
                                      + (int)(theEvent.getValue()));
      sendToArduino(sendMessage);
   }

   @Override
   public void registerToGRTNotifier(GRTNotifier notifier){
      notifier.registerForGRTListener(this);
   }
   @Override
   public void removeToGRTNotifier(GRTNotifier notifier){
      notifier.removeGRTListener(this);
   }
   @Override
   public void updateGRTResults(int label, float likelihood){
      // if (likelihood > likelihoodThreshold && lastClassLabel != label) {
      //    String sendMessage = new String(SEND_LED_SIGNAL + " " + 1 + " "
      //                                     + 1 + " " + 0 + " " + 0 + " " + 255 + " "
      //                                     + 0 + " " + 0 + " " + 5);
      //    println("sendMessage is " + sendMessage);
      //    sendToArduino(sendMessage);
      // }
      // lastClassLabel = label;
   }
}
