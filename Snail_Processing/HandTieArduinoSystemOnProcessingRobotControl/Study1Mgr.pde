import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import java.util.ArrayList;


public class StudyOneTask
{
	
	public float pitch;
	public float roll;
	public float force;

	public StudyOneTask(float pitch, float roll, float force) {
		this.pitch = pitch;
		this.roll = roll;
		this.force = force;
	}
}


public class Study1Mgr implements ControlListener, SerialListener {

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
	public final static float TOLERANCE_OF_ROLL_YAW_PITCH = 5;
	public final static float TOLERANCE_OF_FORCE = 20;
	public final static float NEWTON_TO_GRAMS = 101.971621298;
	public final static int AMOUNT_OF_RECEIVED_RAW_DATA = 50;
	public final static int TIMES_OF_EACH_TASK = 3;
	float pitch []= {65, 45, 25, 15};
	float roll []= {-15, 0, 15, 45, 90};
	float force []= {1, 2, 3, 4, 5};
	int taskCount = pitch.length * roll.length * force.length;
	ArrayList<StudyOneTask> tasks = new ArrayList<StudyOneTask>();

	//external window
	UserStudyOneFrame userStudyFrame = null;


	public Study1Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
		this.mainClass = mainClass;
		this.sensors = mainClass.sensors;

