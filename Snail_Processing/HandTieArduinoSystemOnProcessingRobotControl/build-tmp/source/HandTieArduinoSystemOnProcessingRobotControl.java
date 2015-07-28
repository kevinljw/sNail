import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import oscP5.*; 
import netP5.*; 
import java.util.ArrayList; 
import processing.serial.*; 
import java.util.ArrayList; 
import java.util.Arrays; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class HandTieArduinoSystemOnProcessingRobotControl extends PApplet {



SGManager sgManager;
SerialManager serialManager;
UIInteractionMgr uiInteractionMgr;
AccelMgr accelMgr;
RobotControl robotControl;
GRTMgr grtMgr;

public void setup() {
   size(900, 600);
   sgManager = new SGManager();
   serialManager = new SerialManager(this);
   accelMgr = new AccelMgr();
   robotControl = new RobotControl(this);
   grtMgr = new GRTMgr(this);
   uiInteractionMgr = new UIInteractionMgr(this);

   listenerRegistrations();
   
   serialManager.notifyAllWithDiscoveredSerialPorts();
}

public void draw() {
   background(255, 255, 255, 0);
   sgManager.draw();
   accelMgr.draw();
   grtMgr.draw();
}

public void listenerRegistrations(){
   sgManager.registerToSerialNotifier(serialManager);
   uiInteractionMgr.registerToSerialNotifier(serialManager);
   accelMgr.registerToSerialNotifier(serialManager);
   grtMgr.registerToSerialNotifier(serialManager);

   serialManager.registerToGRTNotifier(grtMgr);
   robotControl.registerToGRTNotifier(grtMgr);
}

public void keyPressed(){
   uiInteractionMgr.performKeyPress(key);
   serialManager.performKeyPress(key);
   sgManager.performKeyPress(key);
   accelMgr.performKeyPress(key);
   robotControl.performKeyPress(key);
   grtMgr.performKeyPress(key);
}

public void serialEvent(Serial port){
   try {
      serialManager.parseDataFromSerial(port);
   } catch (Exception e) {
      println(e.getMessage());
   }
}
public class AccelAxis{
   // Value data member
   private float calibrationValue;
   private float newValue;

   // Bar Display data member
   private final static float barChangeRatio = 0.4f;
   private float barXOrigin;
   private float barYOrigin;
   private float barWidth;

   // Text Display data member;
   private String axisName;
   private float axisNameTextXOrigin;
   private float axisNameTextYOrigin;
   private float axisNameTextSize;
   private float differenceValTextXOrigin;
   private float differenceValTextYOrigin;
   private float differenceValTextSize;
   private float newValTextXOrigin;
   private float newValTextYOrigin;
   private float newValTextSize;

   public AccelAxis(String axisName){
      this.axisName = axisName;
   }

   //Value methods
   public float getNewValue(){
      return newValue;
   }
   public void setNewValue(float newValue){
      this.newValue = newValue;
   }

   public void setCalibrationValue(float calibrationValue){
      this.calibrationValue = calibrationValue;
   }

   public void calibrateUsingNewValue(){
      calibrationValue = newValue;
   }

   public float getCalibrationValue(){
      return calibrationValue;
   }

   public float getDifferenceVal(){
      return newValue - calibrationValue;
   }

   //Bar Display methods
   public void setBarDisplayProperties(float barXOrigin, float barYOrigin,
                                       float barWidth){
      this.barXOrigin = barXOrigin;
      this.barYOrigin = barYOrigin;
      this.barWidth = barWidth;
   }

   public float [] getBarBaseCenter(){
      float [] barOrigin = new float[2];
      barOrigin[0] = barXOrigin + barWidth/2;
      barOrigin[1] = barYOrigin;
      return barOrigin;
   }

   public int getHeatmapRGB(float value){
     float minimum= -300;
     float maximum=  300;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     int heatmapRGB = color((int)max(0, 255*(ratio - 1)),
                              255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)),
                              (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
   }

   public void drawBar(){
      float difference = getDifferenceVal();

      // color stretch = color(4, 79, 111);
      // color compress = color(255, 145, 158);

      fill(getHeatmapRGB(difference));
      rect(barXOrigin, barYOrigin, barWidth, -difference*barChangeRatio);
   }

   //Text Display methods
   public void setTextDisplayPropertiesForAxisName(float axisNameTextXOrigin,
                                                   float axisNameTextYOrigin,
                                                   float axisNameTextSize){
      this.axisNameTextXOrigin = axisNameTextXOrigin;
      this.axisNameTextYOrigin = axisNameTextYOrigin;
      this.axisNameTextSize = axisNameTextSize;
   }

   public void setTextDisplayPropertiesForDifferenceVal(float differenceValTextXOrigin,
                                                        float differenceValTextYOrigin,
                                                        float differenceValTextSize){
      this.differenceValTextXOrigin = differenceValTextXOrigin;
      this.differenceValTextYOrigin = differenceValTextYOrigin;
      this.differenceValTextSize = differenceValTextSize;
   }

   public void setTextDisplayPropertiesForNewVal(float newValTextXOrigin,
                                                 float newValTextYOrigin,
                                                 float newValTextSize){
      this.newValTextXOrigin = newValTextXOrigin;
      this.newValTextYOrigin = newValTextYOrigin;
      this.newValTextSize = newValTextSize;
   }

   public void drawText(){
      fill(0, 102, 255);
      textSize(axisNameTextSize);
      text(axisName, axisNameTextXOrigin, axisNameTextYOrigin);

      fill(0, 102, 10);
      textSize(differenceValTextSize);
      text(String.format("%.2f",getDifferenceVal()), differenceValTextXOrigin,
           differenceValTextYOrigin);

      fill(150,150,150);
      textSize(newValTextSize);
      text(String.format("%.2f",newValue), newValTextXOrigin, newValTextYOrigin);
   }
}
public class AccelMgr implements ControlListener, SerialListener{
   public static final int NUM_OF_AXIS = 3;

   private boolean hideBar = false;
   private boolean hideNormalText = false;
   private boolean hideCalibratingText = true;
   private boolean enable = true;

   private AccelAxis [] axis = new AccelAxis[NUM_OF_AXIS];
   
   private SerialNotifier serialNotifier;
   
   public AccelMgr(){
      for (int i = 0; i < axis.length; ++i) {
         axis[i] = new AccelAxis((Character.toString((char)(i+120))));
         axis[i].setBarDisplayProperties(width*(i+1+SGManager.NUM_OF_GAUGES+1)*0.04f,
                                         height*0.67f, 20);
         axis[i].setTextDisplayPropertiesForAxisName(width*(i+1+SGManager.NUM_OF_GAUGES+1)*0.04f-3,
                                                     // height*((i%2==1)?0.81:0.79),
                                                     height*0.79f,
                                                     12);
         axis[i].setTextDisplayPropertiesForDifferenceVal(width*(i+1+SGManager.NUM_OF_GAUGES+1)*0.04f-5,
                                                          // height*((i%2==1)?0.84:0.82),
                                                          height*0.82f,
                                                          8);
         axis[i].setTextDisplayPropertiesForNewVal(width*(i+1+SGManager.NUM_OF_GAUGES+1)*0.04f-5,
                                                   // height*((i%2==1)?0.87:0.85),
                                                   height*0.85f,
                                                   8);
      }
   }

   public float getOneAxisCaliVal(int idx){
      return axis[idx].getCalibrationValue();
   }

   public float getOneAxisCaliVal(char idx){
      return getOneAxisCaliVal((int)idx-120);
   }

   public float getOneAxisNewVal(int idx){
      return enable ? axis[idx].getNewValue() : 0.0f;
   }

   public float getOneAxisNewVal(char idx){
      return getOneAxisNewVal((int)idx-120);
   }

   public float getOneAxisDifference(int idx){
      return enable ? axis[idx].getDifferenceVal() : 0.0f;
   }

   public float getOneAxisDifference(char idx){
      return getOneAxisDifference((int)idx-120);
   }

   public void calibrateUsingNewValues(){
      for (int i = 0; i < axis.length; ++i) {
         axis[i].calibrateUsingNewValue();
      }
   }

   public void draw(){
      for (int i = 0; i < axis.length; ++i) {
         if (!hideBar && enable) axis[i].drawBar();
         if (!hideNormalText) axis[i].drawText(); 
      }
   }

   public void performKeyPress(char k){
      switch (k) {
         case TAB:
            if (uiHidden) {
               changeDisplay(UIInteractionMgr.RADIO_HIDE_ITEMS);
            } else {
               changeDisplay(UIInteractionMgr.RADIO_SHOW_BAR_ITEM);
            }
            break;
      }
   }

   @Override
   public void registerToSerialNotifier(SerialNotifier notifier){
      notifier.registerForSerialListener(this);
      serialNotifier = notifier;
   }

   @Override
   public void removeToSerialNotifier(SerialNotifier notifier){
      notifier.removeSerialListener(this);
      serialNotifier = null;
   }

   @Override
   public void updateDiscoveredSerialPorts(String [] portNames){}

   @Override
   public void updateAnalogVals(float [] values){
      for (int i = 0; i < axis.length; ++i) {
         axis[i].setNewValue(values[i+SGManager.NUM_OF_GAUGES]);
      }
   }

   @Override
   public void updateCaliVals(float [] values){
      hideCalibratingText = true;
      for (int i = 0; i < axis.length; ++i) {
         axis[i].setCalibrationValue(values[i+SGManager.NUM_OF_GAUGES]);
      }
   }

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
   public void controlEvent(ControlEvent theEvent){
      if (millis()<1000) return;
      
      if (theEvent.getName().equals(UIInteractionMgr.RADIO_DISPLAY)) {
         changeDisplay(theEvent.getValue());
      } else if (theEvent.getName().equals(UIInteractionMgr.CALIBRATE_ACCEL)){
         calibrateUsingNewValues();
      } else if (theEvent.getName().equals(UIInteractionMgr.ENABLE_ACCEL)){
         enable = (theEvent.getValue() == 1.0f) ? true : false;
      }
   }

   private void changeDisplay(float eventValue){
      if (eventValue == UIInteractionMgr.RADIO_SHOW_BAR_ITEM) {
         hideNormalText = false;
         hideBar = false;
      } else if (eventValue == UIInteractionMgr.RADIO_HIDE_ITEMS) {
         hideNormalText = true;
         hideBar = true;
      } else {
         hideNormalText = false;
         hideBar = true;
      }
   }
}
public class Animation {
  PImage[] images;
  int imageCount;
  int frame;
  
  Animation(String imagePrefix, int count) {
    frame = 0;
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = imagePrefix + nf(i, 4) + ".gif";
      images[i] = loadImage(filename);
    }
  }

  public void display(float xpos, float ypos) {
    frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos);
  }
  
  public int getWidth() {
    return images[0].width;
  }
}
/**
GRT
Version: 1.2
Author: Nick Gillian

Info: This class acts as an interface to the GRT GUI. It sends data and commands to the GUI via Open Sound Control (OSC). To use this
code you should download and install the Processing OSC library from: http://www.sojamo.de/libraries/oscP5/
*/
   
   
   
