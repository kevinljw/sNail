
public static class UserProfile {

	public final static String USER_NAME = "jesse";
	public final static String USER_ID = "0"; // staring from 0
	public final static String USER_SEX = "1"; // 1 - male, 0 - female
	public final static String USER_HAND = "1"; // 1 - right, 0 - left


	public static int createProfile() {
		if (!UserProfile.isExisted()) {
			//create user folder and add a profile file
		}
		return 0;
		
	}

	public static boolean isExisted() {
		File dir = new File("/");
		String[] list = dir.list();

		for (String filename : list) {
			if (filename == USER_ID) {
				return true;
			}
		}

		return false;
	}
}