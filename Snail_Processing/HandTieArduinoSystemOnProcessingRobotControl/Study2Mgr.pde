import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import java.util.ArrayList;
import java.util.Collections;
import processing.video.*;


public class StudyTwoTask
{
  
  public int speed;
  public int force;
  public int direction;

  public StudyTwoTask(int speed, int force, int direction) {
    this.speed = speed;
    this.force = force;
    this.direction = direction;
  }
}

public class StudyTwoDataStructure
{
  int taskNumber;
  float roll;
  float yaw;
  float pitch;
  float force;

  float [] sgs = new float[8];
  float [] sgs_E = new float[8];
  float [] sgs_D = new float[8];

  public StudyTwoDataStructure(int taskNumber, float roll, float yaw, float pitch, float force, float [] sgs, float [] sgs_E, float [] sgs_D)
  {
    this.taskNumber = taskNumber;
    this.roll = roll;
    this.yaw = yaw;
    this.pitch = pitch;
    this.force = force;
    this.sgs = sgs;
    this.sgs_E = sgs_E;
    this.sgs_D = sgs_D;

  }
}


public class Study2Mgr implements ControlListener, SerialListener {

  public final static String FOLDER_NAME = "StudyTwo";
  PApplet mainClass;
  ExternalSensors sensors;
	UserStudyTwoFrame userStudyFrame = null;
  MovieFrame movieFrame = null;
	boolean currentDoing = false;
  ArrayList<StudyTwoTask> tasks = new ArrayList<StudyTwoTask>();
  ArrayList<StudyTwoDataStructure> currentDatasForOneTask = new ArrayList<StudyTwoDataStructure>();

  private SerialNotifier serialNotifier;
  public int currentTaskNum = 0;
  int currentSavedRawDataNum = 0;


  int speed []= {0, 1, 2};
  int force []= {0, 1, 2};
  int direction []= {0, 1, 2, 3, 4, 5, 6, 7};

  public int taskCount = speed.length * force.length * direction.length;
  public final static int TIMES_OF_EACH_TASK = 3;

  int run = 0;
  int runIndex = 0;

  Table table;

  boolean currentRecording = false;

	public Study2Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
    this.mainClass = mainClass;
    this.sensors = mainClass.sensors;

    for (int i = 0; i < speed.length; ++i) {
      for (int j = 0; j < force.length; ++j) {
        for (int k = 0; k < direction.length; ++k) {
          tasks.add(new StudyTwoTask(speed[i], force[j], direction[k]));
        }
      }
    }

    // for(int i = 0; i < 8; i++){
    //     tasks.add(i);
    // }

