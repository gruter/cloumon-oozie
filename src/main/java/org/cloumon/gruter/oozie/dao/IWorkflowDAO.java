package org.cloumon.gruter.oozie.dao;

import java.sql.Timestamp;
import java.util.List;

import org.cloumon.gruter.oozie.model.OozieApp;
import org.cloumon.gruter.oozie.model.OozieJob;
import org.cloumon.gruter.oozie.model.OozieJobHistory;

public interface IWorkflowDAO {
	public void insertOozieApp(OozieApp oozieApp) throws Exception;

	public void deleteOozieApp(String appName) throws Exception;
	
	public List<OozieApp> selectOozieApp() throws Exception;

	public void insertOozieJob(OozieJob oozieJob) throws Exception;

	public void updateOozieJob(OozieJob oozieJob) throws Exception;

	public List<OozieJob> selectOozieJob(String jobName) throws Exception;

	public List<OozieJob> selectOozieJobByApp(String appName) throws Exception;

	public void deleteOozieJob(String jobName) throws Exception;

	public void insertOozieJobHistory(OozieJobHistory oozieJobHistory) throws Exception;

	public void deleteOozieJobHistory(String jobName) throws Exception;

	public List<OozieJobHistory> selectOozieJobHistory(String jobName, Timestamp from, Timestamp to) throws Exception;
}
