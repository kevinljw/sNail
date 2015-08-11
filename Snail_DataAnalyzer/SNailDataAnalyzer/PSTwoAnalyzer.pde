import java.util.ArrayList;
import grafica.*;

class PSTwoDatas {

	ArrayList<Table> normalForce = new ArrayList<Table>();
	ArrayList<Table> lightForce = new ArrayList<Table>();
	ArrayList<Table> heavyForce = new ArrayList<Table>();
}



public class PSTwoAnalyzer implements ControlListener{

	public final static String PILOT_STUDY_TWO_DATA = DATA_FOLDER + "/PilotTwo";
	public final static String USER_LIST_DROPDOWN = "Pilot2 - User List";
	public final static String USER_FORCE_DROPDOWN = "Pilot2 - Force List";
	public final static String USER_DIRECTION_DROPDOWN = "Pilot2 - Direction List";

	File users = new File(sketchPath("")+ PILOT_STUDY_TWO_DATA);
	String[] userslist = users.list(new FilenameFilter() {
        @Override
        public boolean accept(File dir, String name) {
            return !name.equals(".DS_Store");
        }
    });
	PSTwoDatas datas = new PSTwoDatas();
	String [] forceNames = {"Normal", "light","Heavy"};
	String [] directionNames = {"front", "front right", "right", "bottom right", "bottom", "bottom left", "left", "front left"};

	Table table;

	DropdownList listUsersDropdown;
	DropdownList listForceDropdown;
	DropdownList listDirectionDropdown;

	int currentUser;
	int currentForce;
	int currentDirection;

	SNailDataAnalyzer mainClass;

	GPlot plot1;

	public PSTwoAnalyzer (SNailDataAnalyzer mainClass) {
		this.mainClass = mainClass;
	}
	public void analysisData() {

		loadFiles();
		drawUI();
		drawGraph();
		
	}

	@Override
	public void controlEvent(ControlEvent theEvent){
		if (theEvent.isGroup()) {
			// theEvent.getGroup().getValue()
			if (theEvent.getGroup().getName() == USER_LIST_DROPDOWN) {
				currentUser = Math.round(theEvent.getGroup().getValue());
				drawGraph();
			}
			else if (theEvent.getGroup().getName() == USER_FORCE_DROPDOWN) {
				currentForce = Math.round(theEvent.getGroup().getValue());
				drawGraph();
			}
			else if (theEvent.getGroup().getName() == USER_DIRECTION_DROPDOWN) {
				currentDirection = Math.round(theEvent.getGroup().getValue());
				drawGraph();
			}
		} 
	}

	void draw()
	{
		if (plot1 != null) {
			plot1.defaultDraw();	
		}
	}

	public void removeUI() {
		listUsersDropdown.remove();
		listForceDropdown.remove();
		listDirectionDropdown.remove();
	}

	void drawUI()
	{
		listUsersDropdown = cp5.addDropdownList(USER_LIST_DROPDOWN)
          .setPosition(100, 20)
          ;

        listUsersDropdown.setBackgroundColor(color(190));
		listUsersDropdown.setItemHeight(20);
		listUsersDropdown.setBarHeight(15);
		listUsersDropdown.setHeight(210);
		listUsersDropdown.captionLabel().set(USER_LIST_DROPDOWN);
		listUsersDropdown.captionLabel().style().marginTop = 3;
		listUsersDropdown.captionLabel().style().marginLeft = 3;
		listUsersDropdown.valueLabel().style().marginTop = 3;

        for (int i=0 ; i < userslist.length ;i++) {
		    listUsersDropdown.addItem("user "+i, i);
  		}
  		listUsersDropdown.setColorBackground(color(60));
  		listUsersDropdown.setColorActive(color(255, 128));


  		listForceDropdown = cp5.addDropdownList(USER_FORCE_DROPDOWN)
          .setPosition(200, 20)
          ;

        listForceDropdown.setBackgroundColor(color(190));
		listForceDropdown.setItemHeight(20);
		listForceDropdown.setBarHeight(15);
		listForceDropdown.setHeight(210);
		listForceDropdown.captionLabel().set(USER_LIST_DROPDOWN);
		listForceDropdown.captionLabel().style().marginTop = 3;
		listForceDropdown.captionLabel().style().marginLeft = 3;
		listForceDropdown.valueLabel().style().marginTop = 3;

        for (int i=0 ; i < 3 ;i++) {
		    listForceDropdown.addItem(forceNames[i], i);
  		}
  		listForceDropdown.setColorBackground(color(60));
  		listForceDropdown.setColorActive(color(255, 128));


  		listDirectionDropdown = cp5.addDropdownList(USER_DIRECTION_DROPDOWN)
          .setPosition(300, 20)
          ;

        listDirectionDropdown.setBackgroundColor(color(190));
		listDirectionDropdown.setItemHeight(20);
		listDirectionDropdown.setBarHeight(15);
		listDirectionDropdown.setHeight(210);
		listDirectionDropdown.captionLabel().set(USER_LIST_DROPDOWN);
		listDirectionDropdown.captionLabel().style().marginTop = 3;
		listDirectionDropdown.captionLabel().style().marginLeft = 3;
		listDirectionDropdown.valueLabel().style().marginTop = 3;

        for (int i=0 ; i < 8 ;i++) {
		    listDirectionDropdown.addItem(directionNames[i], i);
  		}
  		listDirectionDropdown.setColorBackground(color(60));
  		listDirectionDropdown.setColorActive(color(255, 128));


	}

