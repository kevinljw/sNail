import java.util.ArrayList;

public class USOneAnalyzer implements ControlListener{

	public final static String STUDY_ONE_DATA = DATA_FOLDER + "/StudyOne";
	public final static String STUDY_ONE_DATA_RESULT_CLASS_BY_USER = STUDY_ONE_DATA + "/Result/User" ;
	public final static String STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE = STUDY_ONE_DATA + "/Result/UserWithForce" ;

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
		File result_dir = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_USER );
		String[] result_list = result_dir.list(new FilenameFilter() {
	        @Override
	        public boolean accept(File dir, String name) {
	            return !name.equals(".DS_Store");
	        }
	    });

	    for (int i = 0; i < result_list.length; ++i) {
			csvMerger.mergeFiles(STUDY_ONE_DATA_RESULT_CLASS_BY_USER + "/" + result_list[i]);
		}



		//categorize by force
	    File result_dir_with_Force = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE );
		String[] result_list_with_Force = result_dir_with_Force.list(new FilenameFilter() {
	        @Override
	        public boolean accept(File dir, String name) {
	            return !name.equals(".DS_Store");
	        }
	    });



		for (int i = 0; i < result_list_with_Force.length; ++i) {

			File result_dir_with_Force_folder = new File(sketchPath("") + STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE + "/"+result_list_with_Force[i]);

			String[] result_list_with_Force_folder = result_dir_with_Force_folder.list(new FilenameFilter() {
		        @Override
		        public boolean accept(File dir, String name) {
		            return !name.equals(".DS_Store");
		        }
		    });

		    for (int j = 0; j < result_list_with_Force_folder.length; ++j) {
		    	csvMerger.mergeFiles(STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE + "/" + result_list_with_Force[i] +"/" + result_list_with_Force_folder[j]);	
		    }
		}
	    
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
		// taskNumber,yaxis,xaxis,zaxis,force,SG0,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8
		table.removeColumn("taskNumber");
		table.removeColumn("yaxis");
		table.removeColumn("xaxis");
		table.removeColumn("zaxis");
		table.removeColumn("force");
		table.removeColumn("SG0");
		table.removeColumn("SG1");
		table.removeColumn("SG2");
		table.removeColumn("SG3");
		table.removeColumn("SG4");
		table.removeColumn("SG5");
		table.removeColumn("SG6");
		table.removeColumn("SG7");
		table.removeColumn("SG8");


		table.addColumn("ID");


		for (int k = 0; k < table.getRowCount(); ++k) {
			TableRow row = table.getRow(k);
			println("U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName.substring(0, rawDataName.length() - 4));
			row.setString("ID", "U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName.substring(0, rawDataName.length() - 4));
			saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_USER +"/U" + userDir.substring(4) + "/U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName);
			saveTable(table, STUDY_ONE_DATA_RESULT_CLASS_BY_USER_WITH_FORCE +"/U" + userDir.substring(4) + "/F"+ forceDir + "/U"+ userDir.substring(4) + "_F"+ forceDir + "_" + rawDataName);
		}
	}

	
	@Override
	public void controlEvent(ControlEvent theEvent){}

}