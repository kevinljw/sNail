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

		File user_dir = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_TIME );
		String[] user_list = user_dir.list(new FilenameFilter() {
	        @Override
	        public boolean accept(File dir, String name) {
	            return !name.equals(".DS_Store");
	        }
	    });

	    for (int i = 0; i < user_list.length; ++i) {

	    	File user_files_dir = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_TIME + "/" + user_list[i]);
	    	
	    	String[] per_user_files = user_files_dir.list(new FilenameFilter() {
		        @Override
		        public boolean accept(File dir, String name) {
		            return !name.equals(".DS_Store");
		        }
		    });

	    	for (int j = 0; j < per_user_files.length; ++j) {
	    		csvMerger.mergeFiles(STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_TIME + "/" + user_list[i]+"/"+per_user_files[j], "");	
	    	}
			


		}
		



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

		if(forceDir.equals("0.4"))//
		{
			 return;
		}
		else if(forceDir.equals("0.6"))//
		{
			return;
		}
		else if(forceDir.equals("0.8"))//
		{
			//return;
		}
		else if(forceDir.equals("1.0"))//
		{
			//return;
		}
		else if(forceDir.equals("1.2"))//
		{
			//return;
		}

		
		if (rawDataName.substring(3, rawDataName.length() - 4).equals("p15_r-15")) {
			return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p15_r0")) {
			// return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p15_r15")) {
			return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p15_r45")) {
			// return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p25_r0")) {
			return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p45_r-15")) {
			return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p45_r0")) {
			// return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p45_r15")) {
			return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p45_r45")) {
			// return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p65_r0")) {
			return;
		}
		else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p0_r0")) {
			// return;	
		}





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
		// table.removeColumn("SG_D0");
		table.removeColumn("SG1");
		table.removeColumn("SG_E1");
		// table.removeColumn("SG_D1");
		table.removeColumn("SG2");
		table.removeColumn("SG_E2");
		// // table.removeColumn("SG_D2");
		table.removeColumn("SG3");
		table.removeColumn("SG_E3");
		// // table.removeColumn("SG_D3");
		table.removeColumn("SG4");
		table.removeColumn("SG_E4");
		// // table.removeColumn("SG_D4");
		table.removeColumn("SG7");
		table.removeColumn("SG_E7");
		// // table.removeColumn("SG_D7");
		table.removeColumn("SG8");
		table.removeColumn("SG_E8");
		// // table.removeColumn("SG_D8");
		table.removeColumn("SG5");
		table.removeColumn("SG_E5");
		// // table.removeColumn("SG_D5");
		table.removeColumn("SG6");
		table.removeColumn("SG_E6");
		// // table.removeColumn("SG_D6");


		table.addColumn("ID");


		


		for (int k = 0; k < table.getRowCount(); ++k) {
			TableRow row = table.getRow(k);
			println("U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName.substring(0, rawDataName.length() - 4));
			
			//ignore force?
			//|| forceDir.equals("0.4") || || forceDir.equals("0.8") || forceDir.equals("1.0")
			// if(forceDir.equals("0.4"))//
			// {
			// 	continue;
			// }
			int idNum = 0;


			/*if (forceDir.equals("0.4")) {
				idNum = 40;
			}
			else if (forceDir.equals("0.6")) {
				idNum = 60;	
			}
			else if (forceDir.equals("0.8")) {
				idNum = 80;
			}
			else if (forceDir.equals("1.0")) {
				idNum = 100;
			}
			else if (forceDir.equals("1.2")) {
				idNum = 120;
			}*/


			// row.setString("ID",rawDataName.substring(3, rawDataName.length() - 4));

			// println("rawDataName.substring(3, rawDataName.length() - 4): "+rawDataName.substring(3, rawDataName.length() - 4));

			if (rawDataName.substring(3, rawDataName.length() - 4).equals("p15_r-15")) {
				row.setInt("ID", idNum+0);
				 continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p15_r0")) {
				row.setInt("ID", idNum+1);
				// row.setInt("ID", idNum);
				// continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p15_r15")) {
				row.setInt("ID", idNum+2);
				 continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p15_r45")) {//good!!
				row.setInt("ID", idNum+3);
				// row.setInt("ID", idNum);
				// continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p25_r0")) {
				row.setInt("ID", idNum+4);
				 continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p45_r-15")) {
				row.setInt("ID", idNum+5);
				 continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p45_r0")) {
				row.setInt("ID", idNum+6);
				// row.setInt("ID", idNum);
				// continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p45_r15")) {
				row.setInt("ID", idNum+7);
				 continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p45_r45")) {
				row.setInt("ID", idNum+8);
				// row.setInt("ID", idNum);
				// continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p65_r0")) {
				row.setInt("ID", idNum+9);
				 continue;
			}
			else if (rawDataName.substring(3, rawDataName.length() - 4).equals("p0_r0")) {
				row.setInt("ID", idNum+10);
				row.setInt("ID", idNum);
				// continue;
			}
		}

			



		//leave one force
		for (int i = 1; i < 6; ++i) {
			if (Integer.valueOf(rawDataName.substring(1,2)) == 0) {
				continue;
			}
			else if (i != Integer.valueOf(rawDataName.substring(1,2))) {//rawDataName.substring(3, rawDataName.length() - 4)
				saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_TIME +"/U" + userDir.substring(4) +"/leaveT"+ i +"/F"+ forceDir+ "_" + rawDataName);
			}
			else {
				saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_TIME +"/U" + userDir.substring(4) +"/T"+ i +"/F"+ forceDir+ "_" + rawDataName);
			}
			// println("rawDataName.substring(1,2): "+rawDataName.substring(1,2));;
		}

			

			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_USER_MIXED +"/F"+ forceDir + "/U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName);

			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE +"/U" + userDir.substring(4) + "/F"+ forceDir + "/U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName);

			// row.setString("ID", "F"+ forceDir + "_" + rawDataName.substring(0, rawDataName.length() - 4));
			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_FORCE +"/U" +  userDir.substring(4) +"/F"+ forceDir+"_"+ rawDataName);
			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_USER +"/U" + );
		
	}

	
	@Override
	public void controlEvent(ControlEvent theEvent){}

}