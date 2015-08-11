import java.util.ArrayList;

// 0 - 15 users
// each folder contains 0,1,2 csv
// in the csv contains force value


class PSOneDatas {

	ArrayList<Table> lightForce = new ArrayList<Table>();
	ArrayList<Table> normalForce = new ArrayList<Table>();
	ArrayList<Table> heavyForce = new ArrayList<Table>();
}


public class PSOneAnalyzer {

	public final static String PILOT_STUDY_ONE_DATA = DATA_FOLDER + "/PilotOne";
	File dir = new File(sketchPath("")+ PILOT_STUDY_ONE_DATA);
	String[] list = dir.list();
	PSOneDatas datas = new PSOneDatas();

	Table table;

	public PSOneAnalyzer () {
		
	}
	public void analysisData() {
		table = new Table();
		table.addColumn("user");
		table.addColumn("light");
		table.addColumn("normal");
		table.addColumn("heavy");

		float totalNormalAverage = 0.0;
		float totalLightAverage = 0.0;
		float totalHeavyAverage = 0.0;


		loadFiles();

		for (int i = 0; i < list.length; ++i) {

			float perUserNormalAverage = 0.0;
			float perUserLightAverage = 0.0;
			float perUserHeavyAverage = 0.0;


			for (int j = 0; j < datas.normalForce.get(i).getRowCount(); ++j) {
				TableRow row = datas.normalForce.get(i).getRow(j);
				perUserNormalAverage += row.getFloat("force");
			}
			perUserNormalAverage = (float) perUserNormalAverage / datas.normalForce.get(i).getRowCount();

			for (int j = 0; j < datas.lightForce.get(i).getRowCount(); ++j) {
				TableRow row = datas.lightForce.get(i).getRow(j);
				perUserLightAverage += row.getFloat("force");	
			}
			perUserLightAverage = (float) perUserLightAverage / datas.lightForce.get(i).getRowCount();

			for (int j = 0; j < datas.heavyForce.get(i).getRowCount(); ++j) {
				TableRow row = datas.heavyForce.get(i).getRow(j);
				perUserHeavyAverage += row.getFloat("force");
			}
			perUserHeavyAverage = (float) perUserHeavyAverage / datas.heavyForce.get(i).getRowCount();

			TableRow newRow = table.addRow();
			newRow.setString("user", "user_"+i );
			newRow.setFloat("light", perUserNormalAverage);
			newRow.setFloat("normal", perUserLightAverage);
			newRow.setFloat("heavy", perUserHeavyAverage);

			totalNormalAverage += perUserNormalAverage;
			totalLightAverage += perUserLightAverage;
			totalHeavyAverage += perUserHeavyAverage;
		}

		totalNormalAverage = totalNormalAverage/ list.length;
		totalLightAverage = totalLightAverage / list.length;
		totalHeavyAverage = totalHeavyAverage / list.length;


		TableRow newRow = table.addRow();
		newRow.setString("user", "overall");
		newRow.setFloat("light", totalNormalAverage);
		newRow.setFloat("normal", totalLightAverage);
		newRow.setFloat("heavy", totalHeavyAverage);

	}

	void loadFiles() {
		for (int i = 0; i < list.length; ++i) {
			for (int j = 0; j < 3; ++j) {
				switch (j) {
					case 0:
					{
						Table loadtable = loadTable(PILOT_STUDY_ONE_DATA + "/"+ list[i] + "/0.csv", "header");
						datas.normalForce.add(loadtable);
						break;
					}
					case 1:
					{
						Table loadtable = loadTable(PILOT_STUDY_ONE_DATA + "/"+ list[i] + "/1.csv", "header");
						datas.lightForce.add(loadtable);
						break;
					}
					case 2:
					{
						Table loadtable = loadTable(PILOT_STUDY_ONE_DATA + "/"+ list[i] + "/2.csv", "header");
						datas.heavyForce.add(loadtable);
						break;
					}
					default:
						break;
					
				}


					
			}
		}
	}

}