		for (int i = 0; i < this.pitch.length; ++i) {
			for (int j = 0; j < this.roll.length; ++j) {
				for (int k = 0; k < this.force.length; ++k) {
					tasks.add(new StudyOneTask(this.pitch[i], this.roll[j], this.force[k] * NEWTON_TO_GRAMS ));
				}
			}
		}
	}

	@Override
	public void controlEvent(ControlEvent theEvent){
		//others
		if (millis()<1000) return;
	   	else if (theEvent.getName().equals(UIInteractionMgr.START_USER_STUDY_ONE)) {
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
      	//from UserStudyOneFrame
      	if (userStudyFrame != null) {
      		if (!userStudyFrame.launchComplete)  return;
      		else if (theEvent.getName().equals(UserStudyOneFrame.START_RECORD)) {
	      		if (currentRecording) {
	      			stopRecording();
	      		}
	      		else {
	      			startRecording();
	      		}
	      		
	      	}
	      	// else if (theEvent.getName().equals(UserStudyOneFrame.STOP_RECORD)) {
	      	// 	stopRecording();
	      	// }
	      	else if (theEvent.getName().equals(UserStudyOneFrame.NEXT_TASK)) {
	      		currentTaskNum++;
	      		nextTask();
	      	}
	      	else if (theEvent.getName().equals(UserStudyOneFrame.PREVIOUS_TASK)) {
	      		preTask();
	      	}
      	}
	}


	void startStudy() {
		userStudyFrame = addUserStudyOneFrame("User Study One", 320, 480, this);
		sensors.showWindow();
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
		userStudyFrame.closeWindow();
	}

	void startRecording()
	{
		currentRecording = true;
	}

	void stopRecording()
	{
		userStudyFrame.toggle();
		currentRecording = false;
		//this means pause for some users need to relax for a min
		
	}

	void nextTask() {

		if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
			endStudy();
		}
		String nameOfFile = UserProfile.USER_ID + "/StudyOne/" +  currentTaskNum % taskCount +".csv";

		if(!checkIfFileExist(nameOfFile))
		{
			table = new Table();
  
			table.addColumn("userID");
			table.addColumn("roll");
			table.addColumn("yaw");
			table.addColumn("pitch");
			table.addColumn("force");
			for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
				table.addColumn("SG" + i);	
			}
		}
		else{
			table = loadTable(nameOfFile, "header, csv");
		}
		StudyOneTask currentTask = tasks.get(currentTaskNum % taskCount);
		sensors.setCurrentInstruct(currentTask.pitch, currentTask.roll);
	}

	void preTask() {
		

		
		stopRecording();

		if (table.getRowCount() > 0) {
			//just drop the rows by a new table
			nextTask();
		}
		else
		{
			currentTaskNum--;
			String nameOfFile = UserProfile.USER_ID + "/StudyOne/" +  currentTaskNum % taskCount +".csv";
			table = loadTable(nameOfFile, "header, csv");

			for ( int i = 0; i < AMOUNT_OF_RECEIVED_RAW_DATA; i++ ) {
				table.removeRow(table.getRowCount() -1 );  // Removes the first row	
			}

			saveTable(table, nameOfFile);
			userStudyFrame.updateProgress(currentTaskNum);
		}		
	}


	boolean isApplicableForSaving(){
		StudyOneTask currentTask = tasks.get(currentTaskNum % taskCount);
		if (!toleranceCalculation(sensors.roll, currentTask.roll, 0)){ 
			sensors.setCurrentInstruct(currentTask.pitch, currentTask.roll);
			return false; 
		}
		if (!toleranceCalculation(sensors.pitch, currentTask.pitch, 0)) { 
			sensors.setCurrentInstruct(currentTask.pitch, currentTask.roll);
			return false; 
		}
		if (!toleranceCalculation(sensors.weight, currentTask.force, 1)) { 
			sensors.setCurrentInstruct(currentTask.pitch, currentTask.roll);
			return false; 
		}

		sensors.cleanInstruct();
		return true;
	}

	boolean toleranceCalculation(float values, float traget, int type)
	{
		//type 0 - roll yaw pitch, 1 = force
		//
		if (type == 0) {
			if ((traget + TOLERANCE_OF_ROLL_YAW_PITCH >= values) || (traget - TOLERANCE_OF_ROLL_YAW_PITCH <= values)) {
				return true;	
			}
			else
			{
				return false;
			}	
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
		newRow.setFloat("roll", sensors.roll);
		newRow.setFloat("yaw", sensors.yaw);
		newRow.setFloat("pitch", sensors.pitch);
		newRow.setFloat("weight", sensors.weight);

		for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
			newRow.setFloat("SG" + i, values[i]);
		}
		currentSavedRawDataNum++;
		if (currentSavedRawDataNum == AMOUNT_OF_RECEIVED_RAW_DATA) {
			saveTable(table, UserProfile.USER_ID + "/StudyOne/" +  currentTaskNum % taskCount +".csv");
			currentTaskNum++;
			userStudyFrame.updateProgress(currentTaskNum);

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

	//impelments -- SerialListener
	public void registerToSerialNotifier(SerialNotifier notifier){
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
		if (isApplicableForSaving() && currentRecording) {
			saveToFile(values);
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




UserStudyOneFrame addUserStudyOneFrame(String theName, int theWidth, int theHeight, Study1Mgr mgr) {
  Frame f = new Frame(theName);
  UserStudyOneFrame p = new UserStudyOneFrame(this, theWidth, theHeight, f);
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

public class UserStudyOneFrame extends PApplet {


	public final static String START_RECORD = "Start Recording";
	// public final static String STOP_RECORD = "Stop Recording";
	public final static String NEXT_TASK = "Next Task";
	public final static String PREVIOUS_TASK = "Previous Task";
	public final static String CURRENT_PROGRESS = "Current Progress";

  int w, h;
  Frame frame;

  Study1Mgr mgr = null;
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
    cp5.addButton(NEXT_TASK)
     .setValue(0)
     .setPosition(50,150)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    cp5.addButton(PREVIOUS_TASK)
     .setValue(0)
     .setPosition(50,200)
     .setSize(200,19)
     .setBroadcast(true)
     ; 
    progressKnob = cp5.addKnob(CURRENT_PROGRESS)
     .setRange(0,300)
     .setValue(0)
     .setPosition(100,250)
     .setRadius(50)
     .setDragDirection(Knob.VERTICAL)
     .setLock(true)
     ;
  }
  
  private UserStudyOneFrame() {
  }

  public UserStudyOneFrame(Object theParent, int theWidth, int theHeight, Frame f) {
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

  public void toggle() {
  	toogleRecording.toggle();
  }
  

  
}