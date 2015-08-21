public class CSVMerger {

	SNailDataAnalyzer mainClass;

	public CSVMerger () {

	}


	Table allDataTableForSaving = new Table();
	Table currentReadDataForSaving = new Table();


	public void mergeFiles(String dirLocation) {
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


		saveTable(allDataTableForSaving, dirLocation + "merged.csv");

		


	}

}