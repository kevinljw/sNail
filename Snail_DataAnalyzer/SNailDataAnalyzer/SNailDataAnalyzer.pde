import controlP5.*;

// Please put the files in this, and put it within data folder
public final static String DATA_FOLDER = "data";

public final static String PILOT_STUDY_ONE = "Pilot Study One";
public final static String PILOT_STUDY_TWO = "Pilot Study Two";
public final static String USER_STUDY_ONE = "User Study One";
public final static String USER_STUDY_TWO = "User Study Two";

CSVMerger csvMerger;
USOneAnalyzer usOneAnalyzer;
USTwoAnalyzer usTwoAnalyzer;
PSOneAnalyzer psOneAnalyzer;
PSTwoAnalyzer psTwoAnalyzer;

ControlP5 cp5;

boolean uiCompleted = false;

void setup() {
	cp5 = new ControlP5(this);
	csvMerger = new CSVMerger(this);
	psOneAnalyzer = new PSOneAnalyzer();
	psTwoAnalyzer = new PSTwoAnalyzer();
	usOneAnalyzer = new USOneAnalyzer();
	usTwoAnalyzer = new USTwoAnalyzer();
	

	size(900, 600);
	drawUI();
}

void draw() {

}

void drawUI()
{
	cp5.addButton(PILOT_STUDY_ONE)
     .setValue(0)
     .setPosition(10,10)
     .setSize(80,50)
    ;

    cp5.addButton(PILOT_STUDY_TWO)
     .setValue(0)
     .setPosition(10,80)
     .setSize(80,50)
    ;

    cp5.addButton(USER_STUDY_ONE)
     .setValue(0)
     .setPosition(10,150)
     .setSize(80,50)
    ;

    cp5.addButton(USER_STUDY_TWO)
     .setValue(0)
     .setPosition(10,220)
     .setSize(80,50)
    ;
    uiCompleted = true;
}

public void controlEvent(ControlEvent theEvent) {
	if (!uiCompleted) {return;}
	if (theEvent.getController().getName() == PILOT_STUDY_ONE) {
		psOneAnalyzer.analysisData();
	}
	else if (theEvent.getController().getName() == PILOT_STUDY_TWO) {
		psTwoAnalyzer.analysisData();
	}
	else if (theEvent.getController().getName() == USER_STUDY_ONE) {
		usOneAnalyzer.analysisData();
	}
	else if (theEvent.getController().getName() == USER_STUDY_TWO) {
		usTwoAnalyzer.analysisData();
	}
}