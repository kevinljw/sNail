public class ExternalSensors implements ControlListener{
	
	final static int SERIAL_PORT_BAUD_RATE = 57600;
	private static final boolean ENABLE_9DOF = true;
	private static final boolean ENABLE_WEIGHT = true;

	public float raw = 0.0;
	public float yaw = 0.0;
	public float pitch = 0.0;

	public float weight = 0.0;


	PApplet mainClass;
	Serial sensorsPort;

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
			raw = parsedData[i++];
			yaw = parsedData[i++];
			pitch = parsedData[i++];
		}
		
		if (ENABLE_WEIGHT) {
			weight = parsedData[i++];	
		}
	}

	private float [] parseSpaceSeparatedData(Serial port) throws Exception{
      String buf = port.readString();
      // print(buf);
      String [] bufSplitArr = buf.split(" ");
      float [] parsedDataArr = new float[bufSplitArr.length-1];

      for (int i = 0; i < bufSplitArr.length-1; ++i){
         parsedDataArr[i] = Float.parseFloat(bufSplitArr[i]);
         // print(parsedDataArr[i]+" ");
      }

      return parsedDataArr;
   }

	public void performKeyPress(char k){  
	}


}