import processing.opengl.*;
import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

public class ExternalSensors implements ControlListener{
	
	final static int SERIAL_PORT_BAUD_RATE = 57600;
	private static final boolean ENABLE_9DOF = true;
	private static final boolean ENABLE_FORCE = true;

	boolean display9DOF = false;
	boolean displayWeight = false;

	public float roll = 0.0;
	public float yaw = 0.0;
	public float pitch = 0.0;
	public float instruct_roll = 0.0;
	public float instruct_yaw = -15.0;
	public float instruct_pitch = 45.0;
	public float yawOffset = 0.0f;
  	public float rollOffset = 0.0f;
  	public float pitchOffset = 0.0f;
   

   public float force = 0.0;
   public float instruct_force = 1.0;
	
	
	boolean showAnotherWindow = false;
	ControlFrame cf = null;

	PApplet mainClass;
	Serial sensorsPort;

	public float[] getRollYawPitch() {
		float[] datas = new float[3];

		datas[0] = roll - rollOffset;
		datas[1] = yaw - yawOffset;
		datas[2] = -(pitch - pitchOffset);

		return datas;
	}

	public ExternalSensors(PApplet mainClass){
      this.mainClass = mainClass;
	}


	private void connectToSerial(int portNumber){
		String portName = Serial.list()[portNumber];
		connectToSerial(portName);
	}

	private void connectToSerial(String portName){
	   println();
	   println("LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
	   println("  -> Using port : " + portName);
	   disconnectSerial();
	   try {
	      sensorsPort = new Serial(mainClass, portName, SERIAL_PORT_BAUD_RATE);
	      sensorsPort.bufferUntil(10);    //newline
	   } catch (Exception e) {
	      println("connectToSerial : " + e.getMessage());
	   }
	}
	private void disconnectSerial(){
      try {
         sensorsPort.clear();
         sensorsPort.stop();
      } catch (Exception e) {
         println("disconnectSerial : " + e.getMessage());
      }
   }

	@Override
	public void controlEvent(ControlEvent theEvent){
		if (millis()<1000) return;
		if (theEvent.getName().equals(UIInteractionMgr.DROPDOWN_SENSORS_SERIAL_LIST)){
        	connectToSerial((int)(theEvent.getValue()));
      	}
      	else if (theEvent.getName().equals(UIInteractionMgr.ENABLE_9DOF_DISPLAY)) {
      		display9DOF = !display9DOF;
      	}
      	else if (theEvent.getName().equals(UIInteractionMgr.ENABLE_WEIGHT_DISPLAY)) {
      		displayWeight = !displayWeight;
      	}
	}

	public void parseDataFromSerial(Serial port) throws Exception{
      if (port.equals(sensorsPort)) {
         parseDataFromSensors(port);
      }
	}

	private void parseDataFromSensors(Serial port) throws Exception{
		float [] parsedData = parseSpaceSeparatedData(port);
		int i = 0;

		//updating values
		if (ENABLE_9DOF) {
			yaw = parsedData[i++];
			pitch = parsedData[i++];
			roll = parsedData[i++];
		}
		
		if (ENABLE_FORCE) {
			force = parsedData[i++];	
		}
	}

	private float [] parseSpaceSeparatedData(Serial port) throws Exception{
      String buf = port.readString();
      // print(buf);
      String [] bufSplitArr = buf.split(" ");
      float [] parsedDataArr = new float[bufSplitArr.length];

      for (int i = 0; i < bufSplitArr.length; ++i){
         parsedDataArr[i] = Float.parseFloat(bufSplitArr[i]);
         // print(parsedDataArr[i]+" ");
      }

      return parsedDataArr;
   }

	public void performKeyPress(char k){
		switch (k) {
		    case 'a':  // Align screen with Razor
		      if (showAnotherWindow) {
		      	yawOffset = yaw;
		      }
              if (showAnotherWindow) {
                rollOffset = roll;
              }
              if (showAnotherWindow) {
                pitchOffset = pitch;
              }
                      
      }
	}

	public void draw(){
	}


	public void showWindow() {
		cf = addControlFrame("showingSensorData", 640,480, this);
		showAnotherWindow = true;	
	}

	public void closeWindow() {
		cf.closeWindow();
		showAnotherWindow = false;	
	}


	public void setCurrentInstruct(float pitch, float roll, float force) {
		this.instruct_pitch = pitch;
		this.instruct_roll = roll;
		this.instruct_force = force;
	}

	public void cleanInstruct() {
		cf.cleanInstruct();	
	}
}


ControlFrame addControlFrame(String theName, int theWidth, int theHeight, ExternalSensors sensor) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight, f);
  f.add(p);
  p.init();
  p.sensorclass = sensor;
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  return p;
}

public class ControlFrame extends PApplet {