    Collections.shuffle(tasks);
  }

	@Override
	public void controlEvent(ControlEvent theEvent){


		if (millis()<1000) return;
	  else if (theEvent.getName().equals(UIInteractionMgr.START_USER_STUDY_TWO)) {
      if (currentDoing) {
      	currentDoing = false;
      	endStudy(true);
      }
      else{
      	currentDoing = true;
      	startStudy();
      }
      return;	
    }

    if (userStudyFrame != null) {
          if (!userStudyFrame.launchComplete)  return;
          else if (theEvent.getName().equals(UserStudyOneFrame.START_RECORD)) {
            if (currentRecording) {
              stopRecording(true);
            }
            else {
              startRecording();
            }
          }
          else if (theEvent.getName().equals(UserStudyOneFrame.NEXT_TASK)) {
            currentTaskNum++;
            nextTask();
          }
          else if (theEvent.getName().equals(UserStudyOneFrame.PREVIOUS_TASK)) {
            preTask();
          }
        }

	}

  void startRecording()
  {
    currentRecording = true;
  }

  void stopRecording(boolean fromUI)
  {
    // if (fromUI == false) {
    //   userStudyFrame.toggle();  
    // }
    currentRecording = false;

    StudyTwoTask currentTask = tasks.get(currentTaskNum % taskCount);
    saveTable(table, FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force + "/" + currentTask.speed +"/"+ currentTask.direction +".csv");
    currentTaskNum++;
    userStudyFrame.updateProgress(currentTaskNum);
    nextTask();
    //this means pause for some users need to relax for a min
    
  }


	void startStudy() {
		userStudyFrame = addUserStudyTwoFrame("User Study Two", 320, 720, this);
    movieFrame = addMovieFrame("User Study Two movie", 550, 400, this);
    nextTask();
	}

	void endStudy(boolean fromUI)
	{
		userStudyFrame.closeWindow();
    movieFrame.closeWindow();
	}

  void nextTask()
  {
    if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
      endStudy(false);
    }

    if (currentTaskNum % taskCount == 0) {
      Collections.shuffle(tasks);
    }

    StudyTwoTask currentTask = tasks.get(currentTaskNum % taskCount);
    // int convertForceToNewton = Math.round(currentTask.force/NEWTON_TO_GRAMS);

    String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force + "/" + currentTask.speed +"/"+ currentTask.direction +".csv";

    if(!checkIfFileExist(nameOfFile))
    {
      table = new Table();
  
      table.addColumn("taskNumber");
      table.addColumn("roll");
      table.addColumn("yaw");
      table.addColumn("pitch");
      table.addColumn("force");
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
        table.addColumn("SG" + i);
        table.addColumn("SG_E" + i);
        table.addColumn("SG_D" + i);
      }
    }
    else{
      table = loadTable(nameOfFile, "header, csv");
    }
    movieFrame.videoInstruction(currentTask.direction, currentTask.speed);
    // sensors.setCurrentInstruct(currentTask.pitch, currentTask.roll, currentTask.force);


    // if( runIndex < 7 && run < 5 ){
    //   runIndex++;
    //   println("tasks.get(runIndex).intValue(): "+tasks.get(runIndex).intValue());
    //   movieFrame.video(tasks.get(runIndex).intValue());
    // }
    // else{
    //   run++;
    //   runIndex = 0;
    //   Collections.shuffle(tasks);
    // }

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
      StudyTwoTask currentTask = tasks.get(currentTaskNum % taskCount);
      String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force + "/" + currentTask.speed +"/"+ currentTask.direction +".csv";
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

  void saveToFile(float [] values)
  {

    float [] datas = sensors.getRollYawPitch();
    TableRow newRow = table.addRow();
    newRow.setInt("taskNumber", (int) currentTaskNum / taskCount);
    newRow.setFloat("roll", datas[0]);
    newRow.setFloat("yaw", datas[1]);
    newRow.setFloat("pitch", datas[2]);
    newRow.setFloat("force", sensors.force);
    for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
      newRow.setFloat("SG" + i, values[i]);
      newRow.setFloat("SG_E" + i, sgManager.getOneElongationValsOfGauges(i));
      newRow.setFloat("SG_D" + i, sgManager.getOneDifferenceValsOfGauges(i));
    }

    // currentSavedRawDataNum++;

    // println("currentSavedRawDataNum: "+currentSavedRawDataNum);
    // if (currentSavedRawDataNum == AMOUNT_OF_RECEIVED_RAW_DATA) {

    //   StudyTwoTask currentTask = tasks.get(currentTaskNum % taskCount);
      
    //   saveTable(table, FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.speed +"/"+ currentTask.direction +".csv");
    //   currentTaskNum++;
    //   userStudyFrame.updateProgress(currentTaskNum);

    //   currentSavedRawDataNum = 0;
    //   nextTask();

    //   println("AMOUNT_OF_RECEIVED_RAW_DATA !!!!!");
    // }

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

	@Override
  public void registerToSerialNotifier(SerialNotifier notifier)
  {
    notifier.registerForSerialListener(this);
    serialNotifier = notifier;
  }
  @Override
  public void removeToSerialNotifier(SerialNotifier notifier)
  {
    notifier.removeSerialListener(this);
    serialNotifier = null;
  }
	@Override
	public void updateDiscoveredSerialPorts(String [] portNames){}
	@Override
	public void updateAnalogVals(float [] values)
	{
    println("updateAnalogVals user2");
    if (userStudyFrame != null) {
      if (currentRecording) {
        saveToFile(values);
      }
    }
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

}

