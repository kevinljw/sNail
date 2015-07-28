import java.util.ArrayList;

public class GRTMgr implements SerialListener, GRTNotifier{
   HandTieArduinoSystemOnProcessingRobotControl mainClass;

   //-----------------------------------GRT
   //Set the pipeline mode (CLASSIFICATION_MODE or REGRESSION_MODE), the number of inputs and the number of outputs
   final int pipelineMode = GRT.CLASSIFICATION_MODE;
   final int numInputs = SGManager.NUM_OF_GAUGES + AccelMgr.NUM_OF_AXIS;
   final int numOutputs = 1;
    
   public GRT grt = new GRT( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );
   float[] data = new float[ numInputs ];
   float[] targetVector = new float[ numOutputs ];
   
   boolean showGETmsgFlg = true;
   
   ArrayList<GRTListener> grtListeners = new ArrayList<GRTListener>();

   public GRTMgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
      this.mainClass = mainClass;
   }

   public void draw(){
//      fill(color(200));
//        rect(100, 100, width*0.4, height*0.4);
      fill(color(10));
      if( !grt.getInitialized() ){
         background(255,0,0);  
         println("WARNING: GRT Not Initalized. You need to call the setup function!");
         return;
      }
      if(showGETmsgFlg){
         //Draw the info text
         grt.drawInfoText(floor(width*0.72),20);
      }
      //Grab the mouse data and send it to the GRT backend via OSC
      
      for(int idx = 0; idx < SGManager.NUM_OF_GAUGES; idx++){
         data[idx] = mainClass.sgManager.getOneElongationValsOfGauges(idx);
      }
      for(int idx = 0; idx < AccelMgr.NUM_OF_AXIS; idx++){
         data[idx+SGManager.NUM_OF_GAUGES] = mainClass.accelMgr.getOneAxisDifference(idx);
      }

      grt.sendData( data );
//        fill(color(200));
      textSize(50);
      text((char)(grt.getPredictedClassLabel()+96),width*0.4,height*0.2);

      notifyAllWithGRTResults(grt.getPredictedClassLabel(),
                              (float)grt.getMaximumLikelihood());
   }

   public void performKeyPress(char k){
      
      switch (k) {
        case 'm':
            showGETmsgFlg=!showGETmsgFlg;
          break;
        case 'i':
          grt.init( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );
          break;
        case '[':
          grt.decrementTrainingClassLabel();
          break;
        case ']':
          grt.incrementTrainingClassLabel();
          break;
        case 'r':
          if( grt.getRecordingStatus() ){
            grt.stopRecording();
          }else grt.startRecording();
          break;
        case 't':
          grt.startTraining();
          break;
        case 's':
          grt.saveTrainingDatasetToFile( "TrainingData.txt" );
          break;
        case 'l':
          grt.loadTrainingDatasetFromFile( "TrainingData.txt" );
          break;
        case 'c':
          grt.clearTrainingDataset();
          break;
       }
   }
   
   @Override
   public void registerToSerialNotifier(SerialNotifier notifier){
      notifier.registerForSerialListener(this);
   }
   @Override
   public void removeToSerialNotifier(SerialNotifier notifier){
      notifier.removeSerialListener(this);
   }
   @Override
   public void updateDiscoveredSerialPorts(String [] portNames){}
   @Override
   public void updateAnalogVals(float [] values){
      // for (int i = 0; i < values.length; ++i) {
      //    data[i] = values[i];
      // }
   }

   @Override
   public void updateCaliVals(float [] values){}
   @Override
   public void updateTargetAnalogValsMinAmp(float [] values){}
   @Override
   public void updateTargetAnalogValsWithAmp(float [] values){}
   @Override
   public void updateBridgePotPosVals(float [] values){}
   @Override
   public void updateAmpPotPosVals(float [] values){}
   @Override
   public void updateCalibratingValsMinAmp(float [] values){}
   @Override
   public void updateCalibratingValsWithAmp(float [] values){}
   @Override
   public void updateReceiveRecordSignal(){}

   @Override
   public void registerForGRTListener(GRTListener listener){
      grtListeners.add(listener);
   }
   @Override
   public void removeGRTListener(GRTListener listener){
      grtListeners.remove(listener);
   }
   @Override
   public void notifyAllWithGRTResults(int label, float likelihood){
      for (GRTListener grtListener : grtListeners) {
         grtListener.updateGRTResults(label, likelihood);
      }
   }
}
