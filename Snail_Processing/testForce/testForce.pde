import controlP5.*; // http://www.sojamo.de/libraries/controlP5/
import processing.serial.*;


String serialPortName = "/dev/cu.usbmodem1421";
Serial serialPort;

ControlP5 cp5;

Graph LineGraph = new Graph(50, 50, 600, 200, color (20, 20, 200));

float[] lineGraphValues = new float [100];
float[] lineGraphSampleNumbers = new float[100];
color[] graphColors = new color[6];


void setup() {
	size(700, 300);
	  // set line graph colors
	graphColors[0] = color(131, 255, 20);
	graphColors[1] = color(232, 158, 12);
	graphColors[2] = color(255, 0, 0);
	graphColors[3] = color(62, 12, 232);
	graphColors[4] = color(13, 255, 243);
	graphColors[5] = color(200, 46, 232);

	cp5 = new ControlP5(this);

	for (int i=0; i<lineGraphSampleNumbers.length; i++) {
		lineGraphValues[i] = 0;
		lineGraphSampleNumbers[i] = i;
	}

	serialPort = new Serial(this, serialPortName, 115200);

	LineGraph.yMax = 600;
	LineGraph.Title = "Current Force";
}

byte[] inBuffer = new byte[100];
void draw() {
	String myString = "";
	if (serialPort.available() > 0) {
		try {
			serialPort.readBytesUntil('\n', inBuffer);
		}
		catch (Exception e) {

		}
		myString = new String(inBuffer);
		
	}
    else
    {
    	return;
    }


	try {
		for (int k=0; k<lineGraphValues.length-1; k++) {
			lineGraphValues[k] = lineGraphValues[k+1];
		}
		lineGraphValues[lineGraphValues.length-1] = float(myString);
	}
	catch (Exception e) {
	}

	LineGraph.DrawAxis();
	LineGraph.GraphColor = graphColors[0];
	LineGraph.LineGraph(lineGraphSampleNumbers, lineGraphValues);
}
