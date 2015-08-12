import processing.serial.*;

SGManager sgManager;
SerialManager serialManager;
UIInteractionMgr uiInteractionMgr;
AccelMgr accelMgr;
RobotControl robotControl;
GRTMgr grtMgr;
ExternalSensors sensors;
Study1Mgr study1Mgr;
Study2Mgr study2Mgr;
Pilot2Mgr pilot2Mgr;
String currentSketchPath = null;
StudyPMgr studyPMgr;

void setup() {
   currentSketchPath = sketchPath("");
   size(900, 600);
   sgManager = new SGManager();
   serialManager = new SerialManager(this);
   accelMgr = new AccelMgr();
   robotControl = new RobotControl(this);
   grtMgr = new GRTMgr(this);
   sensors = new ExternalSensors(this);
   study1Mgr = new Study1Mgr(this);
   study2Mgr = new Study2Mgr(this);
   pilot2Mgr = new Pilot2Mgr(this);
   studyPMgr = new StudyPMgr(this);

   uiInteractionMgr = new UIInteractionMgr(this);
   listenerRegistrations();
   
   serialManager.notifyAllWithDiscoveredSerialPorts();

   new UserProfile().createProfile();
}

void draw() {
   background(255, 255, 255, 0);
   sgManager.draw();
   accelMgr.draw();
   grtMgr.draw();
   sensors.draw();
   studyPMgr.draw();
   pilot2Mgr.draw();
}

void listenerRegistrations(){
   sgManager.registerToSerialNotifier(serialManager);
   uiInteractionMgr.registerToSerialNotifier(serialManager);
   // accelMgr.registerToSerialNotifier(serialManager);
   grtMgr.registerToSerialNotifier(serialManager);
   study1Mgr.registerToSerialNotifier(serialManager);

   serialManager.registerToGRTNotifier(grtMgr);
   robotControl.registerToGRTNotifier(grtMgr);
}

void keyPressed(){
   uiInteractionMgr.performKeyPress(key);
   serialManager.performKeyPress(key);
   sgManager.performKeyPress(key);
   // accelMgr.performKeyPress(key);
   robotControl.performKeyPress(key);
   grtMgr.performKeyPress(key);
   sensors.performKeyPress(key);
}

void serialEvent(Serial port){
   try {
      sensors.parseDataFromSerial(port);
   } catch (Exception e) {
      println(e.getMessage());
   }
   
   try {
      serialManager.parseDataFromSerial(port);
   } catch (Exception e) {
      println(e.getMessage());
   }
}
