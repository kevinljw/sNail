import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import java.util.ArrayList;

public class Study2Mgr implements ControlListener, SerialListener {

	UserStudyTwoFrame userStudyFrame = null;
	boolean currentDoing = false;

	public Study2Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {}

	@Override
	public void controlEvent(ControlEvent theEvent){

		if (millis()<1000) return;
	   	else if (theEvent.getName().equals(UIInteractionMgr.START_USER_STUDY_TWO)) {
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

	}


	void startStudy() {
		userStudyFrame = addUserStudyTwoFrame("User Study Two", 320, 480, this);
		sensors.showWindow();
	}

	void endStudy()
	{
		userStudyFrame.closeWindow();
		sensors.closeWindow();
	}

	public void registerToSerialNotifier(SerialNotifier notifier){
	}
	@Override
	public void removeToSerialNotifier(SerialNotifier notifier)
	{
	}
	@Override
	public void updateDiscoveredSerialPorts(String [] portNames){}
	@Override
	public void updateAnalogVals(float [] values)
	{

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



public class UserStudyTwoFrame extends PApplet {


	public final static String START_RECORD = "Start Recording";
	public final static String STOP_RECORD = "Stop Recording";
	public final static String NEXT_TASK = "Next Task";
	public final static String PREVIOUS_TASK = "Previous Task";

  int w, h;
  Frame frame;

  Study2Mgr mgr = null;
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
  

  
}