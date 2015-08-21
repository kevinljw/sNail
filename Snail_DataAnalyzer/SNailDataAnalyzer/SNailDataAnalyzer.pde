import controlP5.*;

// Please put the files in this, and put it within data folder
public final static String DATA_FOLDER = "data";

public final static String PILOT_STUDY_ONE = "Pilot Study One";
public final static String PILOT_STUDY_TWO = "Pilot Study Two";
public final static String USER_STUDY_ONE = "User Study One";
public final static String USER_STUDY_TWO = "User Study Two";

USOneAnalyzer usOneAnalyzer;
USTwoAnalyzer usTwoAnalyzer;
PSOneAnalyzer psOneAnalyzer;
PSTwoAnalyzer psTwoAnalyzer;

ControlP5 cp5;

boolean uiCompleted = false;

int currentSeletedType = -1;

void setup() {
	cp5 = new ControlP5(this);
	
	size(900, 600, P3D);
	background(255);
	drawUI();
}

void draw() {
	background(255);
	if (currentSeletedType == 1) {
		psTwoAnalyzer.draw();
	}
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

	if (theEvent.isGroup()) {

	}
	else if (theEvent.isController()) {
		if (theEvent.getController().getName() == PILOT_STUDY_ONE) {
			removeCurrentListener();
			currentSeletedType = 0;
			psOneAnalyzer = new PSOneAnalyzer();
			cp5.addListener(psOneAnalyzer);
			psOneAnalyzer.analysisData();
		}
		else if (theEvent.getController().getName() == PILOT_STUDY_TWO) {
			removeCurrentListener();
			currentSeletedType = 1;
			psTwoAnalyzer = new PSTwoAnalyzer(this);
			cp5.addListener(psTwoAnalyzer);
			psTwoAnalyzer.analysisData();
		}
		else if (theEvent.getController().getName() == USER_STUDY_ONE) {
			removeCurrentListener();
			currentSeletedType = 2;
			usOneAnalyzer = new USOneAnalyzer();
			cp5.addListener(usOneAnalyzer);
			usOneAnalyzer.analysisData();
		}
		else if (theEvent.getController().getName() == USER_STUDY_TWO) {
			removeCurrentListener();
			currentSeletedType = 3;
			usTwoAnalyzer = new USTwoAnalyzer();
			cp5.addListener(usTwoAnalyzer);
			usTwoAnalyzer.analysisData();
		}
	}
}

void removeCurrentListener()
{
	if (currentSeletedType != -1) {
		switch (currentSeletedType) {
			case 0 :
				cp5.removeListener(psOneAnalyzer);
				psOneAnalyzer = null;
				break;
			case 1 :
				cp5.removeListener(psTwoAnalyzer);
				psTwoAnalyzer.removeUI();
				psTwoAnalyzer = null;
				break;
			case 2 :
				cp5.removeListener(usOneAnalyzer);
				usOneAnalyzer = null;
				break;
			case 3 :
				cp5.removeListener(usTwoAnalyzer);
				usTwoAnalyzer = null;
				break;	
			
			
		}
	}
}