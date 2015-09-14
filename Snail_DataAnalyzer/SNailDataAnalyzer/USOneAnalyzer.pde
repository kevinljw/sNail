import java.util.ArrayList;

public class USOneAnalyzer implements ControlListener{

	public final static String STUDY_ONE_DATA = DATA_FOLDER + "/StudyOne";
	public final static String STUDY_ONE_DATA_RESULT_CLASS_BY_USER = STUDY_ONE_DATA + "/Result/User" ;
	public final static String STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE = STUDY_ONE_DATA + "/Result/UserWithForce" ;
	public final static String STUDY_ONE_DATA_RESULT_CLASS_BY_USER_MIXED = STUDY_ONE_DATA + "/Result/UserMixed" ;
	public final static String STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_TIME = STUDY_ONE_DATA + "/Result/PerUserLeaveOneOutByTime" ;
	public final static String STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_USER = STUDY_ONE_DATA + "/Result/UsersLeaveOneOut" ;

	File dir = new File(sketchPath("") + STUDY_ONE_DATA );
	String[] userslist = dir.list(new FilenameFilter() {
        @Override
        public boolean accept(File dir, String name) {
            return !name.equals(".DS_Store");
        }
    });
	Table table;

	CSVMerger csvMerger = new CSVMerger();

	public USOneAnalyzer () {
		
	}

	public void analysisData() {
		loadFiles();
		//mixed
		// File result_dir = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_USER );
		// String[] result_list = result_dir.list(new FilenameFilter() {
	 //        @Override
	 //        public boolean accept(File dir, String name) {
	 //            return !name.equals(".DS_Store");
	 //        }
	 //    });

	 //    for (int i = 0; i < result_list.length; ++i) {
		// 	csvMerger.mergeFiles(STUDY_ONE_DATA_RESULT_CLASS_BY_USER + "/" + result_list[i]);
		// }



		//categorize by force
	 //    File result_dir_with_Force = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE );
		// String[] result_list_with_Force = result_dir_with_Force.list(new FilenameFilter() {
	 //        @Override
	 //        public boolean accept(File dir, String name) {
	 //            return !name.equals(".DS_Store");
	 //            //return name.contains(".csv");
	 //        }
	 //    });



		// for (int i = 0; i < result_list_with_Force.length; ++i) {

		// 	File result_dir_with_Force_folder = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE + "/"+result_list_with_Force[i]);

		// 	String[] result_list_with_Force_folder = result_dir_with_Force_folder.list(new FilenameFilter() {
		//         @Override
		//         public boolean accept(File dir, String name) {
		//             return !name.equals(".DS_Store");
		//         }
		//     });

		//     for (int j = 0; j < result_list_with_Force_folder.length; ++j) {
		//     	csvMerger.mergeFiles(STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE + "/" + result_list_with_Force[i] +"/" + result_list_with_Force_folder[j]);	
		//     }
		// }

		// for (int j = 0; j < result_list_with_Force.length; ++j) {
		// 	for (int i = 0; i < 5; ++i) {
		// 		int showInt = i+1;
		// 		csvMerger.mergeCSVFilesWithIgnore(STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE + "/" + result_list_with_Force[j], i, "no"+showInt+"_Force");	
		// 	}
		// }
		



		//for user mixed
		// File result_dir_user_mixed = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_USER_MIXED );
		// String[] result_list_user_mixed = result_dir_user_mixed.list(new FilenameFilter() {
	 //        @Override
	 //        public boolean accept(File dir, String name) {
	 //            return !name.equals(".DS_Store");
	 //        }
	 //    });

	 //    for (int i = 0; i < result_list_user_mixed.length; ++i) {
	 //    	csvMerger.mergeFiles(STUDY_ONE_DATA_RESULT_CLASS_BY_USER_MIXED + "/" + result_list_user_mixed[i]);	
	 //    }

	    



	    
	}

