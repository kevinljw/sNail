
public class UserProfile {

	public final static String USER_NAME = "jesse";
	public final static String USER_ID = "0"; // staring from 0
	public final static String USER_SEX = "male"; // 1 - male, 0 - female
	public final static String USER_HAND = "right"; // 1 - right, 0 - left
	public final static String NAME_OF_FILE = "UsersProfile.csv";

	public boolean createProfile() {
		//create user folder and add a profile file at profile file
			
		File f = new File(sketchPath("") + NAME_OF_FILE);
		if (f.exists()) {
			return false;
		}
		else{

			Table tableForProfile = new Table();
			tableForProfile.addColumn("userID");
			tableForProfile.addColumn("name");
			tableForProfile.addColumn("sex");
			tableForProfile.addColumn("hand");
			tableForProfile.addColumn("pilotOne");
			tableForProfile.addColumn("pilotTwo");
			tableForProfile.addColumn("studyOne");
			tableForProfile.addColumn("studyTwo");

			TableRow newRow = tableForProfile.addRow();
			newRow.setString("userID", USER_ID);
			newRow.setString("name", USER_NAME);
			newRow.setString("sex", USER_SEX);
			newRow.setString("hand", USER_HAND);
			newRow.setInt("pilotOne", 0); // 0 - means didn't do, 1- means doing, 2- means done
			newRow.setInt("pilotTwo", 0);
			newRow.setInt("studyOne", 0);
			newRow.setInt("studyTwo", 0);


			saveTable(tableForProfile, NAME_OF_FILE);
		}
		return true;
		
	}



	public void startDoingStudy(int typeOfTask) {
		//typeOfTask
		// 0 - PilotOne
		// 1 - PilotTwo
		// 2 - StudyOne
		// 3 - StudyTwo

		File f = new File(sketchPath("") + NAME_OF_FILE);

		if (f.exists())
		{
			Table tableForProfile = new Table();
			tableForProfile = loadTable( NAME_OF_FILE , "header, csv");
			TableRow result = tableForProfile.findRow(USER_ID, "userID");

			String typeName = "";

			switch (typeOfTask) {
				case 0 :
					typeName = "pilotOne";
					break;
				case 1 :
					typeName = "pilotTwo";
					break;
				case 2 :
					typeName = "studyOne";
					break;		
				case 3 :
					typeName = "studyTwo";
					break;	
				default :
					break;	
				
			}
			println("typeOfTask: "+typeOfTask);
			if (typeName != "") {
				if(result.getInt(typeName) == 1 || result.getInt(typeName) == 2)
				{
					println("The file already exists!!! Close app immediately");
					exit();
				}
				else
				{
					result.setInt(typeName, 1);
					saveTable(tableForProfile, NAME_OF_FILE);
				}
			}
		}
		else {
			println("You didn't create file first");
			exit();
		}
	}

	public void doneStudy(int typeOfTask) {
		Table tableForProfile = new Table();
		tableForProfile = loadTable( NAME_OF_FILE , "header, csv");
		TableRow result = tableForProfile.findRow(USER_ID, "userID");

		String typeName = "";

		switch (typeOfTask) {
			case 0 :
				typeName = "pilotOne";
				break;
			case 1 :
				typeName = "pilotTwo";
				break;
			case 2 :
				typeName = "studyOne";
				break;		
			case 3 :
				typeName = "studyTwo";
				break;	
			default :
				break;	
			
		}
		result.setInt(typeName, 2);
		saveTable(tableForProfile, NAME_OF_FILE);
	}
}