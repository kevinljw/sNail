import java.util.ArrayList;
public class USTwoAnalyzer implements ControlListener{

	File dir = new File(sketchPath("") + DATA_FOLDER + "/StudyTwo");
	String[] list = dir.list();
	ArrayList<Table> csvs = new ArrayList<Table>();

	public USTwoAnalyzer () {
		
	}
	public void analysisData() {
		
	}

	@Override
	public void controlEvent(ControlEvent theEvent){}
}