class GRT{
  
  private OscP5 oscP5;
  private NetAddress grtBackend;

  private boolean initialized;
  private boolean record;
  private int pipelineMode;
  private int numDimensions;
  private int targetVectorSize;
  private int trainingClassLabel;
  private int predictedClassLabel;
  
  private int grtPipelineMode;
  private boolean grtPipelineTrained;
  private boolean grtRecording;
  private int grtNumTrainingSamples;
  private int grtNumClassesInTrainingData;
  private String grtInfoText;
  private String grtVersion;
   
  private float maximumLikelihood;
  private float[] preProcessedData;
  private float[] featureExtractionData;
  private float[] classLikelihoods;
  private float[] classDistances;
  private float[] regressionData;
  private float[] targetVector;
  private int[] classLabels;
  
  //Pipeline Modes
  public static final int CLASSIFICATION_MODE = 0;
  public static final int REGRESSION_MODE = 1;
  public static final int TIMESERIES_MODE = 2;
  
  //Classifier Types
  public static final int ANBC = 0;
  public static final int ADABOOST = 1;
  public static final int GMM = 2;
  public static final int KNN = 3;
  public static final int MINDIST = 4;
  public static final int SOFTMAX = 5;
  public static final int SVM = 6;
  
  /**
   Default constructor
  */
  GRT(){
    initialized = false;
  }
  
  /**
   Main constructor used to initialize the instance.
   
   @param int pipelineMode: sets the mode that the pipeline will run in. This should be a valid pipeline mode, either CLASSIFICATION_MODE, REGRESSION_MODE, or TIMESERIES_MODE
   @param int numInputs: sets the size of your data vector, this is the data that you will send to the GRT GUI
   @param int numOutputs: this parameter is only used for REGRESSION_MODE, in which case it sets the target vector size
   @param String grtIPAddress: the IP address of the machine running the GRT GUI. If it is running on the same machine as this Processing Sketch this should be "127.0.0.1"
   @param int grtPort: the network port that the GRT GUI is listening for connections on. This is set by the OSC Receive Port setting in the GRT GUI
   @param int listenerPort: the network port that this Processing Sketch should listen for OSC messages from the GRT GUI
   @param bool sendSetupMessage: if true then the Setup message will be sent to the GRT GUI, if false then the message will not be sent
  */
  GRT(int pipelineMode,int numInputs,int numOutputs,String grtIPAddress,int grtPort,int listenerPort, boolean sendSetupMessage){
    initialized = init( pipelineMode, numInputs, numOutputs, grtIPAddress, grtPort, listenerPort, sendSetupMessage );
  }
  
  /**
   This function initalizes the GRT backend. It will set up any memory required for running the GRT backend and will then send a Setup message to the GRT GUI via OSC (if the
   sendSetupMessage parameter is true).
   
   @param int pipelineMode: sets the mode that the pipeline will run in. This should be a valid pipeline mode, either CLASSIFICATION_MODE, REGRESSION_MODE, or TIMESERIES_MODE
   @param int numInputs: sets the size of your data vector, this is the data that you will send to the GRT GUI
   @param int numOutputs: this parameter is only used for REGRESSION_MODE, in which case it sets the target vector size
   @param String grtIPAddress: the IP address of the machine running the GRT GUI. If it is running on the same machine as this Processing Sketch this should be "127.0.0.1"
   @param int grtPort: the network port that the GRT GUI is listening for connections on. This is set by the OSC Receive Port setting in the GRT GUI
   @param int listenerPort: the network port that this Processing Sketch should listen for OSC messages from the GRT GUI
   @param boolean sendSetupMessage: if true then the Setup message will be sent to the GRT GUI, if false then the message will not be sent
   @return returns true if the initalization was successful, false otherwise
  */
  public boolean init(int pipelineMode,int numInputs,int numOutputs,String grtIPAddress,int grtPort,int listenerPort, boolean sendSetupMessage){
    
    initialized = false;
    
    if( pipelineMode != CLASSIFICATION_MODE && pipelineMode != REGRESSION_MODE && pipelineMode != TIMESERIES_MODE ){
      return false;
    }
    
    this.pipelineMode = pipelineMode;
    this.numDimensions = numInputs;
    
    if( pipelineMode == REGRESSION_MODE ) targetVectorSize = numOutputs;
    else targetVectorSize = 0;
    
    //Init the grt status values, this will be updated each time we get a status message from the GRT
    grtPipelineMode = 0;
    grtPipelineTrained = false;
    grtRecording = false;
    grtNumTrainingSamples = 0;
    grtNumClassesInTrainingData = 0;
    grtInfoText = "";
    
    //Init the prediction data, this will be resized when any new prediction data is received
    preProcessedData = new float[ numDimensions ];
    featureExtractionData = new float[ 1 ]; 
    classLikelihoods = new float[ 1 ];
    classDistances = new float[ 1];
    regressionData = new float[ targetVectorSize ];
    targetVector = new float[ targetVectorSize ];
    classLabels = new int[ 1 ];
    
    trainingClassLabel = 1;
    record = false;
    predictedClassLabel = 0;
    maximumLikelihood = 0;
    
    //Setup the I/O networks
    oscP5 = new OscP5(this,listenerPort);
    grtBackend = new NetAddress(grtIPAddress,grtPort);
    
    //Flag that the instance is now initialized
    initialized = true;
  
    //Send the setup message
    if( sendSetupMessage ){
      OscMessage msg = new OscMessage("/Setup");
      msg.add( pipelineMode );
      msg.add( numInputs );
      msg.add( numOutputs );
      oscP5.send(msg, grtBackend); 
      
      //Send the current training class label or regression target
      switch( pipelineMode ){
        case  CLASSIFICATION_MODE:
        case TIMESERIES_MODE:
          setTrainingClassLabel( trainingClassLabel );
        break;
        case REGRESSION_MODE:
          sendTargetVector( targetVector );
        break;
      }
    }
    
    return true;
  }
  
