import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import java.util.ArrayList;


public class PilotTwoTask
{
	
	public int direction; // 8 direction starting from up -> up_right ,0...7
	public int force; // 3 different forces, normal, light, heavy, 0...2

	public PilotTwoTask(int direction, int force) {
		this.direction = direction;
		this.force = force;
	}
}


public class Pilot2Mgr implements ControlListener {

	public final static String FOLDER_NAME = "PilotTwo";
	public final static int AMOUNT_OF_DIRECTION = 8;
	public final static int AMOUNT_OF_FORCE = 3;

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
	public final static int TIMES_OF_EACH_TASK = 3;
	int taskCount = AMOUNT_OF_DIRECTION * AMOUNT_OF_FORCE;
	ArrayList<PilotTwoTask> tasks = new ArrayList<PilotTwoTask>();

	//external window
	PilotTwoFrame userStudyFrame = null;


	public Pilot2Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
		this.mainClass = mainClass;
		this.sensors = mainClass.sensors;

		for (int i = 0; i < AMOUNT_OF_DIRECTION; ++i) {
			for (int j = 0; j < AMOUNT_OF_FORCE; ++j) {
				tasks.add(new PilotTwoTask(i, j));
			}
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
      		else if (theEvent.getName().equals(PilotTwoFrame.START_RECORD)) {
	      		if (currentRecording) {
	      			stopRecording();
	      		}
	      		else {
	      			startRecording();
	      		}
	      	}
	      	else if (theEvent.getName().equals(PilotTwoFrame.NEXT_TASK)) {
	      		currentTaskNum++;
	      		nextTask();
	      	}
	      	else if (theEvent.getName().equals(PilotTwoFrame.PREVIOUS_TASK)) {
	      		preTask();
	      	}
      	}
	}


	void startStudy() {
		userStudyFrame = addPilotTwoFrame("Pilot Study Two", 320, 480, this);
		//init the first time, wont receiving data immediately, need to press startRecording
		currentDoing = true;
		sensors.showWindow();
		nextTask();
		UserProfile.createProfile();
	}

	void endStudy()
	{
		if (currentRecording) {
			stopRecording();
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

		PilotTwoTask currentTask = tasks.get(currentTaskNum % taskCount);
		saveTable(table, FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force+"/"+ currentTask.direction +".csv");
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

		PilotTwoTask currentTask = tasks.get(currentTaskNum % taskCount);
		String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force+"/"+ currentTask.direction +".csv";

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
			PilotTwoTask currentTask = tasks.get(currentTaskNum % taskCount);
			String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + currentTask.force+"/"+ currentTask.direction +".csv";
			table = loadTable(nameOfFile, "header, csv");

			int [] needToDeleteRows = table.findRowIndices( Integer.toString(currentTaskNum / taskCount), "taskNumber");

			for (int i = needToDeleteRows.length-1 ; i >= 0 ;i-- ) {
				table.removeRow(needToDeleteRows[i]);
			}

			saveTable(table, nameOfFile);
			userStudyFrame.updateProgress(currentTaskNum);
		}		
	}

	void saveToFile()
	{
		println("saveToFile!!");

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




PilotTwoFrame addPilotTwoFrame(String theName, int theWidth, int theHeight, Pilot2Mgr mgr) {
  Frame f = new Frame(theName);
  PilotTwoFrame p = new PilotTwoFrame(this, theWidth, theHeight, f);
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

public class PilotTwoFrame extends PApplet {


	public final static String START_RECORD = "Start Recording";
	// public final static String STOP_RECORD = "Stop Recording";
	public final static String NEXT_TASK = "Next Task";
	public final static String PREVIOUS_TASK = "Previous Task";
	public final static String CURRENT_PROGRESS = "Current Progress";

  int w, h;
  Frame frame;

  Pilot2Mgr mgr = null;
  ControlP5 cp5;

  Object parent;

  private Knob progressKnob;
  private Toggle toogleRecording;
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
  	toogleRecording = cp5.addToggle(START_RECORD)
     .setColorLabel(color(0))
     .setBroadcast(false)
     .setValue(0)
     .setPosition(width*0.85, height*0.8)
     .setSize(50,30)
     .setBroadcast(true)
     ;
    // cp5.addButton(NEXT_TASK)
    //  .setValue(0)
    //  .setPosition(50,150)
    //  .setSize(200,19)
    //  .setBroadcast(true)
    //  ;
    cp5.addButton(PREVIOUS_TASK)
     .setValue(0)
     .setPosition(50,200)
     .setSize(200,19)
     .setBroadcast(true)
     ; 
    progressKnob = cp5.addKnob(CURRENT_PROGRESS)
     .setRange(0,72)
     .setValue(0)
     .setPosition(100,250)
     .setRadius(50)
     .setDragDirection(Knob.VERTICAL)
     .setLock(true)
     ;
  }
  
  private PilotTwoFrame() {
  }

  public PilotTwoFrame(Object theParent, int theWidth, int theHeight, Frame f) {
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