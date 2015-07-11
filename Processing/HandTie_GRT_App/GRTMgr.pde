import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;

     Minim minim;
    AudioOutput out;
    BeatDetect beat;
    int  r = 250;
    float rad = 10;
    
public class GRTMgr implements SerialListener{
  
   HandTie_GRT_App mainClass;

    
   //-----------------------------------GRT
    //Set the pipeline mode (CLASSIFICATION_MODE or REGRESSION_MODE), the number of inputs and the number of outputs
    final int pipelineMode = GRT.CLASSIFICATION_MODE;
    final int numInputs = 19;
    final int numOutputs = 1;
    
   GRT grt = new GRT( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );
   float[] data = new float[ numInputs ];
   float[] targetVector = new float[ numOutputs ];
 
   boolean showGETmsgFlg = true;
   
   boolean noGestureFlg = true; 
   String assignGesture = "No Gesture";
      public final static int NUM_OF_SG = 19;
   public final static int NUM_OF_SG_FIRSTROW = 9;
      public final static int ShowGauge_x = 140;
   public final static int ShowGauge_y = 200;
      public final static int EachSG_x = 50;
   public final static int EachSG_y = 20;   
      public final static int ShowGauge_dist = 30;
      
   int nowApp=0;
   int lastLabel=100;
   
   public GRTMgr (HandTie_GRT_App mainClass) {
      this.mainClass = mainClass;
      
      minim = new Minim(this);
     beat = new BeatDetect();
    out = minim.getLineOut();
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
        
        grt.sendData( data );
//        fill(color(200));
        
        
        switch(nowApp){
          
          case 0:
            textSize(80);
            text(grt.getPredictedClassLabel(),width*0.25,height*0.3);
            break;
          case 1:
          textSize(26);
            text("Numbers",width*0.01,height*0.05);
            textSize(80);
            if(noGestureFlg){
              text("No Gesture",width*0.55,height*0.5);
            }
            else{
              text("Number: "+(grt.getPredictedClassLabel()),width*0.55,height*0.5);
            }
            pushMatrix();
            translate(width/2, height/2);
            rotate(PI);
            
            for(int sgi=0; sgi<NUM_OF_SG; sgi++){
                fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(sgi)));
                if(sgi<NUM_OF_SG_FIRSTROW){
                    rect(ShowGauge_x+sgi*EachSG_x,ShowGauge_y,EachSG_x,EachSG_y);
                }
                else{
                    rect(ShowGauge_x+(sgi-NUM_OF_SG_FIRSTROW-0.5)*EachSG_x,ShowGauge_y+ShowGauge_dist,EachSG_x,EachSG_y);

                }

            }
            
            popMatrix();
            Numbers();
            break;
          case 2:
//           background(60,60,60);  
          textSize(26);
            text("Musical Performance",width*0.01,height*0.05);
            
                MusicalPerformance();
                
                if(lastLabel != grt.getPredictedClassLabel() && grt.getMaximumLikelihood()>0.8){
                    lastLabel = grt.getPredictedClassLabel();
                    out.playNote( 0.0, 1.0, new SineInstrument( Frequency.ofPitch( String.valueOf((char)(lastLabel + 66))+"4" ).asHz() ) );
                }
                textSize(40);
                 fill(0,150);
                 text(String.valueOf((char)(lastLabel + 66))+"3",-25,15);
//                println(lastLabel+" "+String.valueOf((char)(lastLabel + 66)));
            break;
          case 3:
          textSize(26);
            text("Baseball Pitching Grips",width*0.01,height*0.05);
            break;
          case 4:
            textSize(26);
            text("Smartwatch",width*0.01,height*0.05);
            textSize(80);
            if(noGestureFlg){
              text("No Gesture",width*0.55,height*0.5);
            }
            else{
              text(assignGesture,width*0.55,height*0.5);
            }
            
