import java.util.ArrayList;
public class USOneAnalyzer implements ControlListener{

	File dir = new File(sketchPath("") +DATA_FOLDER + "/StudyOne");
	String[] list = dir.list();
	ArrayList<Table> csvs = new ArrayList<Table>();

	public USOneAnalyzer () {
		
	}

	public void analysisData() {
		
	}
	
	@Override
	public void controlEvent(ControlEvent theEvent){}

}