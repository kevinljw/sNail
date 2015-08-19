import java.util.ArrayList;
import java.io.*;

// 0 - 15 users
// each folder contains 0,1 csv (tap and press)
// in the csv contains force value


class PSOneDatas {

	ArrayList<Table> tapForce = new ArrayList<Table>();
	ArrayList<Table> pressForce = new ArrayList<Table>();

}


public class PSOneAnalyzer implements ControlListener{

	public final static String PILOT_STUDY_ONE_DATA = DATA_FOLDER + "/PilotOne";
	File dir = new File(sketchPath("")+ PILOT_STUDY_ONE_DATA);
	String[] list = dir.list(new FilenameFilter() {
        @Override
        public boolean accept(File dir, String name) {
            return !name.equals(".DS_Store");
        }
    });
	PSOneDatas datas = new PSOneDatas();

	

	Table table;

	public PSOneAnalyzer () {
		
	}
	public void analysisData() {

		table = new Table();
		table.addColumn("user");
		table.addColumn("tapMax");
		table.addColumn("pressMax");

		float totalTapAverage = 0.0;
		float totalPressAverage = 0.0;


		loadFiles();

		for (int i = 0; i < list.length; ++i) {

			float perUserTapMax = 0.0;
			float perUserPressMax = 0.0;


			for (int j = 0; j < datas.tapForce.get(i).getRowCount(); ++j) {
				TableRow row = datas.tapForce.get(i).getRow(j);
				float currentRowForceValue = row.getFloat("force");
				if (currentRowForceValue > perUserTapMax) {
					perUserTapMax = currentRowForceValue;
				}
			}

			for (int j = 0; j < datas.pressForce.get(i).getRowCount(); ++j) {
				TableRow row = datas.pressForce.get(i).getRow(j);
				float currentRowForceValue = row.getFloat("force");
				if (currentRowForceValue > perUserPressMax) {
					perUserPressMax = currentRowForceValue;
				}
			}
			


			TableRow newRow = table.addRow();
			newRow.setString("user", "user_"+i );
			newRow.setFloat("tapMax", perUserTapMax);
			newRow.setFloat("pressMax", perUserPressMax);

			totalTapAverage += perUserTapMax;
			totalPressAverage += perUserPressMax;
		}

		if (list.length >0) {
			totalTapAverage = totalTapAverage / list.length;
			totalPressAverage = totalPressAverage / list.length;
		}

		TableRow newRow = table.addRow();
		newRow.setString("user", "overall");
		newRow.setFloat("tapMax", totalTapAverage);
		newRow.setFloat("pressMax", totalPressAverage);

		saveTable(table, PILOT_STUDY_ONE_DATA +"/result.csv");
	}

	void loadFiles() {
		println("list.length: "+list.length);

		for (int i = 0; i < list.length; ++i) {
			println("userslist[i]: "+list[i]);
			for (int j = 0; j < 2; ++j) {
				switch (j) {
					case 0:
					{
						Table loadtable = loadTable(PILOT_STUDY_ONE_DATA + "/"+ list[i] + "/0.csv", "header");
						datas.tapForce.add(loadtable);
						break;
					}
					case 1:
					{
						Table loadtable = loadTable(PILOT_STUDY_ONE_DATA + "/"+ list[i] + "/1.csv", "header");
						datas.pressForce.add(loadtable);
						break;
					}
					default:
						break;
					
				}		
			}
		}
	}
	@Override
	public void controlEvent(ControlEvent theEvent){}

}