  /**
   This function sends the data to the GRT GUI. The size of the data vector must match the numDimensions parameter.
   
   You need to initalize the GRT backend before you use this function.
   
   @param float[] data: the data you want to send to the GRT GUI
   @return returns true if the data was sent successful, false otherwise
  */
  public boolean sendData(float[] data){
    
    if( !initialized ) return false;
    
    if( data.length != numDimensions ) return false;
      
    OscMessage msg = new OscMessage("/Data");
      
    for(int i=0; i<numDimensions; i++){
      msg.add( data[i] );
    }
    oscP5.send(msg, grtBackend); 
      
    return true;
  }
  
  /**
   This function sends the target data to the GRT GUI. The size of the target vector must match the targetVectorSize parameter.
   
   This function is only useful if you have the GRT in REGRESSION_MODE.
   You need to initalize the GRT backend before you use this function.
   
   @param float[] targetVector: the targetVector you want to send to the GRT GUI
   @return returns true if the targetVector was sent successful, false otherwise
  */
  public boolean sendTargetVector(float[] targetVector){
    
    if( !initialized ) return false;
    
    if( targetVector.length != targetVectorSize ) return false;
    
    OscMessage msg = new OscMessage("/TargetVector");
    for(int i=0; i<targetVectorSize; i++){
      msg.add( targetVector[i] );
    }
    oscP5.send(msg, grtBackend); 
    
    //Save the target vector so we can draw it
    this.targetVector = targetVector;
    
    return true;
  }

  /**
   This function increments the current training class label and then sends the updated training class label to the GRT GUI.
   
   This function is only useful if you have the GRT in CLASSIFICATION_MODE or TIMESERIES_MODE.
   You need to initalize the GRT backend before you use this function.
   
   @return returns true if the targetVector was sent successful, false otherwise
  */
  public boolean incrementTrainingClassLabel(){
    
    if( !initialized ) return false;
    
    trainingClassLabel++;
    
    OscMessage msg = new OscMessage("/TrainingClassLabel");
    msg.add( trainingClassLabel );
    oscP5.send(msg, grtBackend); 
      
    return true;
  }
  
  /**
   This function decrements the current training class label and then sends the updated training class label to the GRT GUI.
   
   The training class label can not be less than 1.
   
   This function is only useful if you have the GRT in CLASSIFICATION_MODE or TIMESERIES_MODE.
   You need to initalize the GRT backend before you use this function.
   
   @return returns true if the targetVector was sent successful, false otherwise
  */
  public boolean decrementTrainingClassLabel(){
    
    if( !initialized ) return false;
    
    if( trainingClassLabel <= 1 ) return false;
    trainingClassLabel--;
    
    OscMessage msg = new OscMessage("/TrainingClassLabel");
    msg.add( trainingClassLabel );
    oscP5.send(msg, grtBackend); 
      
    return true;
  }
  
  /**
   This function sets the current training class label and then sends the updated training class label to the GRT GUI.
   
   The training class label can not be less than 1.
   
   This function is only useful if you have the GRT in CLASSIFICATION_MODE or TIMESERIES_MODE.
   You need to initalize the GRT backend before you use this function.
   
   @return returns true if the targetVector was sent successful, false otherwise
  */
  public boolean setTrainingClassLabel(int trainingClassLabel){
    
    if( !initialized ) return false;
    
    if( trainingClassLabel <= 1 ) return false;
    
    this.trainingClassLabel = trainingClassLabel;
    
    OscMessage msg = new OscMessage("/TrainingClassLabel");
    msg.add( trainingClassLabel );
    oscP5.send(msg, grtBackend); 
      
    return true;
  }
  
  /**
   This function sends a start recording message to the GRT GUI.
   
   You need to initalize the GRT backend before you use this function.
   
   @return returns true if the start recording message was sent successful, false otherwise
  */
  public boolean startRecording(){
    
    if( !initialized ) return false;
    
    record = true;
    OscMessage msg = new OscMessage("/Record");
    msg.add( 1 );
    oscP5.send(msg, grtBackend); 
      
    return true; 
  }
  
  /**
   This function sends a stop recording message to the GRT GUI.
   
   You need to initalize the GRT backend before you use this function.
   
   @return returns true if the stop recording message was sent successful, false otherwise
  */
  public boolean stopRecording(){
    
    if( !initialized ) return false;
    
    record = false;
    OscMessage msg = new OscMessage("/Record");
    msg.add( 0 );
    oscP5.send(msg, grtBackend); 
      
    return true; 
  }
  
  /**
   This function sends a train message to the GRT GUI.
   
   You need to initalize the GRT backend before you use this function.
   
   @return returns true if the train message was sent successful, false otherwise
  */
  public boolean startTraining(){
    
    if( !initialized ) return false;
    OscMessage msg = new OscMessage("/Train");
    msg.add( 1 );
    oscP5.send(msg, grtBackend); 
      
    return true;
  }
  
  /**
   This function sends a message to the GRT GUI indicating that it should save the current training dataset to a file.
   
   You need to initalize the GRT backend before you use this function.
   
   @param String filename: the name of the file you want to save the training data to
   @return returns true if the SaveTrainingDatasetToFile message was sent successful, false otherwise
  */
  public boolean saveTrainingDatasetToFile( String filename ){
    
    if( !initialized ) return false;
    
    OscMessage msg = new OscMessage("/SaveTrainingDatasetToFile");
    msg.add( filename );
    oscP5.send(msg, grtBackend);
    
    return true;
  }
  
  /**
   This function sends a message to the GRT GUI indicating that it should load a training dataset from a file.
   
   You need to initalize the GRT backend before you use this function.
   
   @param String filename: the name of the file you want to load the training data from
   @return returns true if the loadTrainingDatasetFromFile message was sent successful, false otherwise
  */
  public boolean loadTrainingDatasetFromFile( String filename ){
    
      if( !initialized ) return false;
     
      OscMessage msg = new OscMessage("/LoadTrainingDatasetFromFile");
      msg.add( filename );
      oscP5.send(msg, grtBackend);
      
      return true;
  }
  
  /**
   This function sends a message to the GRT GUI indicating that it should clear any training data.
   
   You need to initalize the GRT backend before you use this function.
   
   @return returns true if the ClearTrainingDataset message was sent successful, false otherwise
  */
  public boolean clearTrainingDataset( ){
    
      if( !initialized ) return false;
     
      OscMessage msg = new OscMessage("/ClearTrainingDataset");
      oscP5.send(msg, grtBackend);
      
      return true;
  }
  
  /**
   This function sends a message to the GRT GUI to set a specific classifier. You can also use this function to select if
   the classifier should use scaling or null rejection and to update the null rejection threshold.
   
   Note that calling this function will automatically update your classifier, so you will need to retrain any classification
   model after doing this before you can use the new classifier.
   
   You need to initalize the GRT backend before you use this function.
   
   @param int classifierType: this should be one of the classifier types (see the list of defined classifier types at the top of this class)
   @param boolean useScaling: if true, then the GRT will automatically scale your data
   @param boolean useNullRejection: if true, then the GRT will automatically try to reject new data that has a low probability
   @param double nullRejectionThreshold: this value controls the null rejection threshold. See http://www.nickgillian.com/wiki/pmwiki.php/GRT/AutomaticGestureSpotting for more information.
   @return returns true if the setClassifier message was sent successful, false otherwise
  */
  public boolean setClassifier(int classifierType,boolean useScaling,boolean useNullRejection,double nullRejectionThreshold ){
    
      if( !initialized ) return false;
      
      if( classifierType < ANBC || classifierType > SVM ) return false;
      
      if( nullRejectionThreshold < 0 ) return false;
      
      OscMessage msg = new OscMessage("/SetClassifier");
      msg.add( classifierType );
      msg.add( useScaling ? 1 : 0 );
      msg.add( useNullRejection ? 1 : 0 );
      msg.add( nullRejectionThreshold );
      oscP5.send(msg, grtBackend);
      
      return true;
  }
  
