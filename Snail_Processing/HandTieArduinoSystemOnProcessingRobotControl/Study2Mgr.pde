import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import java.util.ArrayList;
import java.util.Collections;
import processing.video.*;


public class StudyTwoTask
{
  
  public int speed;
  public int texture;
  public int direction;
  public int times;

  public StudyTwoTask(int speed, int texture, int direction, int times) {
    this.speed = speed;
    this.texture = texture;
    this.direction = direction;
    this.times = times;
  }
}

// public class StudyTwoDataStructure
// {
//   int taskNumber;
//   float roll;
//   float yaw;
//   float pitch;
//   float force;

//   float [] sgs = new float[8];
//   float [] sgs_E = new float[8];
//   float [] sgs_D = new float[8];

//   public StudyTwoDataStructure(int taskNumber, float roll, float yaw, float pitch, float force, float [] sgs, float [] sgs_E, float [] sgs_D)
//   {
//     this.taskNumber = taskNumber;
//     this.roll = roll;
//     this.yaw = yaw;
//     this.pitch = pitch;
//     this.force = force;
//     this.sgs = sgs;
//     this.sgs_E = sgs_E;
//     this.sgs_D = sgs_D;

//   }
// }


public class Study2Mgr implements ControlListener, SerialListener {

  public final static String FOLDER_NAME = "StudyTwo";
  PApplet mainClass;
  ExternalSensors sensors;
	UserStudyTwoFrame userStudyFrame = null;
  MovieFrame movieFrame = null;
	boolean currentDoing = false;
  ArrayList<StudyTwoTask> tasks = new ArrayList<StudyTwoTask>();
  // ArrayList<StudyTwoDataStructure> currentDatasForOneTask = new ArrayList<StudyTwoDataStructure>();

  private SerialNotifier serialNotifier;
  public int currentTaskNum = 0;
  int currentSavedRawDataNum = 0;


  //need to change for conter balance
  //0 - 木板 
  //1 - 棉褲
  //2 - 玻璃
  int texture []= {2,0,1};

  int speed []= {0, 2};
  int direction []= {0, 1, 2, 3, 4, 5, 6, 7};
// * force.length 
  public int taskCount = speed.length * texture.length * direction.length;
  public final static int TIMES_OF_EACH_TASK = 5;

  int run = 0;
  int runIndex = 0;

  Table table;

  boolean currentRecording = false;

	public Study2Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
    this.mainClass = mainClass;
    this.sensors = mainClass.sensors;

    ArrayList<Integer> listSpeed = new ArrayList<Integer>();
    ArrayList<Integer> listDirection = new ArrayList<Integer>();

    for (int i = 0; i < speed.length; ++i) {
      listSpeed.add(speed[i]);
    }
    for (int k = 0; k < direction.length; ++k) {
      listDirection.add(direction[k]);
    }


    
    for (int j = 0; j < texture.length; ++j) {
      for (int l = 0; l < TIMES_OF_EACH_TASK; ++l) {
        Collections.shuffle(listSpeed);
        Collections.shuffle(listDirection);
        for (int i = 0; i < speed.length; ++i) {
          for (int k = 0; k < direction.length; ++k) {
            tasks.add(new StudyTwoTask(listSpeed.get(i), texture[j], listDirection.get(k),l));
          }
        }
      }
    }

    
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
          else if (theEvent.getName().equals(UserStudyTwoFrame.START_RECORD)) {
            if (currentRecording) {
              stopRecording(true);
            }
            else {
              startRecording();
            }
          }
          else if (theEvent.getName().equals(UserStudyTwoFrame.NEXT_TASK)) {
            currentTaskNum++;
            nextTask();
          }
          else if (theEvent.getName().equals(UserStudyTwoFrame.PREVIOUS_TASK)) {
            preTask();
          }
          else if (theEvent.getName().equals(UserStudyTwoFrame.CLOSEWINDOW)) {
            closeWindow();
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

    StudyTwoTask currentTask = tasks.get(currentTaskNum);
    saveTable(table, FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.texture + "/" + currentTask.speed +"/T"+ currentTask.times +"_d"+ currentTask.direction +".csv");
    currentTaskNum++;
    userStudyFrame.updateProgress(currentTaskNum);
    nextTask();
    //this means pause for some users need to relax for a min
    
  }


	void startStudy() {
		userStudyFrame = addUserStudyTwoFrame("User Study Two", 320, 720, this);
    movieFrame = addMovieFrame("User Study Two movie", 1024, 640, this);
    sensors.showWindow();
    nextTask();
    new UserProfile().startDoingStudy(3);
	}

