package org.cloumon.gruter.oozie.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.cloumon.gruter.oozie.model.AppLibFile;
import org.cloumon.gruter.oozie.model.OozieApp;
import org.cloumon.gruter.oozie.model.OozieClusterInfo;
import org.cloumon.gruter.oozie.model.OozieHiveQuery;
import org.cloumon.gruter.oozie.model.OozieJob;
import org.cloumon.gruter.oozie.model.OozieJobStatus;

public interface IWorkflowService {

	public void saveApp(OozieApp oozieApp) throws Exception;
	
	public void deleteOozieApp(String appName) throws Exception;
	
	public List<OozieApp> listOozieApp() throws Exception;
	
	public OozieApp getOozieApp(String appName) throws Exception;

	public void insertJob(OozieJob oozieJob) throws Exception;

	public void updateJob(OozieJob oozieJob) throws Exception;

	public void deleteOozieJob(String jobName) throws Exception;

	public List<OozieJob> listOozieJob() throws Exception;

	public List<OozieJob> listOozieJobByApp(String appName) throws Exception;
	
	public OozieJob getOozieJob(String jobName) throws Exception;

	public String runJob(String jobName) throws Exception;
	
	public void killJob(String jobId) throws Exception;

	public void suspendJob(String jobId) throws Exception;

	public void resumeJob(String jobId) throws Exception;

	public List<String> findProperties(String xml, boolean includeFuncion) throws Exception;

	public List<OozieJobStatus> getJobHistory(String jobName, String from, String to) throws Exception;
	
	public OozieJobStatus getOozieJobStatus(String jobId) throws Exception;
	
	public String getJobLog(String jobId) throws Exception;
	
	public List<AppLibFile> getAppLibFiles(String appName) throws Exception;
	
	public AppLibFile getAppLibFile(String fullPath) throws Exception;

	public void removeAppLibFile(String appName, String fileName, String libPath) throws Exception;

	public Map<String, String> getDefaultJobProperties(String type) throws Exception;
	
	public OozieClusterInfo getOozieClusterInfo() throws Exception;

	public void saveJob(OozieJob job) throws Exception;

	public List<OozieHiveQuery> getHiveQueries() throws Exception;

	public String saveQuery(String appName, String queryFile, String query) throws Exception;
	
	public String getQuery(String appName, String queryFile) throws Exception;
	
	public void callback(String jobId, String actionId, String status) throws Exception;

	public String runApp(String appName, String userName, String mailTo, HashMap<String, String> params) throws Exception;
	
	public List<String> getCommonFiles(String type) throws Exception;
}