UserStudyTwoFrame addUserStudyTwoFrame(String theName, int theWidth, int theHeight, Study2Mgr mgr) {
  Frame f = new Frame(theName);
  UserStudyTwoFrame p = new UserStudyTwoFrame(this, theWidth, theHeight, f);
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

MovieFrame addMovieFrame(String theName, int theWidth, int theHeight, Study2Mgr mgr){
  Frame f = new Frame(theName);
  MovieFrame p = new MovieFrame(this, theWidth, theHeight, f);
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



public class UserStudyTwoFrame extends PApplet {


	public final static String START_RECORD = "Start Recording";
	public final static String STOP_RECORD = "Stop Recording";
	public final static String NEXT_TASK = "Next Task";
	public final static String PREVIOUS_TASK = "Previous Task";
  public final static String ARROW_UP = "test";
  public final static String CURRENT_PROGRESS = "Current Progress";

  int w, h;
  Frame frame;

  Study2Mgr mgr = null;
  ControlP5 cp5;
  PImage arrow_up_off = loadImage(currentSketchPath+"images/arrow_up_off.png");
  PImage arrow_up_on = loadImage(currentSketchPath+"images/arrow_up_on.png");
  PImage arrow_right_off = loadImage(currentSketchPath+"images/arrow_right_off.png");
  PImage arrow_right_on = loadImage(currentSketchPath+"images/arrow_right_on.png");
  PImage arrow_down_off = loadImage(currentSketchPath+"images/arrow_down_off.png");
  PImage arrow_down_on = loadImage(currentSketchPath+"images/arrow_down_on.png");
  PImage arrow_left_off = loadImage(currentSketchPath+"images/arrow_left_off.png");
  PImage arrow_left_on = loadImage(currentSketchPath+"images/arrow_left_on.png");
  PImage arrow_leftup_off = loadImage(currentSketchPath+"images/arrow_leftup_off.png");
  PImage arrow_leftup_on = loadImage(currentSketchPath+"images/arrow_leftup_on.png");
  PImage arrow_leftdown_off = loadImage(currentSketchPath+"images/arrow_leftdown_off.png");
  PImage arrow_leftdown_on = loadImage(currentSketchPath+"images/arrow_leftdown_on.png");
  PImage arrow_rightup_off = loadImage(currentSketchPath+"images/arrow_rightup_off.png");
  PImage arrow_rightup_on = loadImage(currentSketchPath+"images/arrow_rightup_on.png");
  PImage arrow_rightdown_off = loadImage(currentSketchPath+"images/arrow_rightdown_off.png");
  PImage arrow_rightdown_on = loadImage(currentSketchPath+"images/arrow_rightdown_on.png");

  Object parent;
  public boolean launchComplete = false;

  private Toggle toogleRecording;
  private Knob progressKnob;

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
    StudyTwoTask currentTask = mgr.tasks.get( mgr.currentTaskNum % mgr.taskCount);
    // int index = mgr.tasks.get(mgr.runIndex).intValue();
    // println("runIndex:"+mgr.runIndex+",realindex:"+index);

    image(arrow_up_off,125,30,50,100);
    image(arrow_right_off,175,130,100,50);
    image(arrow_down_off,125,180,50,100);
    image(arrow_left_off,25,130,100,50);
    image(arrow_leftup_off,50,60,80,80);
    image(arrow_leftdown_off,50,175,80,80);
    image(arrow_rightup_off,170,60,80,80);
    image(arrow_rightdown_off,170,175,80,80);

    // if( mgr.run < 5 ){
    switch (currentTask.direction) {
      case 0:
        // do something
        image(arrow_up_on,125,30,50,100);
        break;
      case 1:
        // do something
        image(arrow_rightup_on,170,60,80,80);
        break;
      case 2:
        image(arrow_right_on,175,130,100,50);
        break;
      case 3:
        image(arrow_rightdown_on,170,175,80,80);
        break;
      case 4:
        image(arrow_down_on,125,180,50,100);
        break;
      case 5:
        image(arrow_leftdown_on,50,175,80,80);
        break;
      case 6:
        image(arrow_left_on,25,130,100,50);
        break;
      case 7:
        image(arrow_leftup_on,50,60,80,80);
        break;
      default:
        // do something
    }
    // }

  }

  void drawUI() {
  	toogleRecording = cp5.addToggle(START_RECORD)
     .setColorLabel(color(0))
     .setBroadcast(false)
     .setValue(0)
     .setPosition(50, 300)
     .setSize(50,30)
     .setBroadcast(true)
     ;
    cp5.addButton(NEXT_TASK)
     .setValue(0)
     .setPosition(50,380)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    cp5.addButton(PREVIOUS_TASK)
     .setValue(0)
     .setPosition(50,450)
     .setSize(200,19)
     .setBroadcast(true)
     ; 
    progressKnob = cp5.addKnob(CURRENT_PROGRESS)
     .setRange(0,600)
     .setValue(0)
     .setPosition(50,500)
     .setRadius(50)
     .setDragDirection(Knob.VERTICAL)
     .setLock(true)
     ;
  }
  
  private UserStudyTwoFrame() {
  }

  public UserStudyTwoFrame(Object theParent, int theWidth, int theHeight, Frame f) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
    frame = f;
  }
  public ControlP5 control() {
    return cp5;
  }
  public void toggle() {
    toogleRecording.toggle();
  }
  public void updateProgress(int num) {
    progressKnob.setValue(num);
  }
}
  
  public class MovieFrame extends PApplet {
    Object parent;
    int w, h;
    Frame frame;
    Study2Mgr mgr = null;
    Movie movie;

    public MovieFrame(){
    }

    public MovieFrame(Object theParent, int theWidth, int theHeight, Frame f) {
      parent = theParent;
      w = theWidth;
      h = theHeight;
      frame = f;
    }

    public void closeWindow() {
      frame.dispose();
    }

    public void setup() {
      movie = new Movie(this, currentSketchPath+"videos/origin.mov");
      movie.play();
      size(w, h);
      frameRate(30);
    }
    
    public void draw() {
       image(movie, 0, 0);
    } 

    public void videoInstruction(int index, int speed) {
      // println("video index :" + index);
      switch (index) {
        case 0:
          movie = new Movie(this, currentSketchPath+"videos/up.mov");
          break ;
        case 1:
          movie = new Movie(this, currentSketchPath+"videos/rightup.mov");
          break ;
        case 2:
          movie = new Movie(this, currentSketchPath+"videos/right.mov");
          break ;
        case 3:
          movie = new Movie(this, currentSketchPath+"videos/rightdown.mov");
          break ;
        case 4:
          movie = new Movie(this, currentSketchPath+"videos/down.mov");
          break ;
        case 5:
          movie = new Movie(this, currentSketchPath+"videos/leftdown.mov");
          break ;
        case 6:
          movie = new Movie(this, currentSketchPath+"videos/left.mov");
          break ;
        case 7:
          movie = new Movie(this, currentSketchPath+"videos/leftup.mov");

          break ;
        default :
          break ;
      }

      switch (speed) {
        case 0:
          movie.speed(0.5);
          break ;
        case 1:
          movie.speed(1);
          break ;
        case 2:
          movie.speed(2);
          break ;
        default :
          break ;
      }

      movie.loop();

      // println("movie: "+movie);
  }
  void movieEvent(Movie m) {
    m.read();
  }
}