	void endStudy(boolean fromUI)
	{
    if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
      new UserProfile().doneStudy(3);
    }
	}

  void closeWindow()
  {
    sensors.closeWindow();
    userStudyFrame.closeWindow();
    movieFrame.closeWindow();
  }

  void nextTask()
  {
    if (taskCount * TIMES_OF_EACH_TASK >= currentTaskNum) {
      endStudy(false);
    }
    // else
    // {

      // if (currentTaskNum % taskCount == 0) {
        // Collections.shuffle(tasks);
      // }

      StudyTwoTask currentTask = tasks.get(currentTaskNum);
      // int convertForceToNewton = Math.round(currentTask.force/NEWTON_TO_GRAMS);

      String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.texture + "/" + currentTask.speed +"/T"+ currentTask.times +"_d"+ currentTask.direction +".csv";

      if(!checkIfFileExist(nameOfFile))
      {
        table = new Table();
    
        // table.addColumn("taskNumber");
        table.addColumn("roll");
        table.addColumn("yaw");
        table.addColumn("pitch");
        table.addColumn("yaxis");
        table.addColumn("xaxis");
        table.addColumn("zaxis");
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
    // }

  }
  void preTask() {
    println("preTaskCalled");

    currentRecording = false;

    // if (table.getRowCount() > 0) {
    //   //just drop the rows by a new table
    //   nextTask();
    // }
    // else
    // {
      currentTaskNum--;
      StudyTwoTask currentTask = tasks.get(currentTaskNum);
      String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.texture + "/" + currentTask.speed +"/T"+ currentTask.times+"_d"+ currentTask.direction +".csv";
      table = loadTable(nameOfFile, "header, csv");

      // int [] needToDeleteRows = table.findRowIndices( Integer.toString(currentTaskNum / taskCount), "taskNumber");

      // for (int i = needToDeleteRows.length-1 ; i >= 0 ;i-- ) {
      //   table.removeRow(needToDeleteRows[i]);
      // }
      int rowCount = table.getRowCount();
      for (int i = 0; i < rowCount; ++i) {
        table.removeRow(0);
      }

      saveTable(table, nameOfFile);
      userStudyFrame.updateProgress(currentTaskNum);
      nextTask();
    // }
  }

  void saveToFile(float [] values)
  {

    // float [] datas = sensors.getRawAxis();
    TableRow newRow = table.addRow();
    // newRow.setInt("taskNumber", (int) currentTaskNum / taskCount);
    
    newRow.setFloat("roll", sensors.roll);
    newRow.setFloat("yaw", sensors.yaw);
    newRow.setFloat("pitch", sensors.pitch);

    newRow.setFloat("yaxis", sensors.yaxis);
    newRow.setFloat("xaxis", sensors.xaxis);
    newRow.setFloat("zaxis", sensors.zaxis);
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
  public final static String CLOSEWINDOW = "Close Window";

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
    StudyTwoTask currentTask = mgr.tasks.get( mgr.currentTaskNum);
    background(255);
    fill(0);
    textSize(20);
    text("Texture - " + currentTask.texture+", Speed - "+currentTask.speed, 20, 20);
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
    cp5.addButton(CLOSEWINDOW)
     .setValue(0)
     .setPosition(50,630)
     .setSize(200,19)
     .setBroadcast(true)
     ; 
    progressKnob = cp5.addKnob(CURRENT_PROGRESS)
     .setRange(0,240)
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
    Movie movie_up = new Movie(this, currentSketchPath+"videos/up.mov");
    Movie movie_rightup = new Movie(this, currentSketchPath+"videos/rightup.mov");
    Movie movie_right = new Movie(this, currentSketchPath+"videos/right.mov");
    Movie movie_rightdown = new Movie(this, currentSketchPath+"videos/rightdown.mov");
    Movie movie_down = new Movie(this, currentSketchPath+"videos/down.mov");
    Movie movie_leftdown = new Movie(this, currentSketchPath+"videos/leftdown.mov");
    Movie movie_left = new Movie(this, currentSketchPath+"videos/left.mov");
    Movie movie_leftup = new Movie(this, currentSketchPath+"videos/leftup.mov");


    public MovieFrame(){
    }

    public MovieFrame(Object theParent, int theWidth, int theHeight, Frame f) {
      parent = theParent;
      w = theWidth;
      h = theHeight;
      frame = f;
      frame.setResizable(true); 
    }

    public void closeWindow() {
      frame.dispose();
    }

    public void setup() {
      // movie = new Movie(this, currentSketchPath+"videos/origin.mov");
      // movie.play();
      size(w, h);
      frameRate(30);
    }
    
    public void draw() {
      if (movie != null) {
       image(movie, 0, 0, 1024, 640); 
      }
    } 

    public void videoInstruction(int index, int speed) {
      // println("video index :" + index);
      // movie.stop();
      switch (index) {
        case 0:
          movie = movie_up;
          break ;
        case 1:
          movie = movie_rightup;
          break ;
        case 2:
          movie = movie_right;
          break ;
        case 3:
          movie = movie_rightdown;
          break ;
        case 4:
          movie = movie_down;
          break ;
        case 5:
          movie = movie_leftdown;
          break ;
        case 6:
          movie = movie_left;
          break ;
        case 7:
          movie = movie_leftup;
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


