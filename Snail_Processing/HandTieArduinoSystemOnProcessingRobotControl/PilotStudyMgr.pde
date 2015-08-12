import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import java.util.ArrayList;


public class PilotStudyTask
{
   public float force;

   public PilotStudyTask(float force) {
      this.force = force;
   }
}


public class StudyPMgr implements ControlListener, SerialListener {

   //holding other class object
   PApplet mainClass;
   ExternalSensors sensors;

   //self variable
   private SerialNotifier serialNotifier;
   boolean currentDoing = false;
   boolean currentRecording = false;
   int currentTaskNum = 0;
   int currentSavedRawDataNum = 0;
   Table table;

   //task
   public final static float TOLERANCE_OF_FORCE = 20;
   public final static float NEWTON_TO_GRAMS = 101.971621298;
   public final static int AMOUNT_OF_RECEIVED_RAW_DATA = 50;
   public final static int TIMES_OF_EACH_TASK = 3;
   float force []= {1, 2, 3};
   int taskCount = force.length;
   ArrayList<PilotStudyTask> tasks = new ArrayList<PilotStudyTask>();

   //external window
   PilotStudyOneFrame pilotstudyFrame = null;


   public StudyPMgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
      this.mainClass = mainClass;
      this.sensors = mainClass.sensors;

      for (int k = 0; k < this.force.length; ++k) {
         tasks.add(new PilotStudyTask(this.force[k] * NEWTON_TO_GRAMS ));
      }
   }

   @Override
   public void controlEvent(ControlEvent theEvent){
      //others
      if (millis()<1000) return;
         else if (theEvent.getName().equals(UIInteractionMgr.START_PILOT_STUDY_ONE)) {
            if (currentDoing) {
               currentDoing = false;
               endStudy();
            }
            else{
               currentDoing = true;
               startStudy();
            }
            return;  
         }
         //from PilotStudyOneFrame
         if (pilotstudyFrame != null) {
            if (!pilotstudyFrame.launchComplete)  return;
            else if (theEvent.getName().equals(PilotStudyOneFrame.START_RECORD)) {
               if (currentRecording) {
                  stopRecording();  
               }
               else {
                  startRecording();
               }
               
            }
            // else if (theEvent.getName().equals(PilotStudyOneFrame.STOP_RECORD)) {
            //    stopRecording();
            // }
            else if (theEvent.getName().equals(PilotStudyOneFrame.START_TASK)) {
               startTask();
            }
            else if (theEvent.getName().equals(PilotStudyOneFrame.CONFIRM_START)) {
               confirmStart();
            }  
            else if (theEvent.getName().equals(PilotStudyOneFrame.NEXT_TASK)) {
               currentTaskNum++;
               nextTask();
            }
           
         }
   }


   void startStudy() {
      pilotstudyFrame = addPilotStudyOneFrame("Pilot Study One", 320, 480, this);
      //init the first time, wont receiving data immediately, need to press startRecording
      nextTask();
      UserProfile.createProfile();
   }

   void endStudy()
   {
      if (currentRecording) {
         stopRecording();
      }
      sensors.closeWindow();
      pilotstudyFrame.closeWindow();
   }

   void startRecording()
   {
      currentRecording = true;
   }

   void stopRecording()
   {
      currentRecording = false;
      //this means pause for some users need to relax for a min
      
   }

   void startTask() {
      currentRecording = false;
      sensors.weight();
   }

   void confirmStart(){
      currentRecording = true;
   }

   void nextTask() {

      if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
         endStudy();
      }
      String nameOfFile = UserProfile.USER_ID + "/PilotStudyOne/" +  currentTaskNum % taskCount +".csv";

      if(!checkIfFileExist(nameOfFile))
      {
         table = new Table();
  
         table.addColumn("userID");
         table.addColumn("force");
         for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
            table.addColumn("SG" + i); 
         }
      }
      else{
         table = loadTable(nameOfFile, "header, csv");
      }
      PilotStudyTask currentTask = tasks.get(currentTaskNum % taskCount);
  }

   boolean toleranceCalculation(float values, float traget, int type)
   {
      //type 0 - roll yaw pitch, 1 = force
      //
      if (type == 0) {
         return false;
      }
      else if (type == 1) {
         if ((traget + TOLERANCE_OF_FORCE >= values) || (traget - TOLERANCE_OF_FORCE <= values)) {
            return true;   
         }
         else
         {
            return false;
         }
      }
      else
      {
         return false;
      }
   }

   void saveToFile(float [] values)
   {
      TableRow newRow = table.addRow();
      newRow.setInt("userID", Integer.parseInt(UserProfile.USER_ID));
      newRow.setFloat("weight", sensors.weight);

      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         newRow.setFloat("SG" + i, values[i]);
      }
      currentSavedRawDataNum++;
      if (currentSavedRawDataNum == AMOUNT_OF_RECEIVED_RAW_DATA) {
         saveTable(table, UserProfile.USER_ID + "/PilotStudyOne/" +  currentTaskNum % taskCount +".csv");
         currentTaskNum++;
         pilotstudyFrame.updateProgress(currentTaskNum);

         currentSavedRawDataNum = 0;
         nextTask();
      }
   }

   boolean checkIfFileExist(String nameOfFile) {
      File f = new File(sketchPath("") + nameOfFile);
      if (f.exists()) {
         return true;
      }
      else{
         return false;
      }
   }
}