  /**
   This function draws some useful info to the main processing draw window. 
   
   @param int x: the x position that the info text will be drawn at
   @param int y: the y position that the info text will be drawn at
   @return returns true if the info text was drawn successful, false otherwise
  */
  public boolean drawInfoText( int x, int y ){
    
      if( !initialized ) return false;
      
      //Draw the info text
      stroke( 255 ); 
//      textFont(font, 12);
    
      //Draw the status
      int spacer = 15;
  
      //Draw the pipeline mode
      switch( getPipelineMode() ){
        case  CLASSIFICATION_MODE:
          text("Pipeline Mode: CLASSIFICATION", x, y);
        break;
        case  REGRESSION_MODE:
          text("Pipeline Mode: REGRESSION", x, y);
        break;
        case  TIMESERIES_MODE:
          text("Pipeline Mode: TIMESERIES", x, y);
        break;
      }
      y += spacer*2;
      
      
      //Draw the status info
      text("-----------GRT Status Info-----------", x, y); 
      y += spacer;
      switch( grtPipelineMode ){
        case  CLASSIFICATION_MODE:
          text("GRT Pipeline Mode: CLASSIFICATION", x, y);
        break;
        case  REGRESSION_MODE:
          text("GRT Pipeline Mode: REGRESSION", x, y);
        break;
        case  TIMESERIES_MODE:
          text("GRT Pipeline Mode: TIMESERIES", x, y);
        break;
      }
      y += spacer;
      text("Pipeline Trained: " + (grtPipelineTrained==true?"YES":"NO"), x, y);
      y += spacer;
      text("GRT Message Log: " + grtInfoText, x, y);
      y += spacer;
      
    
      y += spacer*2;
      //Draw the training info
      text("-----------Training Info-----------", x, y); 
  
      y += spacer;
      text("Recording: " + (getRecordingStatus()==true?"YES":"NO"), x, y);
  
      y += spacer;
      switch( getPipelineMode() ){
        case  CLASSIFICATION_MODE:
          text("TrainingClassLabel: " + getTrainingClassLabel(), x, y);
        break;
        case  REGRESSION_MODE:
          String targetVectorText = "TargetVector: ";
          for(int i=0; i<targetVector.length; i++)
            targetVectorText += " " + targetVector[i];
          text(targetVectorText, x, y);
        break;
        case  TIMESERIES_MODE:
        break;
      }
      y += spacer;
      text("NumTrainingSamples: " + grtNumTrainingSamples, x, y);
      
      //Draw the prediction info
      y += spacer*2;
      text("-----------Prediction Info-----------", x, y); 
      
      //Draw the prediction data
      y += spacer;
      
      String regressionResultsText;
      float[] regressionResults;
      switch( getPipelineMode() ){
        case  CLASSIFICATION_MODE:
          text("PredictedClassLabel: " + getPredictedClassLabel(), x, y);
          y += spacer;
          
          text("MaximumLikelihood: " + getMaximumLikelihood(), x, y);
          y += spacer;
          
          String classLikelihoodsText = "ClassLikelihoods: ";
          for(int i=0; i<classLikelihoods.length; i++)
            classLikelihoodsText += "    " + (classLikelihoods[i]>1.0e-5f?classLikelihoods[i]:0);
          text(classLikelihoodsText, x, y);
          y += spacer;
          
          String classDistancesText = "ClassDistances: ";
          for(int i=0; i<classDistances.length; i++)
            classDistancesText += "    " + classDistances[i];
          text(classDistancesText, x, y);
          y += spacer;
          
        break;
//        case  REGRESSION_MODE:
//          regressionResults = grt.getRegressionData();
//          regressionResultsText = "PredictedRegressionData: ";
//          if( regressionResults.length > 0 ){
//             for(int i=0; i<regressionResults.length; i++)
//               regressionResultsText += regressionResults[i] + " ";
//          }
//          text(regressionResultsText, x, y);
//          y += spacer;
//        break;
        case  TIMESERIES_MODE:
        break;
      }
     
      return true;
  }
  
  /**
   Returns if the instance has been initialized.
   
   @return returns true if the instance has been initialized, false otherwise
  */
  public boolean getInitialized(){
    return initialized;
  }
  
  /**
   Returns if a start recording message has been sent to the GRT GUI.
   
   @return returns true if a start recording message has been sent to the GRT GUI, false otherwise
  */
  public boolean getRecordingStatus(){
    return record;
  }
  
  /**
   @return returns the current pipelineMode
  */
  public int getPipelineMode(){
    return pipelineMode;
  }
  
  /**
   @return returns the current trainingClassLabel
  */
  public int getTrainingClassLabel(){
    return trainingClassLabel; 
  }
  
  /**
   @return returns the most recent predictedClassLabel, received from the GRT GUI
  */
  public int getPredictedClassLabel(){
    return predictedClassLabel;
  }
  
  /**
   @return returns the number of classes in the training data, received from the GRT GUI
  */
  public int getNumClassesInTrainingData(){
    return grtNumClassesInTrainingData; 
  }
  
  /**
   @return returns the most recent maximumLikelihood, received from the GRT GUI
  */
  public double getMaximumLikelihood(){
    return maximumLikelihood; 
  }
  
  /**
   @return returns the most recent preProcessedData, received from the GRT GUI
  */
  public float[] getPreProcessedData(){
    return preProcessedData; 
  }
  
  /**
   @return returns the most recent featureExtractionData, received from the GRT GUI
  */
  public float[] getFeatureExtractionData(){
    return featureExtractionData; 
  }
  
  /**
   @return returns the most recent classLikelihoods, received from the GRT GUI
  */
  public float[] getClassLikelihoods(){
    return classLikelihoods; 
  }
  
  /**
   @return returns the most recent classDistances, received from the GRT GUI
  */
  public float[] getClassDistances(){
    return classDistances; 
  }
  
  /**
   @return returns the most recent regressionData, received from the GRT GUI
  */
  public float[] getRegressionData(){
    return regressionData; 
  }
  
  /**
   @return returns the most recent classLabels, received from the GRT GUI
  */
  public int[] getClassLabels(){
    return classLabels; 
  }
  
  /**
   This function is called anytime a new OSC message is received. It will then try and parse the message.
  */
  public void oscEvent(OscMessage theOscMessage) {
  
    if( parseMessage( theOscMessage ) ) return;
 
  }
  
