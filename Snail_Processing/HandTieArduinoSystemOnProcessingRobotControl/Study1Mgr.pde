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
	public final static float NEWTON_TO_GRAMS = 100.5;
	public final static int AMOUNT_OF_RECEIVED_RAW_DATA = 50;
	float pitch []= {65, 45, 25, 15};
	float roll []= {-15, 0, 15, 45, 90};
	float force []= {1, 2, 3, 4, 5};
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
	      		startRecording();
	      	}
	      	else if (theEvent.getName().equals(UserStudyOneFrame.STOP_RECORD)) {
	      		stopRecording();
	      	}
	      	else if (theEvent.getName().equals(UserStudyOneFrame.NEXT_TASK)) {
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
		UserProfile.createProfile();
	}

	void endStudy()
	{
		if (currentRecording) {
			stopRecording();
		}
		userStudyFrame.closeWindow();
		sensors.closeWindow();
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

	void nextTask() {

		table = new Table();
  
		table.addColumn("userID");
		table.addColumn("roll");
		table.addColumn("yaw");
		table.addColumn("pitch");
		table.addColumn("force");
		for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
			table.addColumn("SG" + i);	
		}
		currentTaskNum++;
		currentSavedRawDataNum = 0;
	}

	void preTask() {
		currentTaskNum--;
	}


	boolean isApplicableForSaving(){
		StudyOneTask currentTask = tasks.get(currentTaskNum);
		if (!toleranceCalculation(sensors.roll, currentTask.roll, 0)){ 
			return false; 
		}
		if (!toleranceCalculation(sensors.pitch, currentTask.pitch, 0)) { 
			return false; 
		}
		if (!toleranceCalculation(sensors.weight, currentTask.force, 1)) { 
			return false; 
		}

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
			saveTable(table, UserProfile.USER_ID + "/StudyOne/" +  currentTaskNum +".csv");
			nextTask();
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
	public final static String STOP_RECORD = "Stop Recording";
	public final static String NEXT_TASK = "Next Task";
	public final static String PREVIOUS_TASK = "Previous Task";

  int w, h;
  Frame frame;

  Study1Mgr mgr = null;
  ControlP5 cp5;

  Object parent;
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
  	cp5.addButton(START_RECORD)
     .setValue(0)
     .setPosition(50,50)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    cp5.addButton(STOP_RECORD)
     .setValue(0)
     .setPosition(50,100)
     .setSize(200,19)
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
  

  
}