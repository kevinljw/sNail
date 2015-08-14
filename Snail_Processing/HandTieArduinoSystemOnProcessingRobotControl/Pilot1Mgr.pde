import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import java.util.ArrayList;


public class PilotOneTask
{
  
  public int force; // tap and press 0...1

  public PilotOneTask(int force) {
    this.force = force;
  }
}


public class Pilot1Mgr implements ControlListener {

  public final static String FOLDER_NAME = "PilotOne";
  public final static int AMOUNT_OF_FORCE = 2;

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
  public final static int TIMES_OF_EACH_TASK = 5;
  int taskCount = AMOUNT_OF_FORCE;
  ArrayList<PilotOneTask> tasks = new ArrayList<PilotOneTask>();

  //external window
  PilotOneFrame userStudyFrame = null;


  public Pilot1Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
    this.mainClass = mainClass;
    this.sensors = mainClass.sensors;

    for (int i = 0; i < AMOUNT_OF_FORCE; ++i) {
        tasks.add(new PilotOneTask(i));
    }
  }

  @Override
  public void controlEvent(ControlEvent theEvent){
    //others
    if (millis()<1000) return;
      else if (theEvent.getName().equals(UIInteractionMgr.START_PILOT_STUDY_TWO)) {
          if (currentDoing) {
            endStudy();
          }
          else{
            startStudy();
          }
          return; 
        }
        //from UserStudyOneFrame
        if (userStudyFrame != null) {
          if (!userStudyFrame.launchComplete)  return;
          else if (theEvent.getName().equals(PilotOneFrame.START_RECORD)) {
            if (currentRecording) {
              stopRecording();
            }
            else {
              startRecording();
            }
          }
          else if (theEvent.getName().equals(PilotOneFrame.NEXT_TASK)) {
            currentTaskNum++;
            nextTask();
          }
          else if (theEvent.getName().equals(PilotOneFrame.PREVIOUS_TASK)) {
            preTask();
          }
        }
  }


  void startStudy() {
    userStudyFrame = addPilotOneFrame("Pilot Study One", 320, 480, this);
    //init the first time, wont receiving data immediately, need to press startRecording
    currentDoing = true;
    sensors.showWindow();
    nextTask();
    new UserProfile().startDoingStudy(0);
  }

  void endStudy()
  {
    if (currentRecording) {
      stopRecording();
    }
    if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
      new UserProfile().doneStudy(0);
    }
    currentDoing = false;
    sensors.closeWindow();
    userStudyFrame.closeWindow();
  }

  void startRecording()
  {
    currentRecording = true;
  }

  void stopRecording()
  {
    //means that the task end
    currentRecording = false;

    PilotOneTask currentTask = tasks.get(currentTaskNum % taskCount);
    saveTable(table, FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force+".csv");
    currentTaskNum++;
    userStudyFrame.updateProgress(currentTaskNum);
    nextTask();
  }

  //collet data
  public void draw(){
    if (currentRecording) {
      saveToFile();
    }
  }

  void nextTask() {

    if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
      endStudy();
    }

    if (currentTaskNum % taskCount == 0) {
      Collections.shuffle(tasks);
    }

    PilotOneTask currentTask = tasks.get(currentTaskNum % taskCount);
    String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force+".csv";

    if(!checkIfFileExist(nameOfFile))
    {
      table = new Table();
      table.addColumn("taskNumber");
      table.addColumn("roll");
      table.addColumn("yaw");
      table.addColumn("pitch");
      table.addColumn("force");
    }
    else{
      table = loadTable(nameOfFile, "header, csv");
    }

    userStudyFrame.updateInstruct(currentTask.force);
    
    // sensors.setCurrentInstruct(currentTask.pitch, currentTask.roll, currentTask.force);
  }

  void preTask() {
    
    println("preTaskCalled");

    currentRecording = false;

    if (table.getRowCount() > 0) {
      //just drop the rows by a new table
      nextTask();
    }
    else
    {
      currentTaskNum--;
      PilotOneTask currentTask = tasks.get(currentTaskNum % taskCount);
      String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force+".csv";
      table = loadTable(nameOfFile, "header, csv");

      int [] needToDeleteRows = table.findRowIndices( Integer.toString(currentTaskNum / taskCount), "taskNumber");

      for (int i = needToDeleteRows.length-1 ; i >= 0 ;i-- ) {
        table.removeRow(needToDeleteRows[i]);
      }

      saveTable(table, nameOfFile);
      userStudyFrame.updateProgress(currentTaskNum);
      nextTask();
    }   
  }

  void saveToFile()
  {
    // println("saveToFile!!");

    float [] datas = sensors.getRollYawPitch();
    TableRow newRow = table.addRow();
    newRow.setInt("taskNumber", (int) currentTaskNum / taskCount);
    newRow.setFloat("roll", datas[0]);
    newRow.setFloat("yaw", datas[1]);
    newRow.setFloat("pitch", datas[2]);
    newRow.setFloat("force", sensors.force);
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




PilotOneFrame addPilotOneFrame(String theName, int theWidth, int theHeight, Pilot1Mgr mgr) {
  Frame f = new Frame(theName);
  PilotOneFrame p = new PilotOneFrame(this, theWidth, theHeight, f);
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

public class PilotOneFrame extends PApplet {


  public final static String START_RECORD = "Start Recording";
  // public final static String STOP_RECORD = "Stop Recording";
  public final static String NEXT_TASK = "Next Task";
  public final static String PREVIOUS_TASK = "Previous Task";
  public final static String CURRENT_PROGRESS = "Current Progress";

  int w, h;
  Frame frame;

  Pilot1Mgr mgr = null;
  ControlP5 cp5;

  Object parent;

  private Knob progressKnob;
  private Toggle toogleRecording;
  private int force = 0;

  public boolean launchComplete = false;

  public void setup() {
    cp5 = new ControlP5(this);
    println("mgr: "+mgr);
    cp5.addListener(mgr);
    
    size(w, h);
    drawUI();
    launchComplete = true;
    frameRate(30);
  }

  public void closeWindow() {
    frame.dispose();
    launchComplete = false;
  }

  public void draw() {
    background(255);
    fill(0);
    textSize(32);
    switch (force) {
      case 0 :
        text("Slide", width * 0.2 , height*0.6);  
        break;
      case 1 :
        text("Pivot", width * 0.2 , height*0.6);
        break;  
      case 2:
        text("Drag", width * 0.2 , height*0.6);
        break;    
      default :
        break;  
      
    }
     
  }

  void drawUI() {
    toogleRecording = cp5.addToggle(START_RECORD)
     .setColorLabel(color(0))
     .setBroadcast(false)
     .setValue(0)
     .setPosition(50, 50)
     .setSize(50,30)
     .setBroadcast(true)
     ;
    cp5.addButton(PREVIOUS_TASK)
     .setValue(0)
     .setPosition(50,100)
     .setSize(100,19)
     .setBroadcast(true)
     ; 
    progressKnob = cp5.addKnob(CURRENT_PROGRESS)
     .setRange(0,60)
     .setValue(0)
     .setPosition(200,10)
     .setRadius(50)
     .setDragDirection(Knob.VERTICAL)
     .setLock(true)
     ;
  }
  
  private PilotOneFrame() {
  }

  public PilotOneFrame(Object theParent, int theWidth, int theHeight, Frame f) {
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

  public void updateInstruct(int force) {
    this.force = force;
  }
}

// import java.awt.Frame;
// import java.awt.BorderLayout;
// import controlP5.*;
// import java.util.ArrayList;


// public class PilotStudyTask
// {
//    public int force;

//    public PilotStudyTask(int force) {
//       this.force = force;
//    }
// }


// public class StudyPMgr implements ControlListener {

//   public final static String FOLDER_NAME = "PilotOne";

//    //holding other class object
//    PApplet mainClass;
//    ExternalSensors sensors;

//    //self variable
//    private SerialNotifier serialNotifier;
//    boolean currentDoing = false;
//    boolean currentRecording = false;
//    int currentTaskNum = 0;
//    int currentSavedRawDataNum = 0;
//    Table table;

//    //task
//    public final static float TOLERANCE_OF_FORCE = 20;
//    public final static int AMOUNT_OF_RECEIVED_RAW_DATA = 50;
//    public final static int TIMES_OF_EACH_TASK = 10;
//    int force []= {0, 1, 2};
//    int taskCount = force.length;
//    ArrayList<PilotStudyTask> tasks = new ArrayList<PilotStudyTask>();

//    //external window
//    PilotStudyOneFrame pilotstudyFrame = null;


//    public StudyPMgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
//       this.mainClass = mainClass;
//       this.sensors = mainClass.sensors;

//       for (int k = 0; k < force.length; ++k) {
//          tasks.add(new PilotStudyTask(this.force[k]));
//       }
//    }

//    @Override
//    public void controlEvent(ControlEvent theEvent){
//       //others
//       if (millis()<1000) return;
//          else if (theEvent.getName().equals(UIInteractionMgr.START_PILOT_STUDY_ONE)) {
//             if (currentDoing) {
//                currentDoing = false;
//                endStudy();
//             }
//             else{
//                currentDoing = true;
//                startStudy();
//             }
//             return;  
//          }
//          //from PilotStudyOneFrame
//          if (pilotstudyFrame != null) {
//             if (!pilotstudyFrame.launchComplete)  return;
//             else if (theEvent.getName().equals(PilotStudyOneFrame.START_RECORD)) {
//                if (currentRecording) {
//                   stopRecording();  
//                }
//                else {
//                   startRecording();
//                }
               
//             }
//             else if (theEvent.getName().equals(PilotStudyOneFrame.NEXT_TASK)) {
//                currentTaskNum++;
//                nextTask();
//             }
           
//          }
//    }


//    void startStudy() {
//       pilotstudyFrame = addPilotStudyOneFrame("Pilot Study One", 320, 480, this);
//       //init the first time, wont receiving data immediately, need to press startRecording
//       nextTask();
//       sensors.showWindow();
//       new UserProfile().startDoingStudy(0);
//    }

//    void endStudy()
//    {
//       if (currentRecording) {
//         stopRecording();
//       }
//       if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
//         new UserProfile().doneStudy(0);
//       }
//       sensors.closeWindow();
//       pilotstudyFrame.closeWindow();
//    }

//    void startRecording()
//    {
//       currentRecording = true;
//    }

//    void stopRecording()
//    {
//       currentRecording = false;
//       //this means pause for some users need to relax for a min
      
//    }

//    //collet data
//     public void draw(){
//       if (currentRecording == true) {
//         saveToFile();
//       }
//     }

//    void nextTask() {

//       if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
//          endStudy();
//       }

//       String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTaskNum % taskCount +".csv";

//       if(!checkIfFileExist(nameOfFile))
//       {
//          table = new Table();
  
//          table.addColumn("taskNumber");
//          table.addColumn("force");
//       }
//       else{
//          table = 

//       }

//       PilotStudyTask currentTask = tasks.get(currentTaskNum % taskCount);
//       pilotstudyFrame.updateInstruct(currentTask.force);
//   }

//    void saveToFile()
//    {
//       TableRow newRow = table.addRow();
//       newRow.setInt("taskNumber", (int) currentTaskNum / taskCount);
//       newRow.setFloat("force", sensors.force);

//       currentSavedRawDataNum++;
//       if (currentSavedRawDataNum == AMOUNT_OF_RECEIVED_RAW_DATA) {
//          pilotstudyFrame.toggle();
//          stopRecording();

//          saveTable(table,  FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTaskNum % taskCount +".csv");
//          currentTaskNum++;
//          pilotstudyFrame.updateProgress(currentTaskNum);

//          currentSavedRawDataNum = 0;
         
//          nextTask();
//       }
//    }

//    boolean checkIfFileExist(String nameOfFile) {
//       File f = new File(sketchPath("") + nameOfFile);
//       if (f.exists()) {
//          return true;
//       }
//       else{
//          return false;
//       }
//    }
// }




// PilotStudyOneFrame addPilotStudyOneFrame(String theName, int theWidth, int theHeight, StudyPMgr mgr) {
//   Frame f = new Frame(theName);
//   PilotStudyOneFrame p = new PilotStudyOneFrame(this, theWidth, theHeight, f);
//   p.mgr = mgr;
//   f.add(p);
//   p.init();
//   f.setTitle(theName);
//   f.setSize(p.w, p.h);
//   f.setLocation(100, 100);
//   f.setResizable(false);
//   f.setVisible(true);
//   return p;
// }

// public class PilotStudyOneFrame extends PApplet {


//    public final static String START_RECORD = "Start Recording";
//    // public final static String STOP_RECORD = "Stop Recording";
//    public final static String START_TASK = "Start Task";
//    public final static String CONFIRM_START = "Confirm Start";
//    public final static String NEXT_TASK = "Next Task";
//    public final static String CURRENT_PROGRESS = "Current Progress";

//   int w, h;
//   Frame frame;

//   StudyPMgr mgr = null;
//   ControlP5 cp5;

//   Object parent;

//   private int force = 0;
//   private Knob progressKnob;
//   private Toggle toogleRecording;
//   public boolean launchComplete = false;

//   public void setup() {
//    cp5 = new ControlP5(this);
//    println("mgr: "+mgr);
//    cp5.addListener(mgr);
//    drawUI();
//    launchComplete = true;
//    size(w, h);
//    frameRate(30);
//   }

//   public void closeWindow() {
//     frame.dispose();
//     launchComplete = false;
//   }

//   public void draw() {
//     background(255);
//     fill(0);
//     textSize(32);
//      switch (force) {
//       case 0 :
//         text("Force:\nNormal", width * 0.2 , height*0.3); 
//         break;    
//       case 1:
//         text("Force:\nLight", width * 0.2 , height*0.3);
//         break;  
//       case 2 :
//         text("Force:\nHeavy", width * 0.2 , height*0.3);  
//         break;  
//       default :
//         break;  
      
//     }
//   }

//   void drawUI() {
//    toogleRecording = cp5.addToggle(START_RECORD)
//      .setColorLabel(color(0))
//      .setBroadcast(false)
//      .setValue(0)
//      .setPosition(50,50)
//      .setSize(50,30)
//      .setBroadcast(true)
//      ;
//     cp5.addButton(NEXT_TASK)
//      .setValue(0)
//      .setPosition(50,250)
//      .setSize(200,19)
//      .setBroadcast(true)
//      ;  
//     progressKnob = cp5.addKnob(CURRENT_PROGRESS)
//      .setRange(0, 15)
//      .setValue(0)
//      .setPosition(100,300)
//      .setRadius(50)
//      .setDragDirection(Knob.VERTICAL)
//      .setLock(true)
//      ;
//   }
  
//   private PilotStudyOneFrame() {
//   }

//   public PilotStudyOneFrame(Object theParent, int theWidth, int theHeight, Frame f) {
//     parent = theParent;
//     w = theWidth;
//     h = theHeight;
//     frame = f;
//   }
//   public ControlP5 control() {
//     return cp5;
//   }

//   public void updateProgress(int num) {
//    progressKnob.setValue(num);
//   }
//   public void toggle() {
//     toogleRecording.toggle();
//   }

//   public void updateInstruct(int force) {
//     this.force = force;
//   }

  
// }