  /**
   This function parses OSC messages from the GRT GUI. 
   
   @param OscMessage theOscMessage: the osc message to parse
   @return returns true if the message was successfully parsed, false otherwise
  */
  public boolean parseMessage(OscMessage theOscMessage) {
    
    if( theOscMessage.checkAddrPattern("/Status")==true) {
      grtPipelineMode = theOscMessage.get(0).intValue();
      grtPipelineTrained = theOscMessage.get(1).intValue() == 1 ? true : false;
      grtRecording = theOscMessage.get(2).intValue() == 1 ? true : false;
      grtNumTrainingSamples = theOscMessage.get(3).intValue();
      grtNumClassesInTrainingData = theOscMessage.get(4).intValue();
      grtInfoText = theOscMessage.get(5).stringValue();
      grtVersion = theOscMessage.get(6).stringValue();
      return true;
    }
    
    if(theOscMessage.checkAddrPattern("/PreProcessedData")==true) {
      int N = theOscMessage.get(0).intValue();
      if( preProcessedData.length != N ){
        preProcessedData = new float[N]; 
      }
      for(int i=0; i<N; i++){
        preProcessedData[i] =  theOscMessage.get(i+1).floatValue();
      }
      return true;
    }
    
    if(theOscMessage.checkAddrPattern("/FeatureExtractionData")==true) {
      int N = theOscMessage.get(0).intValue();
      if( featureExtractionData.length != N ){
        featureExtractionData = new float[N]; 
      }
      for(int i=0; i<N; i++){
        featureExtractionData[i] =  theOscMessage.get(i+1).floatValue();
      }
      return true;
    }
    
    if(theOscMessage.checkAddrPattern("/Prediction")==true) {
      if(theOscMessage.checkTypetag("if")) {
        predictedClassLabel = theOscMessage.get(0).intValue();
        maximumLikelihood = theOscMessage.get(1).floatValue();
        return true;
      }   
    }
    
    if(theOscMessage.checkAddrPattern("/ClassLikelihoods")==true) {
        int N = theOscMessage.get(0).intValue();
        if( classLikelihoods.length != N ) classLikelihoods = new float[N];
        
        for(int i=0; i<N; i++){
          classLikelihoods[i] = theOscMessage.get(1+i).floatValue();
        }
        return true;
    }
    
    if(theOscMessage.checkAddrPattern("/ClassDistances")==true) {
        int N = theOscMessage.get(0).intValue();
        if( classDistances.length != N ) classDistances = new float[N];
        
        for(int i=0; i<N; i++){
          classDistances[i] = theOscMessage.get(1+i).floatValue();
        }
        return true;
    }
    
    if(theOscMessage.checkAddrPattern("/ClassLabels")==true) {
      int N = theOscMessage.get(0).intValue();
      if( classLabels.length != N ) classLabels = new int[N]; 

      for(int i=0; i<N; i++){
        classLabels[i] = theOscMessage.get(i+1).intValue();
      }
      return true;
    }
    
     if(theOscMessage.checkAddrPattern("/RegressionData")==true) {
        int N = theOscMessage.get(0).intValue();
        if( regressionData.length != N ) regressionData = new float[N];
        for(int i=0; i<N; i++){
          regressionData[i] = theOscMessage.get(1+i).floatValue();
        }
        return true;
    }
    
    return false;
 
  }

};
public interface GRTListener{
   public void registerToGRTNotifier(GRTNotifier notifier);
   public void removeToGRTNotifier(GRTNotifier notifier);

   public void updateGRTResults(int label, float likelihood);
}


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
         grt.drawInfoText(floor(width*0.72f),20);
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
      text((char)(grt.getPredictedClassLabel()+96),width*0.4f,height*0.2f);

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
public interface GRTNotifier{
   public void registerForGRTListener(GRTListener listener);
   public void removeGRTListener(GRTListener listener);

   public void notifyAllWithGRTResults(int label, float likelihood);
}
public class RobotControl implements GRTListener, ControlListener{
   final static int SERIAL_PORT_BAUD_RATE = 38400;
   final static int SERIAL_PORT_NUM = 6;

   final static float likelihoodThreshold = 0.7f;

   boolean sendEnable = false;

   Serial robotPort;
   PApplet mainClass; 
    
   public RobotControl(PApplet mainClass){
      this.mainClass = mainClass;
   }
  
   private void connectToSerial(){
      // Setup serial port I/O
      println("AVAILABLE SERIAL PORTS:");
      println(Serial.list());
      String portName = Serial.list()[SERIAL_PORT_NUM];
      connectToSerial(portName);
   }

   private void connectToSerial(int portNumber){
      String portName = Serial.list()[portNumber];
      connectToSerial(portName);
   }

   private void connectToSerial(String portName){
      println();
      println("LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
      println("  -> Using port : " + portName);
      disconnectSerial();

      try {
         robotPort = new Serial(mainClass, portName, SERIAL_PORT_BAUD_RATE);
         robotPort.bufferUntil(10);    //newline
      } catch (Exception e) {
         println("connectToSerial : " + e.getMessage());
      }
   }

   private void disconnectSerial(){
      try {
         robotPort.clear();
         robotPort.stop();
      } catch (Exception e) {
         println("disconnectSerial : " + e.getMessage());
      }
   }

   public void sendToRobot(String str){
     try{ 
       robotPort.write(str);
     }
     catch(Exception e) {
       println(e.getMessage());
     }
   }

   public void performKeyPress(char k){
      sendToRobot(String.valueOf(k));
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
      if (likelihood > likelihoodThreshold && sendEnable) {
         sendToRobot(String.valueOf((char)(label+96)));
      }
   }

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (millis() < 1000) return;

      if (theEvent.getName().equals(UIInteractionMgr.ENABLE_SIGNAL_TO_ROBOT)) {
         sendEnable = (theEvent.getValue() == 1.0f)? true : false;
      } else if (theEvent.getName().equals(UIInteractionMgr.DROPDOWN_ROBOT_SERIAL_LIST)){
         connectToSerial((int)(theEvent.getValue()));
      }
   }
}
public class SGManager implements ControlListener, SerialListener{
   
   public final static int NUM_OF_GAUGES = 9;
   
   private boolean hideBar = false;
   private boolean hideNormalText = false;
   private boolean hideCalibratingText = true;

   private StrainGauge [] gauges = new StrainGauge[NUM_OF_GAUGES];

   private SerialNotifier serialNotifier;

   public SGManager(){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i] = new StrainGauge(i);
         println("width = " + width);
         gauges[i].setBarDisplayProperties(width*(i+1)*0.04f,
                                           height*0.67f, 20);
         gauges[i].setTextDisplayPropertiesForGaugeIdx(width*(i+1)*0.04f-3,
                                                       // height*((i%2==1)?0.81:0.79),
                                                       height*0.79f,
                                                       12);
         gauges[i].setTextDisplayPropertiesForElong(width*(i+1)*0.04f-5,
                                                    // height*((i%2==1)?0.84:0.82),
                                                    height*0.82f,
                                                    12);
         gauges[i].setTextDisplayPropertiesForAnalogVal(width*(i+1)*0.04f-5,
                                                        // height*((i%2==1)?0.87:0.85),
                                                        height*0.85f,
                                                        12);
      }
   }

   public float getOneCaliValForGauges(int index){
      return gauges[index].getCalibrationValue();
   }

   public float [] getAnalogValsOfGauges(){
      float[] analogVals = new float[gauges.length];
      for (int i = 0; i < gauges.length; ++i) {
         analogVals[i] = gauges[i].getNewValue();
      }
      return analogVals;
   }

   public float getOneAnalogValOfGauges(int index){
      return gauges[index].getNewValue();
   }

   public float [] getElongationValsOfGauges(){
      float [] elongationVals = new float[gauges.length];
      for (int i = 0; i < gauges.length; ++i) {
         elongationVals[i] = gauges[i].getElongationValue();
      }
      return elongationVals;
   }

   public float getOneElongationValsOfGauges(int index){
      return gauges[index].getElongationValue();
   }

   public float [] getOneBarBaseCenterOfGauges(int index){
      return gauges[index].getBarBaseCenter();
   }

   public void draw(){
      for (int i = 0; i < gauges.length; i++) {
         if (!hideBar)  gauges[i].drawBar();
         if (!hideNormalText) gauges[i].drawText();
         if (!hideCalibratingText) {
            fill(50, 100, 255, 255);
            textSize(15);
            text("Calibrating...", width*0.04f, height*0.7f-100);
            gauges[i].drawCalibratingText();
         }
      }
   }

   public void performKeyPress(char k){
      switch (k) {
         case TAB:
            if (uiHidden) {
               changeDisplay(UIInteractionMgr.RADIO_HIDE_ITEMS);
            } else {
               changeDisplay(UIInteractionMgr.RADIO_SHOW_BAR_ITEM);
            }
            break;
      }
   }

   @Override
   public void registerToSerialNotifier(SerialNotifier notifier){
      notifier.registerForSerialListener(this);
      serialNotifier = notifier;
   }

   @Override
   public void removeToSerialNotifier(SerialNotifier notifier){
      notifier.removeSerialListener(this);
      serialNotifier = null;
   }
   
   @Override
   public void updateDiscoveredSerialPorts(String [] portNames){}

   @Override
   public void updateAnalogVals(float [] values){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i].setNewValue(values[i]);
      }
   }

   @Override
   public void updateCaliVals(float [] values){
      hideCalibratingText = true;
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i].setCalibrationValue(values[i]);
      }
   }

   @Override
   public void updateTargetAnalogValsMinAmp(float [] values){}
   @Override
   public void updateTargetAnalogValsWithAmp(float [] values){}
   @Override
   public void updateBridgePotPosVals(float [] values){}
   @Override
   public void updateAmpPotPosVals(float [] values){}
   @Override
   public void updateCalibratingValsMinAmp(float [] values){
      hideCalibratingText = hideBar;
      for (int i = 0; i < NUM_OF_GAUGES; ++i) {
         gauges[i].setCalibratingValue(values[i]);
      }
   }
   @Override
   public void updateCalibratingValsWithAmp(float [] values){
      hideCalibratingText = hideBar;
      for (int i = 0; i < NUM_OF_GAUGES; ++i) {
         gauges[i].setCalibratingValue(values[i]);
      }
   }

   @Override
   public void updateReceiveRecordSignal(){}

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (millis()<1000) return;
      
      if (theEvent.getName().equals(UIInteractionMgr.RADIO_DISPLAY)) {
         changeDisplay(theEvent.getValue());
      } else if (theEvent.getName().contains(UIInteractionMgr.ENABLE_STRAIN_GAUGE)){
         enableOrDisableStrainGauge(theEvent,UIInteractionMgr.ENABLE_STRAIN_GAUGE);
      }
   }

   private void changeDisplay(float eventValue){
      if (eventValue == UIInteractionMgr.RADIO_SHOW_BAR_ITEM) {
         hideNormalText = false;
         hideBar = false;
      } else if (eventValue == UIInteractionMgr.RADIO_HIDE_ITEMS) {
         hideNormalText = true;
         hideBar = true;
      } else {
         hideNormalText = false;
         hideBar = true;
      }
   }

   private void enableOrDisableStrainGauge(ControlEvent theEvent, String splitStr){
      String [] nameSplit = theEvent.getName().split(splitStr);

      int index = Integer.parseInt(nameSplit[1]);
      gauges[index].enable = (theEvent.getValue() == 1.0f) ? true : false;
   }
}
public interface SerialListener{
   public void registerToSerialNotifier(SerialNotifier notifier);
   public void removeToSerialNotifier(SerialNotifier notifier);
   
