import java.util.ArrayList;
import java.io.*;

public class CSVMerger {

	SNailDataAnalyzer mainClass;

	public CSVMerger () {

	}


	Table allDataTableForSaving = new Table();
	Table currentReadDataForSaving = new Table();


	public void mergeFiles(String dirLocation, String prefix) {
		File mergeDir = new File(sketchPath("") + dirLocation);
		String[] file_list = mergeDir.list(new FilenameFilter() {
	        @Override
	        public boolean accept(File dir, String name) {
	            return !name.equals(".DS_Store");
	        }
	    });

		for (int i = 0; i < file_list.length; ++i) {

			if (i ==0) {
				allDataTableForSaving = loadTable(dirLocation +"/" + file_list[i], "header");
			}
			else
			{
				currentReadDataForSaving = loadTable(dirLocation + "/" + file_list[i], "header");	

				for (TableRow row : currentReadDataForSaving.rows()) {
					allDataTableForSaving.addRow(row);
				}
			}
		}
		saveTable(allDataTableForSaving, dirLocation + prefix + "merged.csv");
	}

	public void mergeCSVFilesWithIgnore(String dirLocation, int ignoreID, String prefix) {
		File mergeDir = new File(sketchPath("") + dirLocation);
		String[] file_list = mergeDir.list(new FilenameFilter() {
	        @Override
	        public boolean accept(File dir, String name) {
	            return name.contains(".csv");
	        }
	    });

		for (int i = 0; i < file_list.length; ++i) {

			if (i == ignoreID) {
				continue;
			}

			if (i ==0 && ignoreID!=0) {
				allDataTableForSaving = loadTable(dirLocation +"/" + file_list[i], "header");
			}
			else
			{
				if (ignoreID==0 && i ==1) {
					allDataTableForSaving = loadTable(dirLocation + "/" + file_list[i], "header");	
				}
				else
				{
					currentReadDataForSaving = loadTable(dirLocation + "/" + file_list[i], "header");	

					for (TableRow row : currentReadDataForSaving.rows()) {
						allDataTableForSaving.addRow(row);
					}
				}
			}
		}
		saveTable(allDataTableForSaving, dirLocation+ prefix + "merged.csv");
	}

}