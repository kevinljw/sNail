import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import java.util.ArrayList;
import java.util.Collections;
import processing.video.*;

public class Study2Mgr implements ControlListener, SerialListener {

  PApplet mainClass;
  ExternalSensors sensors;
	UserStudyTwoFrame userStudyFrame = null;
  MovieFrame movieFrame = null;
	boolean currentDoing = false;
  ArrayList<Integer> tasks = new ArrayList<Integer>();

  int run = 0;
  int runIndex = 0;

	public Study2Mgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
    this.mainClass = mainClass;
    this.sensors = mainClass.sensors;
    for(int i = 0; i < 8; i++){
        tasks.add(i);
    }

    Collections.shuffle(tasks);
  }

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

    if (userStudyFrame != null) {
          if (!userStudyFrame.launchComplete)  return;
          else if (theEvent.getName().equals(UserStudyOneFrame.START_RECORD)) {

          }
          else if (theEvent.getName().equals(UserStudyOneFrame.NEXT_TASK)) {
            nextTask();
          }
          else if (theEvent.getName().equals(UserStudyOneFrame.PREVIOUS_TASK)) {
          }
        }

	}


	void startStudy() {
		userStudyFrame = addUserStudyTwoFrame("User Study Two", 320, 720, this);
    movieFrame = addMovieFrame("User Study Two movie", 550, 400, this);
	}

	void endStudy()
	{
		userStudyFrame.closeWindow();
    movieFrame.closeWindow();
	}

  void nextTask()
  {
    if( runIndex < 7 && run < 5 ){
      runIndex++;
      movieFrame.video(tasks.get(runIndex).intValue());
    }
    else{
      run++;
      runIndex = 0;
      Collections.shuffle(tasks);
    }

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
    int index = mgr.tasks.get(mgr.runIndex).intValue();
    println("runIndex:"+mgr.runIndex+",realindex:"+index);

    image(arrow_up_off,125,30,50,100);
    image(arrow_right_off,175,130,100,50);
    image(arrow_down_off,125,180,50,100);
    image(arrow_left_off,25,130,100,50);
    image(arrow_leftup_off,50,60,80,80);
    image(arrow_leftdown_off,50,175,80,80);
    image(arrow_rightup_off,170,60,80,80);
    image(arrow_rightdown_off,170,175,80,80);

    if( mgr.run < 5 ){
      switch (index) {
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
          image(arrow_leftup_off,50,60,80,80);
          break;
        default:
          // do something
      }
    }

  }

  void drawUI() {
  	cp5.addButton(START_RECORD)
     .setValue(0)
     .setPosition(50,350)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    cp5.addButton(STOP_RECORD)
     .setValue(0)
     .setPosition(50,400)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    cp5.addButton(NEXT_TASK)
     .setValue(0)
     .setPosition(50,450)
     .setSize(200,19)
     .setBroadcast(true)
     ;
    cp5.addButton(PREVIOUS_TASK)
     .setValue(0)
     .setPosition(50,500)
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

    public void video(int index) {
      switch (index) {
        case 0:
          movie = new Movie(this, currentSketchPath+"videos/up.mov");
          movie.play();
          break ;
        case 1:
          movie = new Movie(this, currentSketchPath+"videos/rightup.mov");
          movie.play();
          break ;
        case 2:
          movie = new Movie(this, currentSketchPath+"videos/right.mov");
          movie.play();
          break ;
        case 3:
          movie = new Movie(this, currentSketchPath+"videos/rightdown.mov");
          movie.play();
          break ;
        case 4:
          movie = new Movie(this, currentSketchPath+"videos/down.mov");
          movie.play();
          break ;
        case 5:
          movie = new Movie(this, currentSketchPath+"videos/leftdown.mov");
          movie.play();
          break ;
        case 6:
          movie = new Movie(this, currentSketchPath+"videos/left.mov");
          movie.play();
          break ;
        case 7:
          movie = new Movie(this, currentSketchPath+"videos/leftup.mov");
          movie.play();

          break ;
        default :
      }
    }

  }