PilotStudyOneFrame addPilotStudyOneFrame(String theName, int theWidth, int theHeight, StudyPMgr mgr) {
  Frame f = new Frame(theName);
  PilotStudyOneFrame p = new PilotStudyOneFrame(this, theWidth, theHeight, f);
  p.mgr = mgr;
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  return p;
}

public class PilotStudyOneFrame extends PApplet {


   public final static String START_RECORD = "Start Recording";
   // public final static String STOP_RECORD = "Stop Recording";
   public final static String START_TASK = "Start Task";
   public final static String CONFIRM_START = "Confirm Start";
   public final static String NEXT_TASK = "Next Task";
   public final static String CURRENT_PROGRESS = "Current Progress";

  int w, h;
  Frame frame;

  StudyPMgr mgr = null;
  ControlP5 cp5;

  Object parent;

  private Knob progressKnob;
  public boolean launchComplete = false;

  public void setup() {
   cp5 = new ControlP5(this);
   println("mgr: "+mgr);
   cp5.addListener(mgr);
   drawUI();
   launchComplete = true;
   size(w, h);
   frameRate(30);
  }

  public void closeWindow() {
    frame.dispose();
    launchComplete = false;
  }

  public void draw() {
     
  }

  void drawUI() {
   cp5.addToggle(START_RECORD)
     .setColorLabel(color(0))
     .setBroadcast(false)
     .setValue(0)
     .setPosition(width*0.85, height*0.8)
     .setSize(50,30)
     .setBroadcast(true)
     ;
    cp5.addButton(START_TASK)
     .setValue(0)
     .setPosition(50,150)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    cp5.addButton(CONFIRM_START)
     .setValue(0)
     .setPosition(50,200)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    cp5.addButton(NEXT_TASK)
     .setValue(0)
     .setPosition(50,250)
     .setSize(200,19)
     .setBroadcast(true)
     ;  
    progressKnob = cp5.addKnob(CURRENT_PROGRESS)
     .setRange(0,300)
     .setValue(0)
     .setPosition(100,300)
     .setRadius(50)
     .setDragDirection(Knob.VERTICAL)
     .setLock(true)
     ;
  }
  
  private PilotStudyOneFrame() {
  }

  public PilotStudyOneFrame(Object theParent, int theWidth, int theHeight, Frame f) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
    frame = f;
  }
  public ControlP5 control() {
    return cp5;
  }

  public void updateProgress(int num) {
   progressKnob.setValue(num);
  }
  

  
}