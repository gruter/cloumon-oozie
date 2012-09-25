package org.cloumon.gruter.oozie.service.external;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.springframework.stereotype.Service;

@Service("oozieExternalService")
public class OozieExternalService implements IConfService, IHadoopService, 
							IHiveMetaStoreService, IHiveQueryService, IMapReduceService, IAlarmService {
	
	private Properties managerConf = new Properties();
	
	public OozieExternalService() {
		try {
			managerConf.load(this.getClass().getResourceAsStream("/settings.properties"));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public String get(String key) {
		return (String)managerConf.get(key);
	}
	
	@Override
	public String get(String key, String defaultValue) {
		String value = this.get(key);
		if(value == null) {
			return defaultValue;
		} else {
			return value;
		}
	}

	@Override
	public List<HiveConnection> getConnections() {
		return new ArrayList<HiveConnection>();
	}

	@Override
	public boolean getBoolean(String key, boolean defaultValue) {
		String value = this.get(key);
		if(value == null) {
			return defaultValue;
		} else {
			return "true".equalsIgnoreCase(value);
		}
	}

	@Override
	public List<HadoopCluster> listHadoopClusters() {
		return new ArrayList<HadoopCluster>();
	}

	@Override
	public List<HiveQuery> getHiveQueryList(int id) {
		return new ArrayList<HiveQuery>();
	}

	@Override
	public List<HadoopCluster> listMapReduceClusters() {
		return new ArrayList<HadoopCluster>();
	}

	@Override
	public void sendAlarm(String clusterType, String clusterName, String server, 
			String alarmType, String subject, List<String> alarmTargets, Map<String, String> messageParams) {
		
	}

}