            Numbers();
            break;
        }
        
        if(showGETmsgFlg){
          //Draw the info text
          textSize(16);
          grt.drawInfoText(floor(width*0.72),20);
        }
        //Grab the mouse data and send it to the GRT backend via OSC
        for(int sgi=1; sgi<numInputs; sgi++){
          data[sgi-1] = mainClass.sgManager.getOneElongationValsOfGauges(sgi);
        }
        
   }
   public color getHeatmapRGB(float value){
     float minimum=0.6;
     float maximum=1.4;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     color heatmapRGB = color((int)max(0, 255*(ratio - 1)),255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)), (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
   }
   public void performKeyPress(char k){
      
      switch (k) {
         case 'q':
          assignGesture = "Previous";
          break;
         case 'a':
         assignGesture = "Next";
          break;
         case 'w':
         assignGesture = "OK";
          break;
         case 'e':
         assignGesture = "Homeggg";
          break;
          
         case 'g':
          noGestureFlg = !noGestureFlg;
          break;
         case 'z':
            out.playNote( 0.0, 1.0, new SineInstrument( Frequency.ofPitch( "E3" ).asHz() ) );
          break;
        case '`':
            nowApp = 0;
          break;
        case '1':
            nowApp = 1;
          break;
        case '2':
            nowApp = 2;
          break;
        case '3':
            nowApp = 3;
          break;
        case '4':
            nowApp = 4;
          break;
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
  public void updateAnalogVals(int [] values){}
  @Override
  public void updateCaliVals(int [] values){}
  @Override
  public void updateTargetAnalogValsMinAmp(int [] values){}
  @Override
  public void updateTargetAnalogValsWithAmp(int [] values){}
  @Override
  public void updateBridgePotPosVals(int [] values){}
  @Override
  public void updateAmpPotPosVals(int [] values){}
  @Override
  public void updateCalibratingValsMinAmp(int [] values){}
  @Override
  public void updateCalibratingValsWithAmp(int [] values){}

  // StringBuffer strBuffer = new StringBuffer();

 // private String getImageFileName() {
 //   strBuffer.setLength(0);
 //   strBuffer.append(StudyID);
 //   strBuffer.append("_");
 //   strBuffer.append(NowGesture);
 //   strBuffer.append("_");
 //   strBuffer.append(NowRow);
 //   return strBuffer.toString();
 // }
   @Override
  public void updateReceiveRecordSignal(){
    
  }

}

boolean sketchFullScreen() {
  return true;
}
class SineInstrument implements Instrument
{
  Oscil wave;
  Line  ampEnv;
  
  SineInstrument( float frequency )
  {
    // make a sine wave oscillator
    // the amplitude is zero because 
    // we are going to patch a Line to it anyway
    wave   = new Oscil( frequency, 0, Waves.SINE );
    ampEnv = new Line();
    ampEnv.patch( wave.amplitude );
  }
  
  // this is called by the sequencer when this instrument
  // should start making sound. the duration is expressed in seconds.
  void noteOn( float duration )
  {
    // start the amplitude envelope
    ampEnv.activate( duration, 0.5f, 0 );
    // attach the oscil to the output so it makes sound
    wave.patch( out );
  }
  
  // this is called by the sequencer when the instrument should
  // stop making sound
  void noteOff()
  {
    wave.unpatch( out );
  }
}

void MusicalPerformance(){
  
  beat.detect(out.mix);
//  fill(#1A1F18, 20);
//  noStroke();
//  rect(0, 0,displayWidth, displayHeight);
  translate(width/3*2+100, height/2);
  noFill();
  fill(10,200,15, 10);
  if (beat.isOnset()) rad = rad*0.9;
  else rad = 70;
  ellipse(0, 0, 2*rad, 2*rad);
  stroke(10,200,15);
  int bsize = out.bufferSize();
  for (int i = 0; i < bsize - 1; i+=5)
  {
    
    float x = (r)*cos(i*2*PI/bsize);
    float y = (r)*sin(i*2*PI/bsize);
    float x2 = (r + out.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + out.left.get(i)*100)*sin(i*2*PI/bsize);
    line(x, y, x2, y2);
  }
  beginShape();
  noFill();
  stroke(10,200,15, 10);
  for (int i = 0; i < bsize; i+=30)
  {
    
    float x2 = (r + out.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + out.left.get(i)*100)*sin(i*2*PI/bsize);
    vertex(x2, y2);
    pushStyle();
    stroke(0,255,0);
    strokeWeight(5);
    point(x2, y2);
    popStyle();
  }
  endShape();

}
void Numbers(){
  
  translate(width/3*2+100, height/2);
  noFill();
  
}