  int w, h;
  Frame frame;
  int abc = 100;

  
  ExternalSensors sensorclass = null;
  public void setup() {
    size(640, 480, OPENGL);
	smooth();
	noStroke();
	frameRate(50);
  }

  public void closeWindow() {
    frame.dispose();
  }

  public void draw() {
  	background(0);
  	lights();

  	pushMatrix();
	translate(width/2, height/2, -350);
   instructBoard(sensorclass.instruct_yaw, sensorclass.instruct_pitch, sensorclass.instruct_roll);
	drawBoard();
   if(key == 'd'){
      cleanInstruct();
   }
   popMatrix();
	
	// textFont(font, 20);
	fill(255);
	textAlign(LEFT);
	// // Output info text
	text("Point FTDI connector towards screen and press 'a' to align", 10, 25);
   text("Perform gesture after you make two arrow overlap", 10, 40);
	// // // Output angles
	pushMatrix();
	translate(10, height - 50);
	textAlign(LEFT);
	text("Yaw: " + ((float) sensorclass.yaw - sensorclass.yawOffset), 0, 0);
	text("Pitch: " + ((float) - (sensorclass.pitch - sensorclass.pitchOffset)), 150, 0);
	text("Roll: " + ((float) sensorclass.roll - sensorclass.rollOffset), 300, 0);
   text("Instruct : Yaw: " + ( sensorclass.instruct_yaw), 0, 20);
   text("Pitch: " + ( sensorclass.instruct_pitch), 150, 20);
   text("Roll: " + ( sensorclass.instruct_roll), 300, 20);

	text("Force: " + ( sensorclass.force), 450, 0);
	text("Force: " + ( sensorclass.instruct_force), 450, 20);
	popMatrix();
	translate(0, 0);
	float elongRatio = (float)sensorclass.force/sensorclass.instruct_force;
	fill(getHeatmapRGB(elongRatio));
  	rect(500, height*0.5, 30, (1-elongRatio)* 300);
  }
  
  private ControlFrame() {
  }

  public color getHeatmapRGB(float value){
     float minimum=0.6;
     float maximum=1.4;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     color heatmapRGB = color((int)max(0, 255*(ratio - 1)),
                              255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)),
                              (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
   }

  public ControlFrame(Object theParent, int theWidth, int theHeight, Frame f) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
    frame = f;
  }
  public void cleanInstruct(){
     background(0, 0, 0);
     drawBoard();
  }


  public ControlP5 control() {
    return cp5;
  }

	void drawArrow(float headWidthFactor, float headLengthFactor) {
	  float headWidth = headWidthFactor * 200.0f;
	  float headLength = headLengthFactor * 200.0f;
	  
	  pushMatrix();
	  
	  // Draw base
	  translate(0, 0, -100);
	  box(100, 100, 200);
	  
	  // Draw pointer
	  translate(-headWidth/2, -50, -100);
	  beginShape(QUAD_STRIP);
	    vertex(0, 0 ,0);
	    vertex(0, 100, 0);
	    vertex(headWidth, 0 ,0);
	    vertex(headWidth, 100, 0);
	    vertex(headWidth/2, 0, -headLength);
	    vertex(headWidth/2, 100, -headLength);
	    vertex(0, 0 ,0);
	    vertex(0, 100, 0);
	  endShape();
	  beginShape(TRIANGLES);
	    vertex(0, 0, 0);
	    vertex(headWidth, 0, 0);
	    vertex(headWidth/2, 0, -headLength);
	    vertex(0, 100, 0);
	    vertex(headWidth, 100, 0);
	    vertex(headWidth/2, 100, -headLength);
	  endShape();
	  
	  popMatrix();
	}
   
	void drawBoard() {
	  pushMatrix();

	  rotateY(-radians(sensorclass.yaw - sensorclass.yawOffset));
	  rotateX(-radians(sensorclass.pitch - sensorclass.pitchOffset));
	  rotateZ(radians(sensorclass.roll - sensorclass.rollOffset)); 

	  // Board body
	  fill(255, 0, 0);
	  box(250, 20, 400);
	  
	  // Forward-arrow
	  pushMatrix();
	  translate(0, 0, -200);
	  scale(0.5f, 0.2f, 0.25f);
	  fill(0, 255, 0);
	  drawArrow(1.0f, 2.0f);
	  popMatrix();
	    
	  popMatrix();
	}
  
  void instructBoard(float y, float x, float z) {
     pushMatrix();

     rotateY(radians(0));
     rotateX(radians(x));
     rotateZ(radians(z)); 

     // Board body
     fill(255, 255, 0);
     box(250, 20, 400);
     
     // Forward-arrow
     pushMatrix();
     translate(0, 0, -200);
     scale(0.5f, 0.2f, 0.25f);
     fill(0, 125, 0);
     drawArrow(1.0f, 2.0f);
     popMatrix();
       
     popMatrix();
  }

  
  
  ControlP5 cp5;

  Object parent;

  
}
