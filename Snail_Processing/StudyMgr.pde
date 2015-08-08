public class StudyMgr implements SerialListener{

	@Override
	public void registerToSerialNotifier(SerialNotifier notifier);
	@Override
	public void removeToSerialNotifier(SerialNotifier notifier);
	@Override
	public void updateDiscoveredSerialPorts(String [] portNames);
	@Override
	public void updateAnalogVals(float [] values);
	@Override
	public void updateCaliVals(float [] values);
	@Override
	public void updateTargetAnalogValsMinAmp(float [] values);
	@Override
	public void updateTargetAnalogValsWithAmp(float [] values);
	@Override
	public void updateBridgePotPosVals(float [] values);
	@Override
	public void updateAmpPotPosVals(float [] values);
	@Override
	public void updateCalibratingValsMinAmp(float [] values);
	@Override
	public void updateCalibratingValsWithAmp(float [] values);
	@Override
	public void updateReceiveRecordSignal();

}