	void drawGraph()
	{
		if (userslist.length == 0) {
			return;
		}

		Table loadTable = datas.normalForce.get(currentUser);

		switch (currentForce) {
			case 0 :
				loadTable = datas.normalForce.get(currentUser);
				break;
			case 1 :
				loadTable = datas.normalForce.get(currentUser);
				break;
			case 2 :
				loadTable = datas.normalForce.get(currentUser);
				break;
		}

		int i = 0;
		GPointsArray points = new GPointsArray();
		for (TableRow row : loadTable.findRows("0", "taskNumber")) {
			points.add(i , row.getFloat("force"));
			i++;
		}

		i=0;
		GPointsArray points_2 = new GPointsArray();
		for (TableRow row : loadTable.findRows("1", "taskNumber")) {
			points.add(i , row.getFloat("force"));
			i++;
		}

		i=0;
		GPointsArray points_3 = new GPointsArray();
		for (TableRow row : loadTable.findRows("3", "taskNumber")) {
			points.add(i , row.getFloat("force"));
			i++;
		}

		plot1 = new GPlot(mainClass);
		plot1.setPos(0, 0);
		plot1.setXLim(1, 100);
		plot1.setYLim(0.1, 3);
		plot1.getTitle().setText("In three times");
		plot1.getXAxis().getAxisLabel().setText("Time");
		plot1.getYAxis().getAxisLabel().setText("Force");
		plot1.setLogScale("xy");
		plot1.setPoints(points);
		plot1.setLineColor(color(200, 200, 255));
		plot1.addLayer("layer 1", points_2);
		plot1.getLayer("layer 1").setLineColor(color(150, 150, 255));
		plot1.addLayer("layer 2", points_3);
		plot1.getLayer("layer 2").setLineColor(color(100, 100, 255));
		
	}

	void loadFiles() {
		println("list.length: "+userslist.length);

		for (int i = 0; i < userslist.length; ++i) {
			for (int j = 0; j < 3; ++j) {
				switch (j) {
					case 0:
					{
						for (int k = 0; k < 8; ++k) {
							Table loadtable = loadTable(PILOT_STUDY_TWO_DATA + "/"+ userslist[i]+  "/"+ j + "/" + k +".csv", "header");
							datas.normalForce.add(loadtable);
						}
						break;
					}
					case 1:
					{
						for (int k = 0; k < 8; ++k) {
							Table loadtable = loadTable(PILOT_STUDY_TWO_DATA + "/"+ userslist[i]+  "/"+ j + "/" + k +".csv", "header");
							datas.lightForce.add(loadtable);
						}
						break;
					}
					case 2:
					{
						for (int k = 0; k < 8; ++k) {
							Table loadtable = loadTable(PILOT_STUDY_TWO_DATA + "/"+ userslist[i]+  "/"+ j + "/" + k +".csv", "header");
							datas.heavyForce.add(loadtable);
						}
						break;
					}
					default:
						break;
					
				}


					
			}
		}
	}
}