import java.util.ArrayList;
import java.io.*;

Table allDataTableForSaving = new Table();
Table currentReadDataForSaving = new Table();
public final static String DATA_FOLDER = "data";

void setup() {
 File mergeDir = new File(sketchPath("") + DATA_FOLDER);
    String[] file_list = mergeDir.list(new FilenameFilter() {
          @Override
          public boolean accept(File dir, String name) {
              return !name.equals(".DS_Store");
          }
      });

    for (int i = 0; i < file_list.length; ++i) {

      if (i ==0) {
        allDataTableForSaving = loadTable(DATA_FOLDER +"/" + file_list[i], "header");
      }
      else
      {
        currentReadDataForSaving = loadTable(DATA_FOLDER + "/" + file_list[i], "header");  

        for (TableRow row : currentReadDataForSaving.rows()) {
          allDataTableForSaving.addRow(row);
        }
      }
    }


    saveTable(allDataTableForSaving, DATA_FOLDER + "merged.csv"); 
}
