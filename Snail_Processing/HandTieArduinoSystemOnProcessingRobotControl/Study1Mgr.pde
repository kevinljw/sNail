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

	public final static String FOLDER_NAME = "StudyOne";

	//holding other class object
	PApplet mainClass;
	public ExternalSensors sensors;

	//self variable
	private SerialNotifier serialNotifier;
	boolean currentDoing = false;
	boolean currentRecording = false;
	int currentTaskNum = 0;
	int currentSavedRawDataNum = 0;
	Table table;

	//task
	public final static float TOLERANCE_OF_ROLL_YAW_PITCH = 5;
	public final static float TOLERANCE_OF_FORCE = 5;
	public final static float NEWTON_TO_GRAMS = 101.971621298;
	public final static int AMOUNT_OF_RECEIVED_RAW_DATA = 50;
	public final static int TIMES_OF_EACH_TASK = 5;

	float force []= {0.4, 0.8, 1.2, 1.6, 2};
	int taskCount = 0;

	ArrayList<ArrayList<StudyOneTask>> tasks = new ArrayList<ArrayList<StudyOneTask>>();
	ArrayList<StudyOneTask> template = new ArrayList<StudyOneTask>();
	//external window
	UserStudyOneFrame userStudyFrame = null;


	public Study1Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
		this.mainClass = mainClass;
		this.sensors = mainClass.sensors;
		templateInit();


		for (int i = 0; i < TIMES_OF_EACH_TASK; ++i) {
			tasks.add(template);
			// Collections.shuffle(tasks.get(i));
		}
		taskCount = template.size();
	}

	@Override
	public void controlEvent(ControlEvent theEvent){
		//others
		if (millis()<1000) return;
	   	else if (theEvent.getName().equals(UIInteractionMgr.START_USER_STUDY_ONE)) {
      		if (currentDoing) {
      			endStudy(true);
      		}
      		else{
      			startStudy();
      		}
      		return;	
      	}
      	//from UserStudyOneFrame
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
	      	else if (theEvent.getName().equals(UserStudyOneFrame.WINDOWCLOSE)) {
	      		closeWindows();
	      	}
      	}
	}
	void templateInit()
	{
		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(15, -15, this.force[k] * NEWTON_TO_GRAMS ));
		}

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(15, 0, this.force[k] * NEWTON_TO_GRAMS ));
		}

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(15, 15, this.force[k] * NEWTON_TO_GRAMS ));
		}

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(15, 45, this.force[k] * NEWTON_TO_GRAMS ));
		}

		// for (int k = 0; k < this.force.length; ++k) {
		// 	template.add(new StudyOneTask(15, 90, this.force[k] * NEWTON_TO_GRAMS ));
		// }

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(25, 0, this.force[k] * NEWTON_TO_GRAMS ));
		}

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(45, -15, this.force[k] * NEWTON_TO_GRAMS ));
		}

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(45, 0, this.force[k] * NEWTON_TO_GRAMS ));
		}

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(45, 15, this.force[k] * NEWTON_TO_GRAMS ));
		}

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(45, 45, this.force[k] * NEWTON_TO_GRAMS ));
		}

		// for (int k = 0; k < this.force.length; ++k) {
		// 	template.add(new StudyOneTask(45, 90, this.force[k] * NEWTON_TO_GRAMS ));
		// }

		for (int k = 0; k < this.force.length; ++k) {
			template.add(new StudyOneTask(65, 0, this.force[k] * NEWTON_TO_GRAMS ));
		}

		// for (int k = 0; k < this.force.length; ++k) {
		// 	template.add(new StudyOneTask(90, 0, this.force[k] * NEWTON_TO_GRAMS ));
		// }

	}

	void startStudy() {
		userStudyFrame = addUserStudyOneFrame("User Study One", 640, 480, this);
		sensors.showWindow();
		currentDoing = true;
		//init the first time, wont receiving data immediately, need to press startRecording
		nextTask();
		new UserProfile().startDoingStudy(2);
	}

	void endStudy(boolean fromUI)
	{
		if (currentRecording) {
			stopRecording(fromUI);
		}
		// println("currentTaskNum: "+currentTaskNum);
		// println("taskCount: "+taskCount);
		if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
			new UserProfile().doneStudy(2);
		}


		currentDoing = false;
		// don't close the windows if the error occur, then still have chance for preTask
		
	}
	void closeWindows()
	{
		sensors.closeWindow();
		userStudyFrame.closeWindow();
	}

	void startRecording()
	{
		currentRecording = true;
	}

	void stopRecording(boolean fromUI)
	{
		if (fromUI == false && currentRecording == true) {
			userStudyFrame.toggle();	
		}
		currentRecording = false;
		//this means pause for some users need to relax for a min
		
	}

	void nextTask() {

		//check if the study is done or not, if so close the window
		if (taskCount * TIMES_OF_EACH_TASK == currentTaskNum) {
			endStudy(false);
		}
		// StudyOneTask currentTask = tasks.get(currentTaskNum % taskCount);
		float convertForceToNewton = (float)Math.round(currentTask().force/NEWTON_TO_GRAMS * 10) /10;
		println("convertForceToNewton: "+convertForceToNewton);
		String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + Float.toString(convertForceToNewton) +"/T"+ Integer.toString(currentTaskNum / taskCount)  +"_p"+Math.round(currentTask().pitch)+"_r"+ Math.round(currentTask().roll) +".csv";
		// println(nameOfFile);
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
		userStudyFrame.setFrameInstruct(currentTask().pitch, currentTask().roll, currentTask().force);
		sensors.setCurrentInstruct(currentTask().pitch, currentTask().roll,0.0f);
		userStudyFrame.updateProgress(currentTaskNum);
	}

	void preTask() {
		

		
		stopRecording(false);

		// if (table.getRowCount() > 0) {
		// 	//just drop the rows by a new table
		// 	nextTask();
		// }
		// else
		// {
			currentTaskNum--;

			// StudyOneTask currentTask = tasks.get(currentTaskNum % taskCount);
			float convertForceToNewton = (float)Math.round(currentTask().force/NEWTON_TO_GRAMS * 10) /10;

			String nameOfFile = FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + Float.toString(convertForceToNewton) +"/T"+ Integer.toString(currentTaskNum / taskCount)  +"_p"+Math.round(currentTask().pitch)+"_r"+ Math.round(currentTask().roll) +".csv";
			println("Remove nameOfFile now: "+nameOfFile);
			table = loadTable(nameOfFile, "header, csv");

			// for ( int i = 0; i < AMOUNT_OF_RECEIVED_RAW_DATA; i++ ) {
			// 	table.removeRow(table.getRowCount() -1 );
			// }

			// int [] needToDeleteRows = table.findRowIndices( Integer.toString(currentTaskNum / taskCount), "taskNumber");
			int rowCount = table.getRowCount();
			for (int i = 0; i < rowCount; ++i) {
				table.removeRow(0);
			}

			saveTable(table, nameOfFile);

			userStudyFrame.setFrameInstruct(currentTask().pitch, currentTask().roll, currentTask().force);
			sensors.setCurrentInstruct(currentTask().pitch, currentTask().roll,0.0f);
			userStudyFrame.updateProgress(currentTaskNum);
		// }		
	}


	boolean isApplicableForSaving(){

		// StudyOneTask currentTask = tasks.get(currentTaskNum % taskCount);

		// float[] datas = sensors.getRollYawPitch();
		// println("datas[0]: "+datas[0] + "datas[2]: "+datas[2]);
		// if (toleranceCalculation(datas[0], currentTask.roll, 0) == false){ 
		// 	sensors.setCurrentInstruct(currentTask.pitch, currentTask.roll, currentTask.force);
		// 	return false; 
		// }
		// if (toleranceCalculation(datas[2], currentTask.pitch, 0) == false) { 
		// 	sensors.setCurrentInstruct(currentTask.pitch, currentTask.roll, currentTask.force);
		// 	return false; 
		// }
		if (toleranceCalculation(sensors.force, currentTask().force, 1)  == false) { 
			// sensors.setCurrentInstruct(currentTask().pitch, currentTask().roll, currentTask().force);
			return false; 
		}

		println("isApplicableForSaving");
		// sensors.cleanInstruct();
		return true;
	}

	boolean toleranceCalculation(float values, float traget, int type)
	{
		//type 0 - roll yaw pitch, 1 = force
		//
		if (type == 0) {
			if ((traget + TOLERANCE_OF_ROLL_YAW_PITCH >= values) && (traget - TOLERANCE_OF_ROLL_YAW_PITCH <= values)) {
				return true;	
			}
			else
			{
				return false;
			}	
		}
		else if (type == 1) {
			if ((traget + TOLERANCE_OF_FORCE >= values) && (traget - TOLERANCE_OF_FORCE <= values)) {
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
		println("saveToFile");

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

		currentSavedRawDataNum++;

		println("currentSavedRawDataNum: "+currentSavedRawDataNum);
		if (currentSavedRawDataNum == AMOUNT_OF_RECEIVED_RAW_DATA) {

			// StudyOneTask currentTask = tasks.get(currentTaskNum % taskCount);
			float convertForceToNewton = (float)Math.round(currentTask().force/NEWTON_TO_GRAMS * 10) /10;
			saveTable(table, FOLDER_NAME + "/usr_" + UserProfile.USER_ID + "/" + Float.toString(convertForceToNewton) +"/T"+ Integer.toString(currentTaskNum / taskCount)  +"_p"+Math.round(currentTask().pitch)+"_r"+ Math.round(currentTask().roll) +".csv");
			currentTaskNum++;
			userStudyFrame.updateProgress(currentTaskNum);

			currentSavedRawDataNum = 0;
			stopRecording(false);
			nextTask();

			println("AMOUNT_OF_RECEIVED_RAW_DATA !!!!!");
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

	StudyOneTask currentTask()
  	{
    	StudyOneTask currentTask = tasks.get((int) currentTaskNum / taskCount).get(currentTaskNum % taskCount);
   		return currentTask;
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
		//&& isApplicableForSaving()
		if (userStudyFrame != null) {
			if (currentRecording && isApplicableForSaving()) {
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
  public final static String WINDOWCLOSE = "Windows Close";

  PImage currentShowImage_pitch = null;
  PImage currentShowImage_roll = null;

  int w, h;
  Frame frame;

  Study1Mgr mgr = null;
  ControlP5 cp5;

  Object parent;

  private Knob progressKnob;
  private Toggle toogleRecording;
  public boolean launchComplete = false;

  private float instruct_Pitch = 0.0f;
  private float instruct_Roll = 0.0f;
  private float instruct_Force = 0.0f;

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
  	background(255);
  	fill(0);

  	if (currentShowImage_pitch != null) {
  		image(currentShowImage_pitch,280,0,180,180);
  		textSize(12);
  		text("Pitch: " + instruct_Pitch, 370, 180);
  	}
  	if (currentShowImage_roll != null) {
  		image(currentShowImage_roll,280,200,180,180);
  		textSize(12);
  		text("Roll: " + instruct_Roll, 370, 400);
  	}

  	translate(0, 0);
	// float elongRatio = (float)sensorclass.force/sensorclass.instruct_force;
	// fill(getHeatmapRGB(elongRatio));
	fill(255, 255, 0);
  	rect(500, height*0.8, 30, -instruct_Force * 0.5);

	fill(0, 255, 0);
  	rect(500, height*0.8, 30, -mgr.sensors.force * 0.5);

  	

  	fill(0);
  	text("Current Force: " + mgr.sensors.force, 450, height*0.9);
  	text("Instruct Force: " + instruct_Force, 450, height*0.95);

  	// mgr.sensors;
  	  
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
    cp5.addButton(WINDOWCLOSE)
     .setValue(0)
     .setPosition(50,400)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    progressKnob = cp5.addKnob(CURRENT_PROGRESS)
     .setRange(0,250)
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

  public void setFrameInstruct(float pitch, float roll, float force){
  	instruct_Pitch = pitch;
  	instruct_Roll = roll;
	instruct_Force = force;

  	// println("file:" +currentSketchPath+"images/p"+ Math.round(pitch) +".jpg");
  	currentShowImage_pitch = loadImage(currentSketchPath+"images/p"+ Math.round(pitch) +".jpg");
  	currentShowImage_roll = loadImage(currentSketchPath+"images/r"+ Math.round(roll) +".jpg");

  }
  

  
}