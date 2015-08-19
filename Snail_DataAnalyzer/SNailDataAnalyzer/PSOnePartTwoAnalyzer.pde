// import java.util.ArrayList;
// import java.io.*;

// // 0 - 15 users
// // each folder contains 0,1,2 csv
// // in the csv contains force value


// class PSOnePartTwoDatas {

// 	ArrayList<Table> tapForce = new ArrayList<Table>();
// 	ArrayList<Table> pressForce = new ArrayList<Table>();

// }


// public class PSOnePartTwoAnalyzer implements ControlListener{

// 	public final static String PILOT_STUDY_ONE_DATA = DATA_FOLDER + "/PilotOne";
// 	File dir = new File(sketchPath("")+ PILOT_STUDY_ONE_DATA);
// 	String[] list = dir.list(new FilenameFilter() {
//         @Override
//         public boolean accept(File dir, String name) {
//             return !name.equals(".DS_Store");
//         }
//     });
// 	PSOneDatas datas = new PSOneDatas();

	

// 	Table table;

// 	public PSOneAnalyzer () {
		
// 	}
// 	public void analysisData() {

		
// 	}

// 	void loadFiles() {
// 		println("list.length: "+list.length);

// 		for (int i = 0; i < list.length; ++i) {
// 			println("userslist[i]: "+list[i]);
// 			for (int j = 2; j < 2; ++j) {
// 				switch (j) {
// 					case 0:
// 					{
// 						Table loadtable = loadTable(PILOT_STUDY_ONE_DATA + "/"+ list[i] + "/0.csv", "header");
// 						datas.tapForce.add(loadtable);
// 						break;
// 					}
// 					case 1:
// 					{
// 						Table loadtable = loadTable(PILOT_STUDY_ONE_DATA + "/"+ list[i] + "/1.csv", "header");
// 						datas.pressForce.add(loadtable);
// 						break;
// 					}
// 					default:
// 						break;
					
// 				}		
// 			}
// 		}
// 	}
// 	@Override
// 	public void controlEvent(ControlEvent theEvent){
		
// 	}

// }