   public void updateDiscoveredSerialPorts(String [] portNames);

   public void updateAnalogVals(float [] values);
   public void updateCaliVals(float [] values);
   public void updateTargetAnalogValsMinAmp(float [] values);
   public void updateTargetAnalogValsWithAmp(float [] values);
   public void updateBridgePotPosVals(float [] values);
   public void updateAmpPotPosVals(float [] values);
   public void updateCalibratingValsMinAmp(float [] values);
   public void updateCalibratingValsWithAmp(float [] values);
   public void updateReceiveRecordSignal();
}




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

   ArrayList<SerialListener> serialListeners = new ArrayList<SerialListener>();

   public SerialManager(PApplet mainClass){
      this.mainClass = mainClass;
   }

   private void connectToSerial(){
      // Setup serial port I/O
      println("AVAILABLE SERIAL PORTS:");
      println(Serial.list());
      String portName = Serial.list()[SERIAL_PORT_NUM];
      connectToSerial(portName);
   }

   private void connectToSerial(int portNumber){
      String portName = Serial.list()[portNumber];
      connectToSerial(portName);
   }

   private void connectToSerial(String portName){
      println();
      println("LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
      println("  -> Using port : " + portName);
      disconnectSerial();

      try {
         arduinoPort = new Serial(mainClass, portName, SERIAL_PORT_BAUD_RATE);
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
            sendToArduino(Integer.toString(ALL_CALIBRATION_CONST_AMP));
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
public interface SerialNotifier{
   public void registerForSerialListener(SerialListener listener);
   public void removeSerialListener(SerialListener listener);
   
   public void notifyAllWithDiscoveredSerialPorts();

   public void notifyAllWithAnalogVals(float [] values);
   public void notifyAllWithCaliVals(float [] values);
   public void notifyAllWithTargetAnalogValsMinAmp(float [] values);
   public void notifyAllWithTargetAnalogValsWithAmp(float [] values);
   public void notifyAllWithBridgePotPosVals(float [] values);
   public void notifyAllWithAmpPotPosVals(float [] values);
   public void notifyAllWithCalibratingValsMinAmp(float [] values);
   public void notifyAllWithCalibratingValsWithAmp(float [] values);
   public void notifyAllWithReceiveRecordSignal();
}
public class StrainGauge{
   
   //Value data member
   private int gaugeIdx;
   private float calibrationValue;
   private float newValue;
   private float calibratingValue;
   public boolean enable = true;

   //Bar Display data member
   private float barXOrigin;
   private float barYOrigin;
   private float barWidth;
   // private float barHeight;

   private float barElongRatio = 200;

   //Text Display data member
   private float elongTextXOrigin;
   private float elongTextYOrigin;
   private float elongTextSize;
   private float analogValTextXOrigin;
   private float analogValTextYOrigin;
   private float analogValTextSize;
   private float gaugeIdxTextXOrigin;
   private float gaugeIdxTextYOrigin;
   private float gaugeIdxTextSize;

   public StrainGauge(int gaugeIdx){
      this.gaugeIdx = gaugeIdx;
   }

   //Value methods
   public float getNewValue(){
      return enable ? newValue : 0.0f;
   }
   public void setNewValue(float newValue){
      this.newValue = newValue;
   }

   public void setCalibrationValue(float calibrationValue){
      this.calibrationValue = calibrationValue;
   }

   public float getCalibrationValue(){
      return calibrationValue;
   }

   public float getElongationValue(){
      return enable ? (float)newValue/calibrationValue : 0.0f;
   }

   public void setCalibratingValue(float calibratingValue){
      this.calibratingValue = calibratingValue;
   }

   public float getCalibratingValue(){
      return calibratingValue;
   }

   //Bar Display methods
   public void setBarDisplayProperties(float barXOrigin, float barYOrigin,
                                       float barWidth){
      this.barXOrigin = barXOrigin;
      this.barYOrigin = barYOrigin;
      this.barWidth = barWidth;
   }

   public float [] getBarBaseCenter(){
      float [] barOrigin = new float[2];
      barOrigin[0] = barXOrigin + barWidth/2;
      barOrigin[1] = barYOrigin;
      return barOrigin;
   }

   public int getHeatmapRGB(float value){
     float minimum=0.6f;
     float maximum=1.4f;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     int heatmapRGB = color((int)max(0, 255*(ratio - 1)),
                              255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)),
                              (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
   }

   public void drawBar(){
      if (!enable) return;
      float elongRatio = getElongationValue();

      // color stretch = color(4, 79, 111);
      // color compress = color(255, 145, 158);

      fill(getHeatmapRGB(getElongationValue()));
      rect(barXOrigin, barYOrigin, barWidth, (1-elongRatio)*barElongRatio);
   }

   //Text Display methods
   public void setTextDisplayPropertiesForElong(float elongTextXOrigin,
                                                float elongTextYOrigin,
                                                float elongTextSize){
      this.elongTextXOrigin = elongTextXOrigin;
      this.elongTextYOrigin = elongTextYOrigin;
      this.elongTextSize = elongTextSize;
   }

   public void setTextDisplayPropertiesForAnalogVal(float analogValTextXOrigin,
                                                    float analogValTextYOrigin,
                                                    float analogValTextSize){
      this.analogValTextXOrigin = analogValTextXOrigin;
      this.analogValTextYOrigin = analogValTextYOrigin;
      this.analogValTextSize = analogValTextSize;
   }

   public void setTextDisplayPropertiesForGaugeIdx(float gaugeIdxTextXOrigin,
                                                   float gaugeIdxTextYOrigin,
                                                   float gaugeIdxTextSize){
      this.gaugeIdxTextXOrigin = gaugeIdxTextXOrigin;
      this.gaugeIdxTextYOrigin = gaugeIdxTextYOrigin;
      this.gaugeIdxTextSize = gaugeIdxTextSize;
   }

   public void drawText(){
      fill(0, 102, 255);
      textSize(gaugeIdxTextSize);
      text("SG"+(int)gaugeIdx, gaugeIdxTextXOrigin, gaugeIdxTextYOrigin);

      fill(0, 102, 10);
      textSize(enable ? elongTextSize : 7);
      text(enable ? String.format("%.2f",getElongationValue()) : "Disabled",
           elongTextXOrigin,
           elongTextYOrigin);

      fill(150,150,150);
      textSize(analogValTextSize);
      text((int)newValue, analogValTextXOrigin, analogValTextYOrigin);
   }

   public void drawCalibratingText(){
      fill(0,0,30,255);
      textSize(10);
      text((int)calibratingValue, barXOrigin, barYOrigin+20);
   }
}
class Timer {
 
  int savedTime; // When Timer started
  int totalTime; // How long Timer should last
  
  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }
  
  // Starting the timer
  public void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis(); 
  }
  
  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  public boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}


public boolean uiHidden = false;

public class UIInteractionMgr implements ControlListener, SerialListener{
   HandTieArduinoSystemOnProcessingRobotControl mainClass;

   ControlP5 cp5;
   boolean launchComplete = false;

   // RadioButton properties
   RadioButton radioButton;
   DropdownList arduinoPortNamesDropdownList;
   DropdownList robotPortNamesDropdownList;
   public final static String RADIO_DISPLAY = "display";
   public final static float RADIO_HIDE_ITEMS = -1.0f;
   public final static float RADIO_SHOW_BAR_ITEM = 0.0f;
   public final static float RADIO_SHOW_BRIDGE_TARGET_MIN_AMP_ITEM = 1.0f;
   public final static float RADIO_SHOW_AMP_TARGET_CONST_BRIDGE_ITEM = 2.0f;
   public final static float RADIO_SHOW_BRIDGE_TARGET_CONST_AMP_ITEM = 3.0f;
   public final static float RADIO_SHOW_BRIDGE_POT_POS_ITEM = 4.0f;
   public final static float RADIO_SHOW_AMP_POT_POS_ITEM = 5.0f;
   public final static float RADIO_ENABLE_STRAIN_GAUGE_ITEM = 6.0f;

   // sliders
   public final static String SLIDER_BRIDGE_TARGET_MIN_AMP_ALL = "brdg\nmin\namp\nall";
   public final static String SLIDERS_BRIDGE_TARGET_MIN_AMP = "brdg\nmin\namp\n";

   public final static String SLIDER_AMP_TARGET_CONST_BRIDGE_ALL =  "amp\nconst\nbrdg\nall";
   public final static String SLIDERS_AMP_TARGET_CONST_BRIDGE = "amp\nconst\nbrdg\n";

   public final static String SLIDER_BRIDGE_TARGET_CONST_AMP_ALL = "brdg\nconst\namp\nall";
   public final static String SLIDERS_BRIDGE_TARGET_CONST_AMP = "brdg\nconst\namp\n";

   public final static String SLIDER_BRIDGE_POT_ALL = "b_Pot_all";
   public final static String SLIDER_AMP_POT_ALL = "a_Pot_all";
   public final static String SLIDERS_BRIDGE_POT = "b_Pot\n";
   public final static String SLIDERS_AMP_POT = "a_Pot\n";

   // buttons
   public final static String CALIBRATE = "calibrate";
   public final static String CALIBRATE_CONST_AMP = "calibrate (const amp)";
   public final static String CALIBRATE_ACCEL = "calibrate (accel)";

   // toggles
   public final static String ENABLE_STRAIN_GAUGE = "enable\nsg";
   public final static String ENABLE_ACCEL = "enable\nacc";
   public final static String ENABLE_SIGNAL_TO_ROBOT = "send to robot\n(on/off)";

   // dropdown list
   public final static String DROPDOWN_ARDUINO_SERIAL_LIST = "Arduino Serial";
   public final static String DROPDOWN_ROBOT_SERIAL_LIST = "Robot Serial";

   public UIInteractionMgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
      this.mainClass = mainClass;

      cp5 = new ControlP5(mainClass);
      cp5.setColorValue(0);
      cp5.addListener(this);
      cp5.addListener(mainClass.sgManager);
      cp5.addListener(mainClass.serialManager);
      cp5.addListener(mainClass.accelMgr);
      cp5.addListener(mainClass.robotControl);
      createUIForSerial();
   }

   private void createUIForSerial(){
      float [] barOrigin = sgManager.getOneBarBaseCenterOfGauges(0);
      radioButton = cp5.addRadioButton(RADIO_DISPLAY)
                       .setPosition(width*0.1f, height*0.86f)
                       .setItemWidth(20)
                       .setItemHeight(20)
                       .addItem("bar", RADIO_SHOW_BAR_ITEM)
                       .addItem("bridge pot pos", RADIO_SHOW_BRIDGE_POT_POS_ITEM)
                       .addItem("amp pot pos", RADIO_SHOW_AMP_POT_POS_ITEM)
                       .addItem("bridge target (min amp)", RADIO_SHOW_BRIDGE_TARGET_MIN_AMP_ITEM)
                       .addItem("amp target (const bridge)", RADIO_SHOW_AMP_TARGET_CONST_BRIDGE_ITEM)
                       .addItem("bridge target (const amp)", RADIO_SHOW_BRIDGE_TARGET_CONST_AMP_ITEM)
                       .addItem("enable strain gauge", RADIO_ENABLE_STRAIN_GAUGE_ITEM)
                       .setColorLabel(color(0))
                       .activate(0)
                       .setItemsPerRow(4)
                       .setSpacingColumn((int)(width*0.15f))
                    ;

      int i;
      for (i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         barOrigin = sgManager.getOneBarBaseCenterOfGauges(i);
         cp5.addSlider(SLIDERS_BRIDGE_TARGET_MIN_AMP+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,30)
            // .setValue(20)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(31)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;

         cp5.addSlider(SLIDERS_AMP_TARGET_CONST_BRIDGE+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,1000)
            // .setValue(sgManager.getOneCaliValForGauges(i))
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(21)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;

         cp5.addSlider(SLIDERS_BRIDGE_TARGET_CONST_AMP+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,1000)
            // .setValue(255)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(21)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;

         cp5.addSlider(SLIDERS_BRIDGE_POT+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,255)
            // .setValue(255)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(256)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;

         cp5.addSlider(SLIDERS_AMP_POT+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,50)
            // .setValue(255)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(51)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;
         cp5.addToggle(ENABLE_STRAIN_GAUGE+i)
            .setColorLabel(color(0))
            .setBroadcast(false)
            .setValue(1.0f)
            .setPosition(barOrigin[0]-12, barOrigin[1])
            .setSize(20,20)
            .setVisible(false)
            .setBroadcast(true)
         ;
      }

      cp5.addToggle(ENABLE_ACCEL)
         .setColorLabel(color(0))
         .setBroadcast(false)
         .setValue(1.0f)
         .setPosition(barOrigin[0]+57, barOrigin[1])
         .setSize(20,20)
         .setVisible(false)
         .setBroadcast(true)
      ;

      barOrigin = sgManager.getOneBarBaseCenterOfGauges(i-1);
      cp5.addSlider(SLIDER_BRIDGE_TARGET_MIN_AMP_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
         .setSize(10,80)
         .setRange(0,30)
         .setValue(20)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(31)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
         .setBroadcast(true)
      ;
      cp5.addSlider(SLIDER_AMP_TARGET_CONST_BRIDGE_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
         .setSize(10,80)
         .setRange(0,1000)
         .setValue(500)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(21)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
         .setBroadcast(true)
      ;
      cp5.addSlider(SLIDER_BRIDGE_TARGET_CONST_AMP_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
         .setSize(10,80)
         .setRange(0,1000)
         .setValue(500)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(21)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
         .setBroadcast(true)
      ;
      cp5.addSlider(SLIDER_BRIDGE_POT_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
         .setSize(10,80)
         .setRange(0,255)
         // .setValue(20)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(256)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
         .setBroadcast(true)
      ;
      cp5.addSlider(SLIDER_AMP_POT_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
         .setSize(10,80)
         .setRange(0,50)
         // .setValue(20)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(51)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
         .setBroadcast(true)
      ;
      cp5.addButton(CALIBRATE)
         .setBroadcast(false)
         .setValue(0)
         .setPosition(width*0.12f, height*0.94f)
         .setSize(100,20)
         .setBroadcast(true)
      ;
      cp5.addButton(CALIBRATE_CONST_AMP)
         .setBroadcast(false)
         .setValue(0)
         .setPosition(width*0.12f + 120, height*0.94f)
         .setSize(100,20)
         .setBroadcast(true)
      ;
      cp5.addButton(CALIBRATE_ACCEL)
         .setBroadcast(false)
         .setValue(0)
         .setPosition(width*0.12f + 240, height*0.94f)
         .setSize(100,20)
         .setBroadcast(true)
      ;
      cp5.addToggle(ENABLE_SIGNAL_TO_ROBOT)
         .setColorLabel(color(0))
         .setBroadcast(false)
         .setValue(0)
         .setPosition(width*0.85f, height*0.5f)
         .setSize(50,30)
         .setBroadcast(true)
      ;

      arduinoPortNamesDropdownList = cp5.addDropdownList(DROPDOWN_ARDUINO_SERIAL_LIST)
                                        .setPosition(width*0.05f, height*0.07f)
                                        .setSize(200,200)
                                        .setBackgroundColor(color(190))
                                        .setItemHeight(20)
                                    ;
      robotPortNamesDropdownList = cp5.addDropdownList(DROPDOWN_ROBOT_SERIAL_LIST)
                                        .setPosition(width*0.3f, height*0.07f)
                                        .setSize(200,200)
                                        .setBackgroundColor(color(190))
                                        .setItemHeight(20)
                                    ;

      launchComplete = true;
   }

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (!launchComplete)  return;
      println("performControlEvent: " + theEvent.getName());
      println("event value: " + theEvent.getValue());

      if (theEvent.getName().equals(SLIDER_BRIDGE_TARGET_MIN_AMP_ALL)) {
         manualChangeToAllGaugesBridgeTargetMinAmp(theEvent);
      } else if (theEvent.getName().equals(SLIDER_AMP_TARGET_CONST_BRIDGE_ALL)) {
         manualChangeToAllGaugesAmpTargetConstBridge(theEvent);
      } else if (theEvent.getName().equals(SLIDER_BRIDGE_TARGET_CONST_AMP_ALL)){
         manualChangeToAllGaugesBridgeTargetAtConstAmp(theEvent);
      } else if (theEvent.getName().equals(SLIDER_BRIDGE_POT_ALL)){
         manualChangeToAllGaugesBridgePot(theEvent);
      } else if (theEvent.getName().equals(SLIDER_AMP_POT_ALL)) {
         manualChangeToAllGaugesAmpPot(theEvent);
      } else if (theEvent.getName().equals(RADIO_DISPLAY)){
         changeDisplay(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesBridgeTargetMinAmp(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET_MIN_AMP+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesAmpTargetConstBridge(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_TARGET_CONST_BRIDGE+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesBridgeTargetAtConstAmp(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET_CONST_AMP+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesBridgePot(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_POT+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesAmpPot(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_POT+i).setValue(theEvent.getValue());
      }
   }

   private void changeDisplay(float eventValue){
      hideAllUISliders();
      if (eventValue == RADIO_SHOW_BRIDGE_TARGET_MIN_AMP_ITEM){
         showUISliders(SLIDERS_BRIDGE_TARGET_MIN_AMP);
         cp5.controller(SLIDER_BRIDGE_TARGET_MIN_AMP_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_AMP_TARGET_CONST_BRIDGE_ITEM){
         showUISliders(SLIDERS_AMP_TARGET_CONST_BRIDGE);
         cp5.controller(SLIDER_AMP_TARGET_CONST_BRIDGE_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_BRIDGE_POT_POS_ITEM){
         showUISliders(SLIDERS_BRIDGE_POT);
         cp5.controller(SLIDER_BRIDGE_POT_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_AMP_POT_POS_ITEM){
         showUISliders(SLIDERS_AMP_POT);
         cp5.controller(SLIDER_AMP_POT_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_BRIDGE_TARGET_CONST_AMP_ITEM){
         showUISliders(SLIDERS_BRIDGE_TARGET_CONST_AMP);
         cp5.controller(SLIDER_BRIDGE_TARGET_CONST_AMP_ALL).setVisible(true);
      } else if (eventValue == RADIO_ENABLE_STRAIN_GAUGE_ITEM){
         showUISliders(ENABLE_STRAIN_GAUGE);
         cp5.controller(ENABLE_ACCEL).setVisible(true);
      }
   }

   private void showUISliders(String sliderName){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(sliderName+i).setVisible(true);
      }
   }

   private void hideAllUISliders(){
      for (int i=0; i<SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET_MIN_AMP+i).setVisible(false);
         cp5.controller(SLIDERS_AMP_TARGET_CONST_BRIDGE+i).setVisible(false);
         cp5.controller(SLIDERS_BRIDGE_POT+i).setVisible(false);
         cp5.controller(SLIDERS_AMP_POT+i).setVisible(false);
         cp5.controller(SLIDERS_BRIDGE_TARGET_CONST_AMP+i).setVisible(false);
         cp5.controller(ENABLE_STRAIN_GAUGE+i).setVisible(false);
      }
      cp5.controller(SLIDER_BRIDGE_TARGET_MIN_AMP_ALL).setVisible(false);
      cp5.controller(SLIDER_AMP_TARGET_CONST_BRIDGE_ALL).setVisible(false);
      cp5.controller(SLIDER_BRIDGE_POT_ALL).setVisible(false);
      cp5.controller(SLIDER_AMP_POT_ALL).setVisible(false);
      cp5.controller(SLIDER_BRIDGE_TARGET_CONST_AMP_ALL).setVisible(false);
      cp5.controller(ENABLE_ACCEL).setVisible(false);
   }

   public void performKeyPress(char k){
      switch (k) {
         case TAB :
            hideAllUISliders();
            cp5.controller(CALIBRATE)
               .setVisible(!cp5.controller(CALIBRATE).isVisible());
            cp5.controller(CALIBRATE_CONST_AMP)
               .setVisible(!cp5.controller(CALIBRATE_CONST_AMP).isVisible());
            cp5.controller(CALIBRATE_ACCEL)
               .setVisible(!cp5.controller(CALIBRATE_ACCEL).isVisible());
            radioButton.setVisible(!radioButton.isVisible());
            radioButton.setValue(RADIO_SHOW_BAR_ITEM);
            uiHidden = !uiHidden;
            break;
            
      }
   }

   // public void performMousePress(){

   // }

   @Override
   public void registerToSerialNotifier(SerialNotifier notifier){
      notifier.registerForSerialListener(this);
   }
   @Override
   public void removeToSerialNotifier(SerialNotifier notifier){
      notifier.removeSerialListener(this);
   }
   @Override
   public void updateDiscoveredSerialPorts(String [] portNames){
      for (int i = 0; i < portNames.length; ++i) {
         arduinoPortNamesDropdownList.addItem(portNames[i], i);
         robotPortNamesDropdownList.addItem(portNames[i], i);
      }
   }
   @Override
   public void updateAnalogVals(float [] values){}
   @Override
   public void updateCaliVals(float [] values){}

   @Override
   public void updateTargetAnalogValsMinAmp(float [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET_MIN_AMP+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateTargetAnalogValsWithAmp(float [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_TARGET_CONST_BRIDGE+i).setValue((float)values[i]);
         cp5.controller(SLIDERS_BRIDGE_TARGET_CONST_AMP+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateBridgePotPosVals(float [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_POT+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateAmpPotPosVals(float [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_POT+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateCalibratingValsMinAmp(float [] values){}
   @Override
   public void updateCalibratingValsWithAmp(float [] values){}
   @Override
   public void updateReceiveRecordSignal(){}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "HandTieArduinoSystemOnProcessingRobotControl" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