	void loadFiles()
	{
		for (int i = 0; i < userslist.length; ++i) {

			//Get force folder
			File dir_force = new File(sketchPath("") +DATA_FOLDER + "/StudyOne/" + userslist[i]);

			String[] user_Forces = dir_force.list(new FilenameFilter() {
		        @Override
		        public boolean accept(File dir, String name) {
		            return !name.equals(".DS_Store");
		        }
		    });

			for (int j = 0; j < user_Forces.length; ++j) {

				File dir_To_RawData = new File(sketchPath("") +DATA_FOLDER + "/StudyOne/" + userslist[i] + "/" + user_Forces[j]);

				String[] user_RawDatas = dir_To_RawData.list(new FilenameFilter() {
			        @Override
			        public boolean accept(File dir, String name) {
			            return !name.equals(".DS_Store");
			        }
			    });


				for (int k = 0; k < user_RawDatas.length; ++k) {
					settingForNewFile(userslist[i], user_Forces[j], user_RawDatas[k]);	
				}

			}
		}

	}


	void settingForNewFile(String userDir, String forceDir, String rawDataName)
	{
		table = loadTable(STUDY_ONE_DATA + "/"+ userDir + "/" + forceDir + "/"+ rawDataName, "header");
		// roll,yaw,pitch,yaxis,xaxis,zaxis,force,SG0,SG_E0,SG_D0,SG1,SG_E1,SG_D1,SG2,SG_E2,SG_D2,SG3,SG_E3,SG_D3,SG4,SG_E4,SG_D4,SG5,SG_E5,SG_D5,SG6,SG_E6,SG_D6,SG7,SG_E7,SG_D7,SG8,SG_E8,SG_D8
		// table.removeColumn("taskNumber");
		table.removeColumn("yaxis");
		table.removeColumn("xaxis");
		table.removeColumn("zaxis");
		table.removeColumn("roll");
		table.removeColumn("yaw");
		table.removeColumn("pitch");
		table.removeColumn("force");
		table.removeColumn("SG0");
		table.removeColumn("SG_E0");
		table.removeColumn("SG1");
		table.removeColumn("SG_E1");
		table.removeColumn("SG2");
		table.removeColumn("SG_E2");
		table.removeColumn("SG3");
		table.removeColumn("SG_E3");
		table.removeColumn("SG4");
		table.removeColumn("SG_E4");
		table.removeColumn("SG7");
		table.removeColumn("SG_E7");
		table.removeColumn("SG8");
		table.removeColumn("SG_E8");
		table.removeColumn("SG5");
		table.removeColumn("SG_E5");
		table.removeColumn("SG6");
		table.removeColumn("SG_E6");


		table.addColumn("ID");


		for (int k = 0; k < table.getRowCount(); ++k) {
			TableRow row = table.getRow(k);
			// println("U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName.substring(0, rawDataName.length() - 4));
			row.setString("ID", rawDataName.substring(3, rawDataName.length() - 4));



			//leave one force
			for (int i = 0; i < 5; ++i) {
				if (i !=  Integer.valueOf(rawDataName.substring(1,2))) {
					saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_TIME +"/U" + userDir.substring(4) +"/leaveT"+ i +"/F"+ forceDir+ "_" + rawDataName);
				}
				else {
					saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_TIME +"/U" + userDir.substring(4) +"/T"+ i +"/F"+ forceDir+ "_" + rawDataName);
				}
				// println("rawDataName.substring(1,1): "+rawDataName.substring(1,2));;
			}

			

			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_USER_MIXED +"/F"+ forceDir + "/U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName);

			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE +"/U" + userDir.substring(4) + "/F"+ forceDir + "/U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName);

			// row.setString("ID", "F"+ forceDir + "_" + rawDataName.substring(0, rawDataName.length() - 4));
			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_FORCE +"/U" +  userDir.substring(4) +"/F"+ forceDir+"_"+ rawDataName);
			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_USER +"/U" + );
		}
	}

	
	@Override
	public void controlEvent(ControlEvent theEvent){}

}