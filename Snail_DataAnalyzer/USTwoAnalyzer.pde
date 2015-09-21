import java.util.ArrayList;
public class USTwoAnalyzer implements ControlListener{

	public final static String STUDY_TWO_DATA = DATA_FOLDER + "/StudyTwo";
	public final static String STUDY_TWO_DATA_RESULT_CLASS_BY_LOO_TIME = STUDY_TWO_DATA + "/Result/PerUserLeaveOneOutByTime" ;

	File dir = new File(sketchPath("") + STUDY_TWO_DATA);
	String[] userslist = dir.list(new FilenameFilter() {
        @Override
        public boolean accept(File dir, String name) {
            return !name.equals(".DS_Store");
        }
    });
	Table table;
	Table tableGenerater;

	CSVMerger csvMerger = new CSVMerger();

	public USTwoAnalyzer () {
		
	}
	public void analysisData() {
		loadFiles();

		File user_dir = new File(sketchPath("") + STUDY_TWO_DATA_RESULT_CLASS_BY_LOO_TIME );
		String[] user_list = user_dir.list(new FilenameFilter() {
	        @Override
	        public boolean accept(File dir, String name) {
	            return !name.equals(".DS_Store");
	        }
	    });

	    for (int i = 0; i < user_list.length; ++i) {

	    	File user_files_dir = new File(sketchPath("") + STUDY_TWO_DATA_RESULT_CLASS_BY_LOO_TIME + "/" + user_list[i]);
	    	
	    	String[] per_user_files = user_files_dir.list(new FilenameFilter() {
		        @Override
		        public boolean accept(File dir, String name) {
		            return !name.equals(".DS_Store");
		        }
		    });

	    	for (int j = 0; j < per_user_files.length; ++j) {
	    		csvMerger.mergeFiles(STUDY_TWO_DATA_RESULT_CLASS_BY_LOO_TIME + "/" + user_list[i]+"/"+per_user_files[j], "");	
	    	}
    	}
	}

