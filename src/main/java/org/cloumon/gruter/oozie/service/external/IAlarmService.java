package org.cloumon.gruter.oozie.service.external;

import java.util.List;
import java.util.Map;

public interface IAlarmService {

	public void sendAlarm(String clusterType, String clusterName, String server, String alarmType, String subject, List<String> alarmTargets, Map<String, String> messageParams);

}
