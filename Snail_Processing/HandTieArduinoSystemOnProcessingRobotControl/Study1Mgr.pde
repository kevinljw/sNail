import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

public class Study1Mgr implements ControlListener, SerialListener {

	//holding other class object
	PApplet mainClass;
	ExternalSensors sensors;

	private StrainGauge [] gauges = new StrainGauge[SGManager.NUM_OF_GAUGES];
	private SerialNotifier serialNotifier;

	boolean currentDoing = false;

	//external window
	UserStudyOneFrame userStudyFrame = null;


	public Study1Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
		this.mainClass = mainClass;
		this.sensors = mainClass.sensors;
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
	      		println("START_RECORD");
	      	}
	      	else if (theEvent.getName().equals(UserStudyOneFrame.STOP_RECORD)) {
	      		println("STOP_RECORD");
	      	}
	      	else if (theEvent.getName().equals(UserStudyOneFrame.NEXT_TASK)) {
	      		println("NEXT_TASK");
	      	}
	      	else if (theEvent.getName().equals(UserStudyOneFrame.PREVIOUS_TASK)) {
	      		println("PREVIOUS_TASK");
	      	}
      	}
	}

	void startStudy() {
		userStudyFrame = addUserStudyOneFrame("User Study One", 320, 480, this);
	}

	void endStudy()
	{
		userStudyFrame.closeWindow();
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
		// for (int i = 0; i < axis.length; ++i) {
		// 	axis[i].setNewValue(values[i+SGManager.NUM_OF_GAUGES]);
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