	void loadFiles()
	{
		for (int i = 0; i < userslist.length; ++i) {

			//Get force folder
			File dir_force = new File(sketchPath("") +DATA_FOLDER + "/StudyTwo/" + userslist[i]);

			String[] user_texture = dir_force.list(new FilenameFilter() {
		        @Override
		        public boolean accept(File dir, String name) {
		            return !name.equals(".DS_Store");
		        }
		    });

			for (int j = 0; j < user_texture.length; ++j) {

				File dir_To_RawData = new File(sketchPath("") +DATA_FOLDER + "/StudyTwo/" + userslist[i] + "/" + user_texture[j]);

				String[] user_RawDatas = dir_To_RawData.list(new FilenameFilter() {
			        @Override
			        public boolean accept(File dir, String name) {
			            return !name.equals(".DS_Store");
			        }
			    });


				for (int k = 0; k < user_RawDatas.length; ++k) {
					settingForNewFile(userslist[i], user_texture[j], user_RawDatas[k]);	
				}

			}
		}

	}
	void settingForNewFile(String userDir, String texture, String rawDataName)
	{

		if(texture.equals("0"))//
		{
			// return;
		}
		else if(texture.equals("1"))//
		{
			return;
		}
		else if(texture.equals("2"))//
		{
			return;
		}

		
		if (rawDataName.substring(3, 5).equals("d0")) {
			// return;
		}
		else if (rawDataName.substring(3, 5).equals("d1")) {
			return;
		}
		else if (rawDataName.substring(3, 5).equals("d2")) {
			// return;
		}
		else if (rawDataName.substring(3, 5).equals("d3")) {
			return;
		}
		else if (rawDataName.substring(3, 5).equals("d4")) {
			// return;
		}
		else if (rawDataName.substring(3, 5).equals("d5")) {
			return;
		}
		else if (rawDataName.substring(3, 5).equals("d6")) {
			// return;
		}
		else if (rawDataName.substring(3, 5).equals("d7")) {
			return;
		}


		tableGenerater = new Table();
		tableGenerater.addColumn("ID");
		tableGenerater.addColumn("SG0p");
		tableGenerater.addColumn("SG0m");
		tableGenerater.addColumn("SG1p");
		tableGenerater.addColumn("SG1m");
		tableGenerater.addColumn("SG2p");
		tableGenerater.addColumn("SG2m");
		tableGenerater.addColumn("SG3p");
		tableGenerater.addColumn("SG3m");
		tableGenerater.addColumn("SG4p");
		tableGenerater.addColumn("SG4m");
		tableGenerater.addColumn("SG5p");
		tableGenerater.addColumn("SG5m");
		tableGenerater.addColumn("SG6p");
		tableGenerater.addColumn("SG6m");
		tableGenerater.addColumn("SG7p");
		tableGenerater.addColumn("SG7m");
		tableGenerater.addColumn("SG8p");
		tableGenerater.addColumn("SG8m");

		TableRow newRow = tableGenerater.addRow();

		table = loadTable(STUDY_TWO_DATA + "/"+ userDir + "/" + texture + "/"+ rawDataName, "header");
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


		int d0 = 0, d1= 0, d2= 0, d3= 0, d4= 0, d5= 0, d6= 0, d7= 0, d8 = 0;
		int d0tp=0, d0tm=0, d1tp=0, d1tm=0, d2tp=0, d2tm=0, d3tp=0, d3tm=0, d4tp=0, d4tm=0, d5tp=0, d5tm=0, d6tp=0, d6tm=0, d7tp=0, d7tm=0, d8tp=0, d8tm = 0;
		


		for (int k = 0; k < table.getRowCount(); ++k) {
			TableRow row = table.getRow(k);

			if (k == 0) {
				d0 = - row.getInt("SG_D0");
				d1 = - row.getInt("SG_D1");
				d2 = - row.getInt("SG_D2");
				d3 = - row.getInt("SG_D3");
				d4 = - row.getInt("SG_D4");
				d5 = - row.getInt("SG_D5");
				d6 = - row.getInt("SG_D6");
				d7 = - row.getInt("SG_D7");
			}
			else
			{
				if (abs(row.getInt("SG_D0") + d0) <20	) {
						 	
				}
				else if (row.getInt("SG_D0") + d0 <0) {
					d0tm += abs(row.getInt("SG_D0") + d0);
				}
				else {
					d0tp += abs(row.getInt("SG_D0") + d0);	
				}

				if (abs(row.getInt("SG_D1") + d1) <20) {
					
				}
				else if (row.getInt("SG_D1") + d1 <0) {
					d1tm += abs(row.getInt("SG_D1") + d1);
				}
				else {
					d1tp += abs(row.getInt("SG_D1") + d1);	
				}

				if (abs(row.getInt("SG_D2") + d2) <20) {
					
				}
				else if (row.getInt("SG_D2") + d2 <0) {
					d2tm += abs(row.getInt("SG_D2") + d2);
				}
				else {
					d2tp += abs(row.getInt("SG_D2") + d2);	
				}

				if (abs(row.getInt("SG_D3") + d3) <20) {
					
				}
				else if (row.getInt("SG_D3") + d3 <0) {
					d3tm += abs(row.getInt("SG_D3") + d3);
				}
				else {
					d3tp += abs(row.getInt("SG_D3") + d3);	
				}

				if (abs(row.getInt("SG_D4") + d4) <20) {
					
				}
				else if (row.getInt("SG_D4") + d4 <0) {
					d4tm += abs(row.getInt("SG_D4") + d4);
				}
				else {
					d4tp += abs(row.getInt("SG_D4") + d4);	
				}

				if (abs(row.getInt("SG_D5") + d5) <20) {
					
				}
				else if (row.getInt("SG_D5") + d5 <0) {
					d5tm += abs(row.getInt("SG_D5") + d5);
				}
				else {
					d5tp += abs(row.getInt("SG_D5") + d5);	
				}

				if (abs(row.getInt("SG_D6") + d6) <20) {
					
				}
				else if (row.getInt("SG_D6") + d6 <0) {
					d6tm += abs(row.getInt("SG_D6") + d6);
				}
				else {
					d6tp += abs(row.getInt("SG_D6") + d6);	
				}

				if (abs(row.getInt("SG_D7") + d7) <20) {
					
				}
				else if (row.getInt("SG_D7") + d7 <0) {
					d7tm += abs(row.getInt("SG_D7") + d7);
				}
				else {
					d7tp += abs(row.getInt("SG_D7") + d7);	
				}

				if (abs(row.getInt("SG_D8") + d8) <20) {
					
				}
				else if (row.getInt("SG_D8") + d8 <0) {
					d8tm += abs(row.getInt("SG_D8") + d8);
				}
				else {
					d8tp += abs(row.getInt("SG_D8") + d8);	
				}


			}



			// println("U"+ userDir.substring(4) + "_F"+ texture + "_" + rawDataName.substring(0, 4));
			
			//ignore force?
			//|| forceDir.equals("0.4") || || forceDir.equals("0.8") || forceDir.equals("1.0")
			// if(forceDir.equals("0.4"))//
			// {
			// 	continue;
			// }
			// int idNum = 0;


			// if (texture.equals("0.4")) {
			// 	idNum = 40;
			// }
			// else if (texture.equals("0.6")) {
			// 	idNum = 60;	
			// }
			// else if (texture.equals("0.8")) {
			// 	idNum = 80;
			// }
			// else if (texture.equals("1.0")) {
			// 	idNum = 100;
			// }
			// else if (texture.equals("1.2")) {
			// 	idNum = 120;
			// }


			// row.setString("ID",rawDataName.substring(3, 5));

			// println("rawDataName.substring(3, 5): "+rawDataName.substring(3, 5));

			// if (rawDataName.substring(3, 5).equals("d0")) {
			// 	row.setString("ID", "d0");
			// 	// row.setInt("ID", idNum);
			// 	// continue;
			// }
			// else if (rawDataName.substring(3, 5).equals("d1")) {
			// 	row.setString("ID", "d1");
			// 	// row.setInt("ID", idNum);
			// 	// continue;
			// }
			// else if (rawDataName.substring(3, 5).equals("d2")) {
			// 	row.setString("ID", "d2");
			// 	// row.setInt("ID", idNum);
			// 	// continue;
			// }
			// else if (rawDataName.substring(3, 5).equals("d3")) {//good!!
			// 	row.setString("ID", "d3");
			// 	// row.setInt("ID", idNum);
			// 	// continue;
			// }
			// else if (rawDataName.substring(3, 5).equals("d4")) {
			// 	row.setString("ID", "d4");
			// 	// row.setInt("ID", idNum);
			// 	// continue;
			// }
			// else if (rawDataName.substring(3, 5).equals("d5")) {
			// 	row.setString("ID", "d5");
			// 	// row.setInt("ID", idNum);
			// 	// continue;
			// }
			// else if (rawDataName.substring(3, 5).equals("d6")) {
			// 	row.setString("ID", "d6");
			// 	// row.setInt("ID", idNum);
			// 	// continue;
			// }
			// else if (rawDataName.substring(3, 5).equals("d7")) {
			// 	row.setString("ID", "d7");
			// 	// row.setInt("ID", idNum);
			// 	// continue;
			// }
		}
		newRow.setInt("ID", int(rawDataName.substring(4, 5)));
		newRow.setInt("SG0p", d0tp);
		newRow.setInt("SG0m", d0tm);
		newRow.setInt("SG1p", d1tp);
		newRow.setInt("SG1m", d1tm);
		newRow.setInt("SG2p", d2tp);
		newRow.setInt("SG2m", d2tm);
		newRow.setInt("SG3p", d3tp);
		newRow.setInt("SG3m", d3tm);
		newRow.setInt("SG4p", d4tp);
		newRow.setInt("SG4m", d4tm);
		newRow.setInt("SG5p", d5tp);
		newRow.setInt("SG5m", d5tm);
		newRow.setInt("SG6p", d6tp);
		newRow.setInt("SG6m", d6tm);
		newRow.setInt("SG7p", d7tp);
		newRow.setInt("SG7m", d7tm);
		newRow.setInt("SG8p", d8tp);
		newRow.setInt("SG8m", d8tm);



		//leave one force
		for (int i = 0; i < 10; ++i) {
			// if (Integer.valueOf(rawDataName.substring(1,2)) == 0) {
				// continue;
			// }
			if (i != Integer.valueOf(rawDataName.substring(1,2))) {
				saveTable(tableGenerater, STUDY_TWO_DATA_RESULT_CLASS_BY_LOO_TIME +"/U" + userDir.substring(4)+"/leaveT"+ i + "/" + rawDataName);
			}
			else {
				saveTable(tableGenerater, STUDY_TWO_DATA_RESULT_CLASS_BY_LOO_TIME +"/U" + userDir.substring(4)+"/T"+ i + "/" + rawDataName);
			}
			// println("rawDataName.substring(1,2): "+rawDataName.substring(1,2));;
		}

			

			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_USER_MIXED +"/F"+ forceDir + "/U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName);

			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE +"/U" + userDir.substring(4) + "/F"+ forceDir + "/U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName);

			// row.setString("ID", "F"+ forceDir + "_" + rawDataName.substring(0, 4));
			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_FORCE +"/U" +  userDir.substring(4) +"/F"+ forceDir+"_"+ rawDataName);
			// saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_LOO_USER +"/U" + );
		
	}

	@Override
	public void controlEvent(ControlEvent theEvent){}
}