package org.cloumon.gruter.oozie.dao;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.cloumon.gruter.common.SqlMapBase;
import org.cloumon.gruter.oozie.model.OozieApp;
import org.cloumon.gruter.oozie.model.OozieJob;
import org.cloumon.gruter.oozie.model.OozieJobHistory;
import org.springframework.stereotype.Repository;

@Repository("workflowDAO")
public class WorkflowDAO extends SqlMapBase implements IWorkflowDAO {
	@Override
	public void insertOozieApp(OozieApp oozieApp) throws Exception {
		//this.sqlMapClient.insert("workflowSQL.insertOozieApp", oozieApp);
	}

	@Override
	public void deleteOozieApp(String appName) throws Exception {
		//this.sqlMapClient.delete("workflowSQL.deleteOozieApp", appName);
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<OozieApp> selectOozieApp() throws Exception {
		//return (List<OozieApp>)this.sqlMapClient.queryForList("workflowSQL.selectOozieApp");
		return null;
	}
	
	@Override
	public void insertOozieJobHistory(OozieJobHistory oozieJobHistory) throws Exception {
		this.sqlMapClient.insert("workflowSQL.insertOozieJobHistory", oozieJobHistory);
	}

	@Override
	public void deleteOozieJobHistory(String jobName) throws Exception {
		this.sqlMapClient.insert("workflowSQL.deleteOozieJobHistory", jobName);
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<OozieJobHistory> selectOozieJobHistory(String jobName, Timestamp from, Timestamp to) throws Exception {
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("jobName", jobName);
		if(from != null) {
			params.put("from", from);
			params.put("to", to);
		}
		return (List<OozieJobHistory>)this.sqlMapClient.queryForList("workflowSQL.selectOozieJobHistory", params);
	}
	
	@Override
	public void insertOozieJob(OozieJob oozieJob) throws Exception {
		this.sqlMapClient.insert("workflowSQL.insertOozieJob", oozieJob);
	}

	@Override
	public void updateOozieJob(OozieJob oozieJob) throws Exception {
		this.sqlMapClient.update("workflowSQL.updateOozieJob", oozieJob);
	}

	@Override
	public void deleteOozieJob(String jobName) throws Exception {
		this.sqlMapClient.delete("workflowSQL.deleteOozieJob", jobName);
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<OozieJob> selectOozieJob(String jobName) throws Exception {
		Map<String, String> params = new HashMap<String, String>();
		if(jobName != null && !jobName.isEmpty()) {
			params.put("jobName", jobName);
		}
		return (List<OozieJob>)this.sqlMapClient.queryForList("workflowSQL.selectOozieJob", params);
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public List<OozieJob> selectOozieJobByApp(String appName) throws Exception {
		Map<String, String> params = new HashMap<String, String>();
		params.put("appName", appName);
		return (List<OozieJob>)this.sqlMapClient.queryForList("workflowSQL.selectOozieJob", params);
	}
}
